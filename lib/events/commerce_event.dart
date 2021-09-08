import 'package:mparticle_flutter_sdk/events/product.dart';
import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';
import 'package:mparticle_flutter_sdk/events/transaction_attributes.dart';

import 'impression.dart';

class CommerceEvent {
  CommerceEvent.withProduct(this.productActionType, Product product)
      : promotionActionType = null {
    products.add(product);
  }

  CommerceEvent.withPromotion(this.promotionActionType, Promotion promotion)
      : productActionType = null {
    promotions.add(promotion);
  }

  CommerceEvent.withImpression(Impression impression)
      : promotionActionType = null,
        productActionType = null {
    impressions.add(impression);
  }

  final ProductActionType? productActionType;
  final PromotionActionType? promotionActionType;

  final List<Promotion> promotions = [];
  final List<Product> products = [];
  final List<Impression> impressions = [];

  TransactionAttributes? transactionAttributes;
  String? checkoutOptions;
  String? currency;
  String? productListName;
  String? productListSource;
  String? screenName;
  int? checkoutStep;
  bool? nonInteractive;
  bool? shouldUploadEvent;

  Map<String, String?>? customAttributes;
  Map<String, dynamic>? customFlags;
}
