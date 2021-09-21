/// This class represents the attributes of a commerce event transaction. It is used in conjunction with CommerceEvent.

class TransactionAttributes {
  TransactionAttributes(this.transactionId,
      [this.affiliation,
      this.couponCode,
      this.shipping,
      this.tax,
      this.revenue]);

  final String transactionId;
  final String? affiliation;
  final String? couponCode;
  final double? shipping;
  final double? tax;
  final double? revenue;

  static TransactionAttributes fromJson(Map<String, dynamic> json) {
    return TransactionAttributes(
        json['transactionId'] as String,
        json['affiliation'] as String,
        json['couponCode'] as String,
        json['shipping'] as double,
        json['tax'] as double,
        json['revenue'] as double);
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
