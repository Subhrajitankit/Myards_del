package com.myards.deliveryman

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import org.json.JSONObject

class MyardsOverlayService : Service() {
    companion object {
        private const val TAG = "MyardsOverlay"
        private var instance: MyardsOverlayService? = null
        fun isRunning(): Boolean = instance != null
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var overlayLayoutParams: WindowManager.LayoutParams? = null
    private var currentOrderId: String? = null
    private var currentLatitude: String? = null
    private var currentLongitude: String? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        Log.d(TAG, "onCreate called")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand called flags=$flags startId=$startId")
        val orderJson = intent?.getStringExtra("orderJson") ?: intent?.getStringExtra("order_data")
        Log.d(TAG, "received extras orderJson_present=${!orderJson.isNullOrEmpty()}")
        if (orderJson != null) {
            try {
                val orderData = JSONObject(orderJson)
                currentOrderId = orderData.optString("orderId")
                currentLatitude = readField(orderData, "latitude", "")
                currentLongitude = readField(orderData, "longitude", "")
                Log.d(TAG, "orderJson parse result orderId=$currentOrderId")
                showOverlay(orderData)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to parse orderJson", e)
                stopSelf()
            }
        } else {
            Log.e(TAG, "No orderJson in onStartCommand; stopping service")
            stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun showOverlay(orderData: JSONObject) {
        if (overlayView != null) {
            Log.d(TAG, "Overlay already exists, removing previous view first")
            hideOverlay()
        }

        val canDraw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
        Log.d(TAG, "permission check result=$canDraw")
        if (!canDraw) {
            Log.e(TAG, "Overlay permission missing inside service")
            stopSelf()
            return
        }

        val inflater = LayoutInflater.from(this)
        try {
            Log.d(TAG, "inflating layout: myards_overlay_layout")
            overlayView = inflater.inflate(R.layout.myards_overlay_layout, null)
            Log.d(TAG, "full overlay layout inflated successfully")
        } catch (e: Exception) {
            Log.e(TAG, "fallback simple overlay used because full layout failed", e)
            try {
                overlayView = inflater.inflate(R.layout.myards_overlay_layout_simple, null)
            } catch (fallbackError: Exception) {
                Log.e(TAG, "fallback simple overlay also failed", fallbackError)
                stopSelf()
                return
            }
        }

        populateOverlayData(overlayView!!, orderData)
        setupOverlayActions(overlayView!!)

        overlayLayoutParams = WindowManager.LayoutParams().apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }
            format = PixelFormat.TRANSLUCENT
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
            width = WindowManager.LayoutParams.MATCH_PARENT
            height = WindowManager.LayoutParams.MATCH_PARENT
            gravity = Gravity.CENTER
        }

        try {
            Log.d(TAG, "WindowManager addView called")
            windowManager?.addView(overlayView, overlayLayoutParams)
            Log.d(TAG, "overlay added successfully")
        } catch (e: Exception) {
            Log.e(TAG, "addView exception", e)
            overlayView = null
            stopSelf()
        }
    }

    private fun populateOverlayData(view: View, orderData: JSONObject) {
        val orderId = view.findViewById<TextView>(R.id.tv_order_id)
        val restaurantName = view.findViewById<TextView>(R.id.tv_restaurant_name)
        val itemCount = view.findViewById<TextView>(R.id.tv_item_count)
        val pickupAddress = view.findViewById<TextView>(R.id.tv_pickup_address)
        val dropAddress = view.findViewById<TextView>(R.id.tv_drop_address)
        val customerName = view.findViewById<TextView>(R.id.tv_customer_name)
        val distance = view.findViewById<TextView>(R.id.tv_distance)
        val payment = view.findViewById<TextView>(R.id.tv_payment)
        val status = view.findViewById<TextView>(R.id.tv_status)
        val orderTime = view.findViewById<TextView>(R.id.tv_order_time)

        val orderIdText = readFirstField(orderData, arrayOf("orderId", "id"), "—")
        val restaurantNameText = readFirstField(
            orderData,
            arrayOf("restaurantName", "storeName", "store_name"),
            "Restaurant"
        )
        val restaurantLogoText = readFirstField(
            orderData,
            arrayOf("restaurantLogo", "storeLogoFullUrl", "store_logo_full_url"),
            ""
        )
        val itemCountText = formatItemCount(
            readFirstField(orderData, arrayOf("itemCount", "detailsCount", "details_count"), "")
        )
        val pickupAddressText = readFirstField(
            orderData,
            arrayOf("pickupAddress", "storeAddress", "store_address"),
            "Pickup address not available"
        )
        val dropAddressText = readFirstField(
            orderData,
            arrayOf("dropAddress", "deliveryAddress", "delivery_address"),
            "Delivery address not available"
        )
        val customerNameText = readFirstField(
            orderData,
            arrayOf("customerName", "customer_name"),
            "Customer"
        )
        val distanceText = formatDistance(
            readFirstField(orderData, arrayOf("distance", "distanceKm", "distance_km"), "")
        )
        val paymentMethodText = formatPayment(
            readFirstField(orderData, arrayOf("paymentMethod", "payment_method"), "Not available")
        )
        val paymentStatusText = formatStatus(
            readFirstField(orderData, arrayOf("paymentStatus", "payment_status"), "Not available")
        )
        val orderTimeText = formatOrderTime(
            readFirstField(orderData, arrayOf("orderTime", "createdAt", "created_at"), "")
        )

        orderId?.text = if (orderIdText == "—") "Order ID: —" else "Order ID: #$orderIdText"
        restaurantName?.text = restaurantNameText.ifBlank { "Restaurant" }
        itemCount?.text = itemCountText
        pickupAddress?.text = pickupAddressText.ifBlank { "Pickup address not available" }
        dropAddress?.text = dropAddressText.ifBlank { "Delivery address not available" }
        customerName?.text = if (customerNameText.equals("Customer", ignoreCase = true)) {
            "Customer"
        } else {
            "Customer: ${customerNameText.ifBlank { "Customer" }}"
        }
        distance?.text = distanceText
        payment?.text = paymentMethodText
        status?.text = paymentStatusText
        orderTime?.text = orderTimeText.ifBlank { "Just now" }

        Log.d(
            TAG,
            "binding overlay data orderId=$orderIdText restaurant=$restaurantNameText logo=${restaurantLogoText.isNotBlank()} itemCount=$itemCountText"
        )
    }

    private fun readFirstField(json: JSONObject, keys: Array<String>, fallback: String): String {
        for (key in keys) {
            val value = readField(json, key, "")
            if (value.isNotBlank()) {
                return value
            }
        }
        return fallback
    }

    private fun formatItemCount(raw: String): String {
        val value = raw.trim()
        val count = value.toIntOrNull()
        if (count != null) {
            return if (count == 1) "1 Item" else "$count Items"
        }

        val normalized = value.lowercase(Locale.US)
            .replace("items", "")
            .replace("item", "")
            .trim()
        val normalizedCount = normalized.toIntOrNull()
        if (normalizedCount != null) {
            return if (normalizedCount == 1) "1 Item" else "$normalizedCount Items"
        }

        return "Items not available"
    }

    private fun formatDistance(raw: String): String {
        val value = raw.trim()
        if (value.isBlank()) {
            return "Distance not available"
        }

        val numeric = value.lowercase(Locale.US)
            .replace("km", "")
            .replace("away from you", "")
            .replace("away", "")
            .trim()
            .toDoubleOrNull()

        if (numeric != null) {
            return String.format(Locale.US, "%.2f km away", numeric)
        }

        if (value.lowercase(Locale.US).contains("away")) {
            return value
        }
        if (value.lowercase(Locale.US).contains("km")) {
            return "$value away"
        }
        return "$value km away"
    }

    private fun formatPayment(raw: String): String {
        val value = raw.trim()
        if (value.isBlank()) {
            return "Payment: Not available"
        }

        val cleaned = value.replaceFirst(Regex("^payment\\s*:\\s*", RegexOption.IGNORE_CASE), "").trim()
        return "Payment: ${cleaned.ifBlank { "Not available" }}"
    }

    private fun formatStatus(raw: String): String {
        val value = raw.trim()
        if (value.isBlank()) {
            return "Status: Not available"
        }

        val cleaned = value.replaceFirst(Regex("^status\\s*:\\s*", RegexOption.IGNORE_CASE), "").trim()
        return "Status: ${cleaned.ifBlank { "Not available" }}"
    }

    private fun formatOrderTime(raw: String): String {
        val value = raw.trim()
        if (value.isBlank()) {
            return "Just now"
        }

        val lowered = value.lowercase(Locale.US)
        if (lowered == "just now" || lowered.contains("min ago") || lowered.contains("hour ago")) {
            return value
        }

        val parsedDate = parseServerDate(value) ?: return "Just now"
        val diffMillis = (System.currentTimeMillis() - parsedDate.time).coerceAtLeast(0)
        val minutes = diffMillis / (60 * 1000)
        val hours = diffMillis / (60 * 60 * 1000)

        return when {
            minutes < 1 -> "Just now"
            minutes < 60 -> "$minutes min ago"
            hours == 1L -> "1 hour ago"
            hours < 24 -> "$hours hours ago"
            else -> "Just now"
        }
    }

    private fun parseServerDate(raw: String): Date? {
        val patterns = arrayOf(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss"
        )

        for (pattern in patterns) {
            try {
                val parser = SimpleDateFormat(pattern, Locale.US)
                parser.timeZone = TimeZone.getTimeZone("UTC")
                return parser.parse(raw)
            } catch (_: Exception) {
                // Try the next known format.
            }
        }

        return null
    }

    private fun readField(json: JSONObject, key: String, fallback: String): String {
        return if (!json.has(key) || json.isNull(key)) {
            fallback
        } else {
            json.opt(key)?.toString()?.trim().takeUnless { it.isNullOrEmpty() } ?: fallback
        }
    }

    private fun setupOverlayActions(view: View) {
        val btnAccept = view.findViewById<Button>(R.id.btn_accept)
        val btnIgnore = view.findViewById<Button>(R.id.btn_ignore)
        val btnViewMap = view.findViewById<Button>(R.id.btn_view_map)
        val btnClose = view.findViewById<View>(R.id.btn_close)

        btnAccept?.setOnClickListener {
            Log.d(TAG, "accept clicked orderId=$currentOrderId")
            sendActionToApp("MYARDS_OVERLAY_ACCEPT")
            hideOverlay()
        }

        btnIgnore?.setOnClickListener {
            Log.d(TAG, "ignore clicked orderId=$currentOrderId")
            sendActionToApp("MYARDS_OVERLAY_IGNORE")
            hideOverlay()
        }

        btnViewMap?.setOnClickListener {
            Log.d(TAG, "view map clicked orderId=$currentOrderId")
            sendActionToApp("MYARDS_OVERLAY_VIEW_MAP")
            hideOverlay()
        }

        btnClose?.setOnClickListener {
            Log.d(TAG, "close clicked")
            sendActionToApp("MYARDS_OVERLAY_CLOSE")
            hideOverlay()
        }
    }

    private fun sendActionToApp(action: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            this.action = action
            putExtra("order_id", currentOrderId)
            putExtra("latitude", currentLatitude)
            putExtra("longitude", currentLongitude)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        Log.d(TAG, "sending action to app: action=$action orderId=$currentOrderId lat=$currentLatitude lng=$currentLongitude")
        startActivity(intent)
    }

    private fun hideOverlay() {
        removeOverlayView()
        stopSelf()
    }

    private fun removeOverlayView() {
        if (overlayView != null && windowManager != null) {
            try {
                Log.d(TAG, "Removing overlay view")
                windowManager?.removeView(overlayView)
            } catch (e: Exception) {
                Log.e(TAG, "Error removing overlay", e)
            }
            overlayView = null
            overlayLayoutParams = null
            Log.d(TAG, "overlay removed")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy called")
        removeOverlayView()
        instance = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
