class TransactionReportModel {
  int? totalSize;
  int? limit;
  String? offset;
  double? onHold;
  double? canceled;
  double? completedTransactions;
  List<OrderTransactions>? orderTransactions;

  TransactionReportModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.onHold,
    this.canceled,
    this.completedTransactions,
    this.orderTransactions,
  });

  TransactionReportModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    onHold = json['on_hold']?.toDouble();
    canceled = json['canceled']?.toDouble();
    completedTransactions = json['completed_transactions']?.toDouble();
    if (json['order_transactions'] != null) {
      orderTransactions = <OrderTransactions>[];
      json['order_transactions'].forEach((v) {
        orderTransactions!.add(OrderTransactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['on_hold'] = onHold;
    data['canceled'] = canceled;
    data['completed_transactions'] = completedTransactions;
    if (orderTransactions != null) {
      data['order_transactions'] =
          orderTransactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderTransactions {
  int? orderId;
  String? restaurant;
  String? customerName;
  double? totalItemAmount;
  double? itemDiscount;
  double? couponDiscount;
  double? discountedAmount;
  double? vat;
  double? deliveryCharge;
  double? orderAmount;
  double? adminDiscount;
  double? restaurantDiscount;
  double? adminCommission;
  double? additionalCharge;
  double? commissionOnDeliveryCharge;
  double? adminNetIncome;
  double? restaurantNetIncome;
  String? amountReceivedBy;
  String? paymentMethod;
  String? paymentStatus;

  OrderTransactions({
    this.orderId,
    this.restaurant,
    this.customerName,
    this.totalItemAmount,
    this.itemDiscount,
    this.couponDiscount,
    this.discountedAmount,
    this.vat,
    this.deliveryCharge,
    this.orderAmount,
    this.adminDiscount,
    this.restaurantDiscount,
    this.adminCommission,
    this.additionalCharge,
    this.commissionOnDeliveryCharge,
    this.adminNetIncome,
    this.restaurantNetIncome,
    this.amountReceivedBy,
    this.paymentMethod,
    this.paymentStatus,
  });

  OrderTransactions.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    restaurant = json['restaurant'];
    customerName = json['customer_name'];
    totalItemAmount = json['total_item_amount']?.toDouble();
    itemDiscount = json['item_discount']?.toDouble();
    couponDiscount = json['coupon_discount']?.toDouble();
    discountedAmount = json['discounted_amount']?.toDouble();
    vat = json['vat']?.toDouble();
    deliveryCharge = json['delivery_charge']?.toDouble();
    orderAmount = json['order_amount']?.toDouble();
    adminDiscount = json['admin_discount']?.toDouble();
    restaurantDiscount = json['restaurant_discount']?.toDouble();
    adminCommission = json['admin_commission']?.toDouble();
    additionalCharge = json['additional_charge']?.toDouble();
    commissionOnDeliveryCharge = json['commission_on_delivery_charge']?.toDouble();
    adminNetIncome = json['admin_net_income']?.toDouble();
    restaurantNetIncome = json['restaurant_net_income']?.toDouble();
    amountReceivedBy = json['amount_received_by'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['restaurant'] = restaurant;
    data['customer_name'] = customerName;
    data['total_item_amount'] = totalItemAmount;
    data['item_discount'] = itemDiscount;
    data['coupon_discount'] = couponDiscount;
    data['discounted_amount'] = discountedAmount;
    data['vat'] = vat;
    data['delivery_charge'] = deliveryCharge;
    data['order_amount'] = orderAmount;
    data['admin_discount'] = adminDiscount;
    data['restaurant_discount'] = restaurantDiscount;
    data['admin_commission'] = adminCommission;
    data['additional_charge'] = additionalCharge;
    data['commission_on_delivery_charge'] = commissionOnDeliveryCharge;
    data['admin_net_income'] = adminNetIncome;
    data['restaurant_net_income'] = restaurantNetIncome;
    data['amount_received_by'] = amountReceivedBy;
    data['payment_method'] = paymentMethod;
    data['payment_status'] = paymentStatus;
    return data;
  }
}

class OrderReportModel {
  int? totalSize;
  int? limit;
  String? offset;
  OtherData? otherData;
  List<Orders>? orders;

  OrderReportModel({this.totalSize, this.limit, this.offset, this.otherData, this.orders});

  OrderReportModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    otherData = json['other_data'] != null ? OtherData.fromJson(json['other_data']) : null;
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (otherData != null) {
      data['other_data'] = otherData!.toJson();
    }
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OtherData {
  int? totalCanceledCount;
  int? totalDeliveredCount;
  int? totalProgressCount;
  int? totalFailedCount;
  int? totalRefundedCount;
  int? totalOnTheWayCount;
  int? totalAcceptedCount;
  int? totalPendingCount;
  int? totalScheduledCount;

  OtherData({
    this.totalCanceledCount,
    this.totalDeliveredCount,
    this.totalProgressCount,
    this.totalFailedCount,
    this.totalRefundedCount,
    this.totalOnTheWayCount,
    this.totalAcceptedCount,
    this.totalPendingCount,
    this.totalScheduledCount,
  });

  OtherData.fromJson(Map<String, dynamic> json) {
    totalCanceledCount = json['total_canceled_count'];
    totalDeliveredCount = json['total_delivered_count'];
    totalProgressCount = json['total_progress_count'];
    totalFailedCount = json['total_failed_count'];
    totalRefundedCount = json['total_refunded_count'];
    totalOnTheWayCount = json['total_on_the_way_count'];
    totalAcceptedCount = json['total_accepted_count'];
    totalPendingCount = json['total_pending_count'];
    totalScheduledCount = json['total_scheduled_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_canceled_count'] = totalCanceledCount;
    data['total_delivered_count'] = totalDeliveredCount;
    data['total_progress_count'] = totalProgressCount;
    data['total_failed_count'] = totalFailedCount;
    data['total_refunded_count'] = totalRefundedCount;
    data['total_on_the_way_count'] = totalOnTheWayCount;
    data['total_accepted_count'] = totalAcceptedCount;
    data['total_pending_count'] = totalPendingCount;
    data['total_scheduled_count'] = totalScheduledCount;
    return data;
  }
}

class Orders {
  int? orderId;
  double? totalItemAmount;
  double? itemDiscount;
  double? couponDiscount;
  double? discountedAmount;
  double? tax;
  double? deliveryCharge;
  double? additionalCharge;
  double? orderAmount;
  String? amountReceivedBy;
  String? paymentMethod;
  String? orderStatus;
  String? paymentStatus;
  double? deliverymanTips;

  Orders({
    this.orderId,
    this.totalItemAmount,
    this.itemDiscount,
    this.couponDiscount,
    this.discountedAmount,
    this.tax,
    this.deliveryCharge,
    this.additionalCharge,
    this.orderAmount,
    this.amountReceivedBy,
    this.paymentMethod,
    this.orderStatus,
    this.paymentStatus,
    this.deliverymanTips,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    totalItemAmount = json['total_item_amount']?.toDouble();
    itemDiscount = json['item_discount']?.toDouble();
    couponDiscount = json['coupon_discount']?.toDouble();
    discountedAmount = json['discounted_amount']?.toDouble();
    tax = json['tax']?.toDouble();
    deliveryCharge = json['delivery_charge']?.toDouble();
    additionalCharge = json['additional_charge']?.toDouble();
    orderAmount = json['order_amount']?.toDouble();
    amountReceivedBy = json['amount_received_by'];
    paymentMethod = json['payment_method'];
    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];
    deliverymanTips = json['dm_tips']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['total_item_amount'] = totalItemAmount;
    data['item_discount'] = itemDiscount;
    data['coupon_discount'] = couponDiscount;
    data['discounted_amount'] = discountedAmount;
    data['tax'] = tax;
    data['delivery_charge'] = deliveryCharge;
    data['additional_charge'] = additionalCharge;
    data['order_amount'] = orderAmount;
    data['amount_received_by'] = amountReceivedBy;
    data['payment_method'] = paymentMethod;
    data['order_status'] = orderStatus;
    data['payment_status'] = paymentStatus;
    data['dm_tips'] = deliverymanTips;
    return data;
  }
}

class FoodReportModel {
  int? totalSize;
  int? limit;
  String? offset;
  List<String>? label;
  List<double>? earning;
  double? earningAvg;
  String? avgType;
  List<Foods>? foods;

  FoodReportModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.label,
    this.earning,
    this.earningAvg,
    this.avgType,
    this.foods,
  });

  FoodReportModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    label = json['label'].cast<String>();
    if(json['earning'] != null) {
      earning = [];
      json['earning']?.forEach((e) => earning?.add(e.toDouble()));
    }
    earningAvg = json['earning_avg']?.toDouble() ?? 0;
    avgType = json['avg_type'];
    if (json['foods'] != null) {
      foods = <Foods>[];
      json['foods'].forEach((v) {
        foods!.add(Foods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['label'] = label;
    data['earning'] = earning;
    data['earning_avg'] = earningAvg;
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Foods {
  String? image;
  String? name;
  int? totalOrderCount;
  double? unitPrice;
  double? totalAmountSold;
  double? totalDiscountGiven;
  double? averageSaleValue;
  int? totalRatingsGiven;
  double? averageRatings;

  Foods({
    this.image,
    this.name,
    this.totalOrderCount,
    this.unitPrice,
    this.totalAmountSold,
    this.totalDiscountGiven,
    this.averageSaleValue,
    this.totalRatingsGiven,
    this.averageRatings,
  });

  Foods.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    name = json['name'];
    totalOrderCount = json['total_order_count'];
    unitPrice = json['unit_price']?.toDouble();
    totalAmountSold = json['total_amount_sold']?.toDouble();
    totalDiscountGiven = json['total_discount_given']?.toDouble();
    averageSaleValue = json['average_sale_value']?.toDouble();
    totalRatingsGiven = json['total_ratings_given'];
    averageRatings = json['average_ratings']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['total_order_count'] = totalOrderCount;
    data['unit_price'] = unitPrice;
    data['total_amount_sold'] = totalAmountSold;
    data['total_discount_given'] = totalDiscountGiven;
    data['average_sale_value'] = averageSaleValue;
    data['total_ratings_given'] = totalRatingsGiven;
    data['average_ratings'] = averageRatings;
    return data;
  }
}