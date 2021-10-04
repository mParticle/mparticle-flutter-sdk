// This file implements the public facing API for the Flutter plugin

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mparticle_flutter_sdk/events/commerce_event.dart';
import 'package:mparticle_flutter_sdk/events/event_type.dart';
import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';
import 'package:mparticle_flutter_sdk/identity/identity_type.dart';
import 'package:mparticle_flutter_sdk/apple/authorization_status.dart';
import 'package:mparticle_flutter_sdk/src/commerce/commerce_helpers.dart';
import 'package:mparticle_flutter_sdk/src/identity/identity_helpers.dart';
import 'package:mparticle_flutter_sdk/src/user.dart';

import 'events/mp_event.dart';
import 'events/screen_event.dart';
import 'identity/alias_request.dart';
import 'identity/identity_api_result.dart';
import 'identity/identity_type.dart';

/// The interface that implements the mParticle Dart SDK.
class MparticleFlutterSdk {
  static MparticleFlutterSdk? _instance;

  /// Returns an active instance of MparticleFlutterSDK if the underlying platform SDK has been initialized.
  ///
  /// The most common reason that this method returns null is if an API Key and
  /// secret have not been provided properly to the underlying platform SDK.
  static Future<MparticleFlutterSdk?> getInstance() async {
    try {
      if (_instance == null) {
        if (await _channel.invokeMethod('isInitialized') == true) {
          _instance = new MparticleFlutterSdk();
        }
      }
      return _instance;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static const MethodChannel _channel =
      const MethodChannel('mparticle_flutter_sdk');

  /// The identity request object required to pass into Identity calls.
  static IdentityRequest identityRequest = new IdentityRequest();

  /// The identity API to make identity calls.
  Identity identity = new Identity._();

  /// Returns the appName set in your web SDK.  There is no iOS or Android equivalent.
  Future<String?> get getAppName async {
    final String? appName = await _channel.invokeMethod('getAppName');
    return appName;
  }

  /// Returns the opt out status.
  Future<bool> get getOptOut async {
    final bool optOutStatus = await _channel.invokeMethod('getOptOut');
    return optOutStatus;
  }

  /// Returns if a kit is active given a [kitId].
  Future<bool> isKitActive({
    required int kit,
  }) async {
    return await _channel.invokeMethod('isKitActive', {'kitId': kit});
  }

  /// Logs a product commerce event with an [productActionType], a promotion commerce event with a [eventType], and an impression commerce event if neither of the prior are implemented.
  Future<void> logCommerceEvent(CommerceEvent commerceEvent) async {
    var commerceEventMessage = {
      'products': commerceEvent.products.map((e) => e.toJson()).toList(),
      'promotions': commerceEvent.promotions.map((e) => e.toJson()).toList(),
      'impressions': commerceEvent.impressions.map((e) => e.toJson()).toList(),
      'transactionAttributes': commerceEvent.transactionAttributes?.toJson(),
      'checkoutOptions': commerceEvent.checkoutOptions,
      'currency': commerceEvent.currency,
      'productListName': commerceEvent.productListName,
      'productListSource': commerceEvent.productListSource,
      'screenName': commerceEvent.screenName,
      'checkoutStep': commerceEvent.checkoutStep,
      'nonInteractive': commerceEvent.nonInteractive,
      'shouldUploadEvent': commerceEvent.shouldUploadEvent,
      'customAttributes': commerceEvent.customAttributes,
      'customFlags': commerceEvent.customFlags
    };
    ProductActionType? productActionType = commerceEvent.productActionType;
    PromotionActionType? promotionActionType =
        commerceEvent.promotionActionType;
    if (productActionType != null) {
      commerceEventMessage['productActionType'] =
          ProductActionType.values.indexOf(productActionType);
      commerceEventMessage['androidProductActionType'] =
          getAndroidSDKProductActionTypeString(productActionType);
      commerceEventMessage['jsProductActionType'] =
          getWebSDKProductActionType(productActionType);
    } else if (promotionActionType != null) {
      commerceEventMessage['promotionActionType'] =
          PromotionActionType.values.indexOf(promotionActionType);
      commerceEventMessage['androidPromotionActionType'] =
          getAndroidSDKPromotionActionTypeString(promotionActionType);
      commerceEventMessage['jsPromotionActionType'] =
          getWebSDKPromotionActionType(promotionActionType);
    }
    return await _channel.invokeMethod(
        'logCommerceEvent', {"commerceEvent": commerceEventMessage});
  }

  /// Logs an error event with an [eventName] and [customAttributes].
  Future<void> logError({
    required String eventName,
    Map<String, String?>? customAttributes,
  }) async {
    return await _channel.invokeMethod('logError', {
      'eventName': eventName,
      'customAttributes': customAttributes,
    });
  }

  /// Logs an MPEvent
  Future<void> logEvent(MPEvent event) async {
    return await _channel.invokeMethod('logEvent', {
      'eventName': event.eventName,
      'eventType': EventType.values.indexOf(event.eventType as EventType),
      'customAttributes': event.customAttributes,
      'customFlags': event.customFlags,
      'shouldUploadEvent': event.shouldUploadEvent
    });
  }

  /// Logs a push registration with a [pushToken] and [senderId].
  ///
  /// For iOS, only [pushToken] is required.  Pass null as [senderId].
  /// This is iOS/Android only.
  Future<void> logPushRegistration({
    required String pushToken,
    String? senderId,
  }) async {
    return await _channel.invokeMethod(
        'logPushRegistration', {'pushToken': pushToken, 'senderId': senderId});
  }

  /// Logs a screen event (in web parlance, a 'page view') with an [eventName], [customAttributes], and [customFlags]
  Future<void> logScreenEvent(ScreenEvent screenEvent) async {
    return await _channel.invokeMethod('logScreenEvent', {
      'eventName': screenEvent.eventName,
      'customAttributes': screenEvent.customAttributes,
      'customFlags': screenEvent.customFlags
    });
  }

  /// Sets the [attStatus] with a [timestampInMillis] for iOS
  Future<void> setATTStatus({
    required MPATTAuthorizationStatus attStatus,
    int? timestampInMillis,
  }) async {
    return await _channel.invokeMethod('setATTStatus', {
      'attStatus': MPATTAuthorizationStatus.values.indexOf(attStatus),
      'timestampInMillis': timestampInMillis,
    });
  }

  /// Sets the opt out status with an [optOutBoolean]
  Future<void> setOptOut(
    bool optOutBoolean,
  ) async {
    return await _channel
        .invokeMethod('setOptOut', {'optOutBoolean': optOutBoolean});
  }

  /// Forces a manual upload of the batch.
  ///
  /// Uploading occurs at different intervals, or after certain events are fired.
  /// You can call this manually when you want to force a manual upload.
  /// On web, this is only enabled if you are configured for batching. To
  /// determine if you are configured for batching, see [here](https://docs.mparticle.com/developers/sdk/web/getting-started/#upload-interval--batching
  Future<void> upload() async {
    return await _channel.invokeMethod('upload');
  }

  Future<User?> getCurrentUser() async {
    String mpid = await _channel.invokeMethod('getMPID');
    if (mpid == "") {
      return null;
    }
    return new User(mpid);
  }

  Future<Map> getAttributions() async {
    String attributionsString = await _channel.invokeMethod('getAttributions');
    Map attributionsMap = jsonDecode(attributionsString);
    return attributionsMap;
  }
}

/// An object that contains identities that are passed to [identity] calls
class IdentityRequest {
  Map<IdentityType, String> identities = new Map();

  IdentityRequest setIdentity(
      {required IdentityType identityType, required String value}) {
    this.identities[identityType] = value;
    return this;
  }

  String? getIdentity(IdentityType identityType) {
    if (this.identities[identityType] != null) {
      return this.identities[identityType];
    }
  }

  Map<IdentityType, String> getIdentities() {
    return this.identities;
  }
}

/// The Identity API
class Identity {
  Identity._();

  static const MethodChannel _channel =
      const MethodChannel('mparticle_flutter_sdk');

  Future<IdentityApiResult> identify(
    IdentityRequest identityRequest,
  ) async {
    return await sendIdentityRequest(
        identityRequest.identities, _channel, 'identify');
  }

  Future<IdentityApiResult> login(
    IdentityRequest identityRequest,
  ) async {
    return await sendIdentityRequest(
        identityRequest.identities, _channel, 'login');
  }

  Future<IdentityApiResult> logout(
    IdentityRequest identityRequest,
  ) async {
    return await sendIdentityRequest(
        identityRequest.identities, _channel, 'logout');
  }

  Future<IdentityApiResult> modify(
    IdentityRequest identityRequest,
  ) async {
    return await sendIdentityRequest(
        identityRequest.identities, _channel, 'modify');
  }

  /// Transitions anonymous user to known user inside an `aliasRequest`
  ///
  /// See https://docs.mparticle.com/guides/idsync/aliasing/ for more information
  Future<void> aliasUsers(AliasRequest aliasRequest) async {
    var aliasRequestObj = {
      "sourceMpid": aliasRequest.sourceMpid,
      "destinationMpid": aliasRequest.destinationMpid,
      "startTime": aliasRequest.startTime,
      "endTime": aliasRequest.endTime
    };

    return await _channel
        .invokeMethod('aliasUsers', {'aliasRequest': aliasRequestObj});
  }
}
