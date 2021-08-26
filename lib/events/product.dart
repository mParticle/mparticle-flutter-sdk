class Product {
  Product(this.name, this.sku, this.quantity, this.price);

  final String name;
  final String sku;
  final int quantity;
  final double price;

  static Product fromJson(dynamic json) {
    return Product(json['name'] as String, json['sku'] as String,
        json['quantity'] as int, json['price'] as double);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'sku': this.sku,
      'quantity': this.quantity,
      'price': this.price
    };
  }
}
