import 'dart:js';

// Web integer values for product action types differ from Dart Enums
// https://github.com/mParticle/mparticle-web-sdk/blob/master/src/types.js#L255-L267
int? convertProductActionTypeIndexToJSProductActionType(
    int? productActionTypeEnum, JsObject productActionType) {
  if (productActionTypeEnum != null) {
    switch (productActionTypeEnum) {
      case 0:
        return productActionType["AddToCart"];
      case 1:
        return productActionType["RemoveFromCart"];
      case 2:
        return productActionType["AddToWishlist"];
      case 3:
        return productActionType["RemoveFromWishlist"];
      case 4:
        return productActionType["Checkout"];
      case 5:
        return productActionType["CheckoutOption"];
      case 6:
        return productActionType["Click"];
      case 7:
        return productActionType["ViewDetail"];
      case 8:
        return productActionType["Purchase"];
      // case 8 is "alias", which is deprecated
      case 9:
        return productActionType["Refund"];
      default:
        print(
            'You passed in a product action type that is not supported on Web. eCommerce event not logged.');
        return null;
    }
  } else {
    return null;
  }
}

// Web integer values for promotion action types differ from Dart Enums
// https://github.com/mParticle/mparticle-web-sdk/blob/master/src/types.js#L324-L328
int? convertPromotionActionTypeIndexToJSPromotionAction(
    int? promotionActionTypeEnum, JsObject promotionType) {
  if (promotionActionTypeEnum != null) {
    switch (promotionActionTypeEnum) {
      case 0:
        return promotionType["PromotionClick"];
      case 1:
        return promotionType["PromotionView"];
      default:
        print('You passed in a promotion action type is not supported on Web');
        return null;
    }
  } else {
    return null;
  }
}
