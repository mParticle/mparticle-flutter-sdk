import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';

// Android integer values for product action types differ from Dart Enums
// https://github.com/mParticle/mparticle-android-sdk/blob/6bd755a6350024bee8dbb263b7a059536f7f9b07/android-core/src/main/java/com/mparticle/commerce/Product.java#L33-L42
String getAndroidSDKProductActionTypeString(
    ProductActionType productActionType) {
  switch (productActionType) {
    case ProductActionType.AddToCart:
      return "add_to_cart";
    case ProductActionType.RemoveFromCart:
      return "remove_from_cart";
    case ProductActionType.AddToWishList:
      return "add_to_wishlist";
    case ProductActionType.RemoveFromWishlist:
      return "remove_from_wishlist";
    case ProductActionType.Checkout:
      return "checkout";
    case ProductActionType.Click:
      return "click";
    case ProductActionType.ViewDetail:
      return "view_detail";
    case ProductActionType.Purchase:
      return "purchase";
    case ProductActionType.Refund:
      return "refund";
    case ProductActionType.CheckoutOptions:
      return "checkout_option";
  }
}

// Android integer values for product action types differ from Dart Enums
// https://github.com/mParticle/mparticle-android-sdk/blob/6bd755a6350024bee8dbb263b7a059536f7f9b07/android-core/src/main/java/com/mparticle/commerce/Promotion.java#L45-L50
String getAndroidSDKPromotionActionTypeString(
    PromotionActionType productActionType) {
  switch (productActionType) {
    case PromotionActionType.Click:
      return "click";
    case PromotionActionType.View:
      return "view";
  }
}

// Web integer values for product action types differ from Dart Enums
// https://github.com/mParticle/mparticle-web-sdk/blob/master/src/types.js#L255-L267
int? getWebSDKProductActionType(ProductActionType productActionType) {
  const jsProductActionTypes = {
    'AddToCart': 1,
    'RemoveFromCart': 2,
    'Checkout': 3,
    'CheckoutOption': 4,
    'Click': 5,
    'ViewDetail': 6,
    'Purchase': 7,
    'Refund': 8,
    'AddToWishlist': 9,
    'RemoveFromWishlist': 10,
  };

  switch (productActionType) {
    case ProductActionType.AddToCart:
      return jsProductActionTypes['AddToCart'];
    case ProductActionType.RemoveFromCart:
      return jsProductActionTypes['RemoveFromCart'];
    case ProductActionType.AddToWishList:
      return jsProductActionTypes['AddToWishlist'];
    case ProductActionType.RemoveFromWishlist:
      return jsProductActionTypes['RemoveFromWishlist'];
    case ProductActionType.Checkout:
      return jsProductActionTypes['Checkout'];
    case ProductActionType.Click:
      return jsProductActionTypes['CheckoutOption'];
    case ProductActionType.ViewDetail:
      return jsProductActionTypes['Click'];
    case ProductActionType.Purchase:
      return jsProductActionTypes['ViewDetail'];
    case ProductActionType.Refund:
      return jsProductActionTypes['Purchase'];
    case ProductActionType.CheckoutOptions:
      return jsProductActionTypes['Refund'];
  }
}

// Web integer values for promotion action types differ from Dart Enums
// https://github.com/mParticle/mparticle-web-sdk/blob/master/src/types.js#L324-L328
int? getWebSDKPromotionActionType(PromotionActionType promotionActionTypeEnum) {
  const jsPromotionActionTypes = {
    'PromotionView': 1,
    'PromotionClick': 2,
  };
  switch (promotionActionTypeEnum) {
    case PromotionActionType.Click:
      return jsPromotionActionTypes["PromotionClick"];
    case PromotionActionType.View:
      return jsPromotionActionTypes["PromotionView"];
  }
}
