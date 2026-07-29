class EarningReportModel {
  final Summary? summary;
  final Trends? trends;
  final Transactions? transactions;

  EarningReportModel({this.summary, this.trends, this.transactions});

  factory EarningReportModel.fromJson(Map<String, dynamic> json) {
    return EarningReportModel(
      summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      trends: json['trends'] != null ? Trends.fromJson(json['trends']) : null,
      transactions: json['transactions'] != null ? Transactions.fromJson(json['transactions']) : null,
    );
  }
}

// ── Summary ───────────────────────────────────────────────
class Summary {
  final double? totalEarnings;
  final double? totalEarningsPercentage;
  final bool? totalEarningsPositive;
  final double? totalExpenses;
  final double? totalExpensesPercentage;
  final bool? totalExpensesPositive;
  final double? netProfit;
  final double? netProfitPercentage;
  final bool? netProfitPositive;
  final Breakdown? breakdown;

  Summary({
    this.totalEarnings,
    this.totalEarningsPercentage,
    this.totalEarningsPositive,
    this.totalExpenses,
    this.totalExpensesPercentage,
    this.totalExpensesPositive,
    this.netProfit,
    this.netProfitPercentage,
    this.netProfitPositive,
    this.breakdown,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalEarnings: num.tryParse(json['total_earnings'].toString())?.toDouble(),
      totalEarningsPercentage: num.tryParse(json['total_earnings_percentage'].toString())?.toDouble(),
      totalEarningsPositive: json['total_earnings_positive'] as bool?,
      totalExpenses: num.tryParse(json['total_expenses'].toString())?.toDouble(),
      totalExpensesPercentage: num.tryParse(json['total_expenses_percentage'].toString())?.toDouble(),
      totalExpensesPositive: json['total_expenses_positive'] as bool?,
      netProfit: num.tryParse(json['net_profit'].toString())?.toDouble(),
      netProfitPercentage: num.tryParse(json['net_profit_percentage'].toString())?.toDouble(),
      netProfitPositive: json['net_profit_positive'] as bool?,
      breakdown: json['breakdown'] != null ? Breakdown.fromJson(json['breakdown']) : null,
    );
  }
}

// ── Breakdown ─────────────────────────────────────────────
class Breakdown {
  final double? deliveryCharge;
  final double? dmTips;
  final String? incentives;
  final double? adminCommission;

  Breakdown({this.deliveryCharge, this.dmTips, this.incentives, this.adminCommission});

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      deliveryCharge: num.tryParse(json['delivery_charge'].toString())?.toDouble(),
      dmTips: num.tryParse(json['dm_tips'].toString())?.toDouble(),
      incentives: (json['incentives']),
      adminCommission: num.tryParse(json['admin_commission'].toString())?.toDouble(),
    );
  }
}

// ── Trends ────────────────────────────────────────────────
class Trends {
  final List<String>? categories;
  final List<double>? earningSeries;
  final List<double>? expenseSeries;

  Trends({this.categories, this.earningSeries, this.expenseSeries});

  factory Trends.fromJson(Map<String, dynamic> json) {
    return Trends(
      categories: (json['categories'] as List?)?.map((e) => e.toString()).toList(),
      earningSeries: (json['earning_series'] as List?)?.map((e) => num.tryParse(e.toString())?.toDouble()).whereType<double>().toList(),
      expenseSeries: (json['expense_series'] as List?)?.map((e) => num.tryParse(e.toString())?.toDouble()).whereType<double>().toList(),
    );
  }
}

// ── Transactions ──────────────────────────────────────────
class Transactions {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<TransactionData>? data;

  Transactions({this.totalSize, this.limit, this.offset, this.data});

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      totalSize: json['total_size'] as int?,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
      data: (json['data'] as List?)?.map((e) => TransactionData.fromJson(e)).toList(),
    );
  }
}

// ── TransactionData ───────────────────────────────────────
class TransactionData {
  final String? orderId;
  final String? rideId;
  final String? date;
  final double? deliveryCharge;
  final double? rideCost;
  final double? incentive;
  final double? tips;
  final double? commissionPaid;
  final double? netProfit;
  final double? vatTex;

  TransactionData({
    this.orderId,
    this.rideId,
    this.date,
    this.deliveryCharge,
    this.rideCost,
    this.incentive,
    this.tips,
    this.commissionPaid,
    this.netProfit,
    this.vatTex
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      orderId: json['order_id'] as String?,
      rideId: json['ride_id'] as String?,
      date: json['date'] as String?,
      deliveryCharge: num.tryParse(json['delivery_charge'].toString())?.toDouble(),
      rideCost: num.tryParse(json['ride_cost'].toString())?.toDouble(),
      incentive: num.tryParse(json['incentive'].toString())?.toDouble(),
      tips: num.tryParse(json['tips'].toString())?.toDouble(),
      commissionPaid: num.tryParse(json['commission_paid'].toString())?.toDouble(),
      netProfit: num.tryParse(json['net_profit'].toString())?.toDouble(),
      vatTex: num.tryParse(json['vat_tax'].toString())?.toDouble(),
    );
  }
}
