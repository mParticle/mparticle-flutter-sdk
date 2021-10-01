/// A Product for use with a commerce event
class Product {
  Product(this.name, this.sku, this.price,
      [this.quantity,
      this.variant,
      this.category,
      this.brand,
      this.position,
      this.couponCode,
      this.attributes]);

  final String name;
  final String sku;
  final int? quantity;
  final double price;
  final String? variant;
  final String? category;
  final String? brand;
  final int? position;
  final String? couponCode;
  final Map<String, String?>? attributes;

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
        json['name'] as String,
        json['sku'] as String,
        json['price'] as double,
        json['quantity'] as int,
        json['variant'] as String,
        json['category'] as String,
        json['brand'] as String,
        json['position'] as int,
        json['couponCode'] as String,
        json['attributes'] as Map<String, String?>);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'sku': this.sku,
      'quantity': this.quantity,
      'price': this.price,
      'variant': this.variant,
      'category': this.category,
      'brand': this.brand,
      'position': this.position,
      'couponCode': this.couponCode,
      'attributes': this.attributes
    };
  }
}
