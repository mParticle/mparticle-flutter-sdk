// This file provides the mappings between the Flutter API and the core mParticle JS SDK

import 'dart:async';
import 'dart:convert';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:js';
import 'package:mparticle_flutter_sdk/src/web_helpers/identity_helpers.dart'
    as webIdentityHelpers;
import 'package:mparticle_flutter_sdk/src/web_helpers/ecommerce_helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the MparticleFlutterSdk plugin.
class MparticleFlutterSdkWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'mparticle_flutter_sdk',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = MparticleFlutterSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    final mParticle = JsObject.fromBrowserObject(context['mParticle']);
    final mpIdentity =
        JsObject.fromBrowserObject(context['mParticle']['Identity']);
    final mpCommerce =
        JsObject.fromBrowserObject(context['mParticle']['eCommerce']);

    // Calls to the mParticle JS Identity methods are async, so we must await
    // a Future that contains a Completer. The Completer completes inside the JS callback
    // Await-ing this function will return the result from the identity calls, and
    // we return this up to the dart layer as a string.
    Future<String> sendIdentityCall(identityMethod, identityRequest) {
      const String PLATFORM = 'web';
      final completer = Completer<String>();
      String? mpid;
      List<Map<String, String?>>? errors;
      String? previousMpid;
      int? httpCode;

      mpIdentity.callMethod(identityMethod, [
        JsObject.jsify(identityRequest),
        // This callback must parse the httpCode, context, errors, previousMpid,
        // and mpid based on what httpCode is returned. If the httpCode is -1 through
        // -5, it is a client side error, and we format the errors array to include it
        // and set httpCode to null and the message is contained on the result['body'].
        // A 200 http code will have no errors, and all non-200 http codes have errors
        // on the result['body']['error'] object.
        (result) {
          httpCode = result['httpCode'];

          mpid = result?.callMethod('getUser')?.callMethod('getMPID');
          if (identityMethod == 'modify') {
            previousMpid = null;
          } else {
            previousMpid =
                result?.callMethod('getPreviousUser')?.callMethod('getMPID');
          }

          var identityResult = {
            "mpid": mpid,
            "http_code": httpCode,
            "platform": PLATFORM
          };

          switch (httpCode) {
            case 200:
              errors = null;
              identityResult['previous_mpid'] = previousMpid;
              break;
            case 400:
            case 401:
            case 429:
              errors =
                  webIdentityHelpers.convertJSErrorArraytoDartErrorList(result);
              break;
            case -1:
            case -2:
            case -3:
            case -4:
            case -5:
              // client side errors for -1 through -5 only have a single error
              errors = [
                {'code': httpCode.toString(), 'message': result['body']}
              ];
              httpCode = null;
              break;
            default:
              // if the http code is 5xx, error will be on result.body.errors
              if (httpCode != null && httpCode as int >= 500) {
                errors = result['body']['errors'];
              } else {
                print(
                    'The httpCode of $httpCode is not covered in the web implementation');
              }
          }

          if (errors != null) {
            identityResult['errors'] = errors;
          }

          completer.complete(jsonEncode(identityResult));
        }
      ]);

      return completer.future;
    }

    switch (call.method) {
      case 'isInitialized':
        try {
          return mParticle.callMethod('getInstance')['_Store']['isInitialized'];
        } catch (error, stackTrace) {
          throw PlatformException(
              code: 'Unimplemented',
              details:
                  'Double check your web API key. Unable to get mParticle initialization status.',
              message: 'StackTrace: $stackTrace');
        }

      case 'getAppName':
        return mParticle.callMethod('getAppName');
      case 'logError':
        mParticle.callMethod('logError', [
          call.arguments['eventName'],
          JsObject.jsify(call.arguments['customAttributes']),
        ]);
        break;
      case 'logEvent':
        mParticle.callMethod('logEvent', [
          call.arguments['eventName'],
          call.arguments['eventType'],
          JsObject.jsify(call.arguments['customAttributes']),
          JsObject.jsify(call.arguments['customFlags']),
        ]);
        break;
      case 'logScreenEvent':
        mParticle.callMethod('logPageView', [
          call.arguments['eventName'],
          JsObject.jsify(call.arguments['customAttributes']),
          JsObject.jsify(call.arguments['customFlags']),
        ]);
        break;
      case 'setOptOut':
        mParticle.callMethod('setOptOut', [call.arguments['optOutBoolean']]);
        break;
      //  upload is only required for batching, if a workspace is not set up for batching, it will send events as they come int
      //  to test this, either use a workspace on v3, or override your v3 flag settings as follows:
      //  window.mParticle.config.flags = {"eventsV3":"100","eventBatchingIntervalMillis":"50000"};
      //  simply set eventBatchingIntervalMillis to some arbitrarily large number to ensure you can queue enough events before calling upload
      case 'upload':
        mParticle.callMethod('upload');
        break;

      // user methods
      case 'getMPID':
        return mpIdentity.callMethod('getCurrentUser').callMethod('getMPID');

      case 'getUserAttributes':
        var jsAttributes = mpIdentity.callMethod('getUser',
            [call.arguments["mpid"]]).callMethod('getAllUserAttributes');

        return context['JSON'].callMethod('stringify', [jsAttributes]);

      case 'getUserIdentities':
        // Calling getUserIdentities in the JS SDK returns an object in the shape of:
        // { userIdentities: { customerid: 'customerid1', email: 'email@email.com' } }
        // We must convert this into a dart map with the shape of { 1: 'customerid1', 7: 'email@email.com' }
        // And then return this as a string to the dart layer.

        JsObject jsIdentities = mpIdentity.callMethod('getUser',
            [call.arguments["mpid"]]).callMethod('getUserIdentities');

        // A JsObject needs to be stringified using a web's JSON.stringify, and not jsonEncode
        // which only stringifies dart objects.
        String userIdentitiesString = context['JSON']
            .callMethod('stringify', [jsIdentities['userIdentities']]);

        // Decode the JSON to a dart map. In the example shape above, the keys are 'customerid' and 'email'
        var userIdentitiesMapKeyedByIdentityName =
            jsonDecode(userIdentitiesString);

        // Convert each key of Identity name string to its equivalent stringified Integer
        // In the example shape above, 'customerid' maps to '1', 'email' maps to 7.
        var userIdentitiesMapKeyedByStringifiedNumber = {};
        userIdentitiesMapKeyedByIdentityName.forEach((key, value) {
          userIdentitiesMapKeyedByStringifiedNumber[webIdentityHelpers
              .convertIdentityNameToStringifiedNumber(key)] = value;
        });

        // Return a stringified version of the new dart map
        return jsonEncode(userIdentitiesMapKeyedByStringifiedNumber);

      case 'setUserAttribute':
        mpIdentity.callMethod('getUser', [call.arguments["mpid"]]).callMethod(
            'setUserAttribute',
            [call.arguments["attributeKey"], call.arguments["attributeValue"]]);
        break;
      case 'setUserAttributeArray':
        mpIdentity.callMethod('getUser', [call.arguments["mpid"]]).callMethod(
            'setUserAttributeList', [
          call.arguments["attributeKey"],
          JsObject.jsify(call.arguments["attributeValue"])
        ]);
        break;
      case 'setUserTag':
        mpIdentity.callMethod('getUser', [call.arguments["mpid"]]).callMethod(
            'setUserTag', [call.arguments["attributeKey"]]);
        break;
      // identity methods:
      case 'identify':
        var identityRequest = webIdentityHelpers
            .createWebIdentityRequest(call.arguments['identityRequest']);

        var result = await sendIdentityCall('identify', identityRequest);
        return result;
      case 'login':
        var identityRequest = webIdentityHelpers
            .createWebIdentityRequest(call.arguments['identityRequest']);

        var result = await sendIdentityCall('login', identityRequest);
        return result;
      case 'logout':
        var identityRequest = webIdentityHelpers
            .createWebIdentityRequest(call.arguments['identityRequest']);

        var result = await sendIdentityCall('logout', identityRequest);
        return result;
      case 'modify':
        var identityRequest = webIdentityHelpers
            .createWebIdentityRequest(call.arguments['identityRequest']);

        var result = await sendIdentityCall('modify', identityRequest);
        return result;
      case 'aliasUsers':
        var jsAliasRequest = call.arguments["aliasRequest"];
        // If both startTime and endTime exist, then we have a valid aliasRequest
        // and we call aliasUsers
        if (jsAliasRequest['startTime'] != null &&
            jsAliasRequest['endTime'] != null) {
          mpIdentity.callMethod('aliasUsers', [JsObject.jsify(jsAliasRequest)]);
        } else if (jsAliasRequest['startTime'] == null &&
            jsAliasRequest['endTime'] == null) {
          var createdAliasRequest = webIdentityHelpers.createAliasRequest(
              jsAliasRequest, mParticle, mpIdentity);
          // If neither startTime nor endTime exist, we must generate them using
          // the JS SDK
          mpIdentity
              .callMethod('aliasUsers', [JsObject.jsify(createdAliasRequest)]);
        } else {
          print(
              'You included only a startTime or an endTime, but not both. Please include BOTH a startTime and an endTime, or let mParticle calculate both for you');
        }
        break;
      case 'logCommerceEvent':
        var commerceEvent = call.arguments['commerceEvent'];
        int? productActionType = commerceEvent['productActionType'];

        // Web has Enums which start with Unknown, so we must increment by 1 since Dart enums start with AddToCart
        // https://github.com/mParticle/mparticle-web-sdk/blob/master/src/types.js#L256
        if (productActionType != null) {
          productActionType =
              convertProductActionTypeIndexToJSProductActionType(
                  productActionType, mParticle['ProductActionType']);
        }

        int? promotionActionType = commerceEvent['promotionActionType'];
        if (promotionActionType != null) {
          promotionActionType =
              convertPromotionActionTypeIndexToJSPromotionAction(
                  promotionActionType, mParticle["PromotionType"]);
        }
        List? rawProducts = commerceEvent['products'];
        List? products = [];

        Map<String, dynamic>? customAttributes =
            commerceEvent['customAttributes'];
        if (customAttributes == null) {
          customAttributes = {};
        }
        Map<String, dynamic>? customFlags = commerceEvent['customFlags'];

        if (customFlags == null) {
          customFlags = {};
        }

        String? currency = commerceEvent['currency'];
        if (currency != null) {
          mpCommerce.callMethod('setCurrencyCode', [currency]);
        }

        var checkoutStep = commerceEvent['checkoutStep'];
        var checkoutOptions = commerceEvent['checkoutOptions'];
        var transactionAttributes = commerceEvent['transactionAttributes'];
        if (checkoutStep != null) {
          transactionAttributes['Step'] = checkoutStep;
        }

        if (checkoutOptions != null) {
          transactionAttributes['Option'] = checkoutOptions;
        }

        if (rawProducts != null && rawProducts.length > 0) {
          rawProducts.forEach((rawProduct) {
            var product = mpCommerce.callMethod('createProduct', [
              rawProduct['name'],
              rawProduct['quantity'],
              rawProduct['price']
            ]);
            products.add(product);
          });
        }
        // log product action
        if (productActionType != null) {
          mpCommerce.callMethod('logProductAction', [
            productActionType,
            JsObject.jsify(products),
            JsObject.jsify(customAttributes),
            JsObject.jsify(customFlags),
            JsObject.jsify(transactionAttributes)
          ]);
          return true;
          // log promotion
        } else if (promotionActionType != null) {
          List? rawPromotions = commerceEvent["promotions"];
          List? promotions = [];

          if (rawPromotions != null && rawPromotions.length > 0) {
            rawPromotions.forEach((rawPromotion) {
              var promotion = mpCommerce.callMethod('createPromotion', [
                rawPromotion['promotionId'],
                rawPromotion['creative'],
                rawPromotion['name'],
                rawPromotion['position'],
              ]);
              promotions.add(promotion);
            });
          }

          mpCommerce.callMethod('logPromotion',
              [promotionActionType, JsObject.jsify(promotions)]);

          return true;
          // log impression
        } else {
          List? rawImpressions = commerceEvent["impressions"];
          List? impressions = [];

          if (rawImpressions != null && rawImpressions.length > 0) {
            rawImpressions.forEach((rawImpression) {
              List impressionProducts = [];
              var rawImpressionProducts = rawImpression['products'];

              if (rawImpressionProducts != null &&
                  rawImpressionProducts.length > 0) {
                rawImpressionProducts.forEach((rawImpressionProduct) {
                  var product = mpCommerce.callMethod('createProduct', [
                    rawImpressionProduct['name'],
                    rawImpressionProduct['quantity'],
                    rawImpressionProduct['price']
                  ]);
                  impressionProducts.add(product);
                });
              }
              var impression = mpCommerce.callMethod('createImpression', [
                rawImpression['impressionListName'],
                JsObject.jsify(impressionProducts)
              ]);
              impressions.add(impression);
            });
          }

          mpCommerce.callMethod('logImpression', [JsObject.jsify(impressions)]);
        }

        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'mParticle Flutter SDK for Web does not support \'${call.method}\'',
        );
    }
  }
}
