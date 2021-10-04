/// This class represents the attributes of a commerce event transaction. It is used in conjunction with CommerceEvent.

class TransactionAttributes {
  TransactionAttributes(
      {required this.transactionId,
      this.affiliation,
      this.couponCode,
      this.shipping,
      this.tax,
      this.revenue});

  /// The unique identifier for the commerce event transaction.
  final String transactionId;

  /// A string describing the affiliation.
  final String? affiliation;

  /// The coupon code string.
  final String? couponCode;

  ///The shipping amount of the commerce event transaction.
  final double? shipping;

  /// The tax amount of the commerce event transaction.
  final double? tax;

  /// The revenue amount of the commerce event transaction.
  final double? revenue;

  static TransactionAttributes fromJson(Map<String, dynamic> json) {
    return TransactionAttributes(
        transactionId: json['transactionId'] as String,
        affiliation: json['affiliation'] as String,
        couponCode: json['couponCode'] as String,
        shipping: json['shipping'] as double,
        tax: json['tax'] as double,
        revenue: json['revenue'] as double);
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': this.transactionId,
      'affiliation': this.affiliation,
      'couponCode': this.couponCode,
      'shipping': this.shipping,
      'tax': this.tax,
      'revenue': this.revenue
    };
  }
}
