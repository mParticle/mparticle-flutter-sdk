import 'package:mparticle_flutter_sdk/events/product.dart';
import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';
import 'package:mparticle_flutter_sdk/events/transaction_attributes.dart';

import 'impression.dart';

/// A commerce event
///
/// A commerce event can either contain Products, Promotions, or Impressions.
class CommerceEvent {
  /// Initializes an instance of a Commerce Event with an action and a product.
  CommerceEvent.withProduct(
      {required this.productActionType, required Product product})
      : promotionActionType = null {
    products.add(product);
  }

  /// Initializes an instance of MPCommerceEvent with a promotion container
  CommerceEvent.withPromotion(
      {required this.promotionActionType, required Promotion promotion})
      : productActionType = null {
    promotions.add(promotion);
  }

  /// Initializes an instance of MPCommerceEvent with a product impression.
  CommerceEvent.withImpression({required Impression impression})
      : promotionActionType = null,
        productActionType = null {
    impressions.add(impression);
  }

  /// A value from the ProductActionType enum describing the commerce event action.
  final ProductActionType? productActionType;

  /// A value from the PromotionActionType enum describing the promotion action.
  final PromotionActionType? promotionActionType;

  /// A list of internal promotions applied to the commerce action.
  final List<Promotion> promotions = [];

  /// A list of products being applied to the commerce action.
  final List<Product> products = [];

  /// A list of impressions being applied to the commerce action.
  final List<Impression> impressions = [];

  /// The attributes of the transaction, such as: transactionId, tax, affiliation, shipping, etc.
  TransactionAttributes? transactionAttributes;

  /// The checkout option string describing what the options are.
  String? checkoutOptions;

  /// The currency used in the commerce event.
  String? currency;

  /// Describes a product action list for this commerce event transaction.
  String? productListName;

  /// Describes a product list source for this commerce event transaction.
  String? productListSource;

  /// The label describing the screen on which the commerce event transaction occurred
  String? screenName;

  /// The step number, within the chain of commerce event transactions, corresponding to the checkout.
  int? checkoutStep;

  /// Flag indicating whether a refund is non-interactive.
  bool? nonInteractive;

  /// Flag indicating whether the event should be sent to mParticle's servers.
  bool? shouldUploadEvent;

  /// A map containing further information about the commerce event.
  Map<String, String?>? customAttributes;

  /// A map containing kit-specific flags about the commerce event.
  Map<String, dynamic>? customFlags;
}
