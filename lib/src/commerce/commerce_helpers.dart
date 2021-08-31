import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';

String productActionTypeString(ProductActionType productActionType) {
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

String promotionActionTypeString(PromotionActionType productActionType) {
  switch (productActionType) {
    case PromotionActionType.Click:
      return "click";
    case PromotionActionType.View:
      return "view";
  }
}