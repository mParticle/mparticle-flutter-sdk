class TransactionAttributes {
  TransactionAttributes(this.affiliation, this.couponCode, this.shipping,
      this.tax, this.revenue, this.transactionId);

  final String? affiliation;
  final String? couponCode;
  final double? shipping;
  final double? tax;
  final double? revenue;
  final String? transactionId;

  static TransactionAttributes fromJson(dynamic json) {
    return TransactionAttributes(
        json['affiliation'] as String,
        json['couponCode'] as String,
        json['shipping'] as double,
        json['tax'] as double,
        json['revenue'] as double,
        json['transactionId'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'affiliation': this.affiliation,
      'couponCode': this.couponCode,
      'shipping': this.shipping,
      'tax': this.tax,
      'revenue': this.revenue,
      'transactionId': this.transactionId
    };
  }
}
