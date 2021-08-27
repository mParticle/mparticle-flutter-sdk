class Product {
  Product(this.name, this.sku, this.price, this.quantity);

  final String name;
  final String sku;
  final int quantity;
  final double price;

  static Product fromJson(Map<String, dynamic> json) {
    return Product(json['name'] as String, json['sku'] as String,
        json['price'] as double, json['quantity'] as int);
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
