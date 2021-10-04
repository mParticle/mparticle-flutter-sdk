/// A Product for use with a commerce event
class Product {
  Product(
      {required this.name,
      required this.sku,
      required this.price,
      this.quantity,
      this.variant,
      this.category,
      this.brand,
      this.position,
      this.couponCode,
      this.attributes});

  /// The product name.
  final String name;

  /// SKU of a product. This is the product id.
  final String sku;

  /// The price of a product
  final double price;

  /// The quantity of the product. Default value is 1.
  final int? quantity;

  /// The variant of the product.
  final String? variant;

  /// A category to which the product belongs.
  final String? category;

  /// The product brand.
  final String? brand;

  /// The prosition of the product on the screen.
  final int? position;

  /// The coupon associated with the product.
  final String? couponCode;

  /// A map containing further information about the product.
  final Map<String, String?>? attributes;

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
        name: json['name'] as String,
        sku: json['sku'] as String,
        price: json['price'] as double,
        quantity: json['quantity'] as int,
        variant: json['variant'] as String,
        category: json['category'] as String,
        brand: json['brand'] as String,
        position: json['position'] as int,
        couponCode: json['couponCode'] as String,
        attributes: json['attributes'] as Map<String, String?>);
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
