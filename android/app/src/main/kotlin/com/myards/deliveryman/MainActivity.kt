package com.myards.deliveryman

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MyardsOverlay"
        private const val OVERLAY_CHANNEL = "myards_delivery_overlay"
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 2001
    }

    private var pendingAction: String? = null
    private var pendingOrderId: String? = null
    private var pendingLatitude: String? = null
    private var pendingLongitude: String? = null

    private var overlayChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "MethodChannel initialized: $OVERLAY_CHANNEL")
        overlayChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)

        overlayChannel?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkOverlayPermission" -> {
                        Log.d(TAG, "checkOverlayPermission called")
                        val hasPermission = canDrawOverlays()
                        Log.d(TAG, "permission result=$hasPermission")
                        result.success(hasPermission)
                    }
                    "openOverlayPermissionSettings" -> {
                        Log.d(TAG, "openOverlayPermissionSettings called")
                        openOverlaySettings()
                        result.success(null)
                    }
                    "showDeliveryRequestOverlay" -> {
                        Log.d(TAG, "showDeliveryRequestOverlay called")
                        val orderJson = call.argument<String>("orderJson")
                            ?: call.argument<String>("order_data")

                        Log.d(TAG, "received orderJson nullOrEmpty=${orderJson.isNullOrEmpty()}")
                        if (!orderJson.isNullOrEmpty()) {
                            try {
                                val started = showOverlay(orderJson)
                                Log.d(TAG, "Overlay method result: $started")
                                result.success(started)
                            } catch (e: Exception) {
                                Log.e(TAG, "Failed to start overlay service", e)
                                result.error("SERVICE_START_FAILED", e.message, null)
                            }
                        } else {
                            Log.e(TAG, "showDeliveryRequestOverlay failed: order payload missing")
                            result.error("MISSING_ORDER_DATA", "order_data/orderJson is missing", null)
                        }
                    }
                    "hideDeliveryRequestOverlay" -> {
                        Log.d(TAG, "hideDeliveryRequestOverlay called")
                        hideOverlay()
                        result.success(true)
                    }
                    "getPendingOverlayAction" -> {
                        val payload = if (!pendingAction.isNullOrEmpty()) {
                            mapOf(
                                "action" to pendingAction,
                                "orderId" to pendingOrderId,
                                "latitude" to pendingLatitude,
                                "longitude" to pendingLongitude
                            )
                        } else {
                            mapOf<String, String?>(
                                "action" to null,
                                "orderId" to null,
                                "latitude" to null,
                                "longitude" to null
                            )
                        }
                        Log.d(TAG, "getPendingOverlayAction returning action=$pendingAction orderId=$pendingOrderId lat=$pendingLatitude lng=$pendingLongitude")
                        pendingAction = null
                        pendingOrderId = null
                        pendingLatitude = null
                        pendingLongitude = null
                        result.success(payload)
                    }
                    else -> {
                        Log.d(TAG, "Unknown method: ${call.method}")
                        result.notImplemented()
                    }
                }
            }

        handleOverlayAction(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d(TAG, "onNewIntent action=${intent.action}")
        handleOverlayAction(intent)
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun openOverlaySettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            Log.d(TAG, "Opening overlay settings for package=$packageName")
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST_CODE)
        }
    }

    private fun showOverlay(orderJson: String): Boolean {
        Log.d(TAG, "showOverlay called isServiceRunning=${MyardsOverlayService.isRunning()}")
        if (MyardsOverlayService.isRunning()) {
            Log.d(TAG, "Overlay service already running; skipping start")
            return true
        }

        val intent = Intent(this, MyardsOverlayService::class.java).apply {
            putExtra("orderJson", orderJson)
        }

        if (!canDrawOverlays()) {
            Log.e(TAG, "Cannot start overlay service: overlay permission missing")
            return false
        }

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startService(intent)
            } else {
                startService(intent)
            }
            Log.d(TAG, "Overlay service start requested")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start overlay service", e)
            false
        }
    }

    private fun hideOverlay() {
        val intent = Intent(this, MyardsOverlayService::class.java)
        Log.d(TAG, "hideOverlay requested")
        stopService(intent)
    }

    private fun handleOverlayAction(intent: Intent) {
        val orderId = intent.getStringExtra("order_id")
        val latitude = intent.getStringExtra("latitude")
        val longitude = intent.getStringExtra("longitude")
        when (intent.action) {
            "MYARDS_OVERLAY_ACCEPT" -> {
                Log.d(TAG, "Overlay action ACCEPT received for orderId=$orderId")
                pendingAction = "MYARDS_OVERLAY_ACCEPT"
                pendingOrderId = orderId
                pendingLatitude = latitude
                pendingLongitude = longitude
                overlayChannel?.invokeMethod(
                    "onOverlayAccept",
                    mapOf("orderId" to orderId, "latitude" to latitude, "longitude" to longitude)
                )
            }
            "MYARDS_OVERLAY_IGNORE" -> {
                Log.d(TAG, "Overlay action IGNORE received for orderId=$orderId")
                pendingAction = "MYARDS_OVERLAY_IGNORE"
                pendingOrderId = orderId
                pendingLatitude = latitude
                pendingLongitude = longitude
                overlayChannel?.invokeMethod(
                    "onOverlayIgnore",
                    mapOf("orderId" to orderId, "latitude" to latitude, "longitude" to longitude)
                )
            }
            "MYARDS_OVERLAY_VIEW_MAP" -> {
                Log.d(TAG, "Overlay action VIEW_MAP received for orderId=$orderId")
                pendingAction = "MYARDS_OVERLAY_VIEW_MAP"
                pendingOrderId = orderId
                pendingLatitude = latitude
                pendingLongitude = longitude
                overlayChannel?.invokeMethod(
                    "onOverlayViewMap",
                    mapOf("orderId" to orderId, "latitude" to latitude, "longitude" to longitude)
                )
            }
            "MYARDS_OVERLAY_CLOSE" -> {
                Log.d(TAG, "Overlay action CLOSE received for orderId=$orderId")
                pendingAction = "MYARDS_OVERLAY_CLOSE"
                pendingOrderId = orderId
                pendingLatitude = latitude
                pendingLongitude = longitude
                overlayChannel?.invokeMethod(
                    "onOverlayClose",
                    mapOf("orderId" to orderId, "latitude" to latitude, "longitude" to longitude)
                )
            }
        }
    }
}

