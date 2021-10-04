import 'package:mparticle_flutter_sdk/events/product.dart';

/// An Impression for use with a commerce event
///
/// An Impression assigns an [impressionListName] to a list of [products]
class Impression {
  Impression({required this.impressionListName, required this.products});

  /// A string name given to the list where the given Products displayed.
  String impressionListName;

  /// Product(s) to be associate with the Impression.
  List<Product> products;

  static Impression fromJson(Map<String, dynamic> json) {
    return Impression(
        impressionListName: json['impressionListName'] as String,
        products: json['products'] as List<Product>);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> productsJSON = [];
    for (var product in this.products) {
      productsJSON.add(product.toJson());
    }
    return {
      'impressionListName': this.impressionListName,
      'products': productsJSON
    };
  }
}
