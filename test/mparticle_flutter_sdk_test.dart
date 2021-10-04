import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mparticle_flutter_sdk/mparticle_flutter_sdk.dart';
import 'package:mparticle_flutter_sdk/events/event_type.dart';
import 'package:mparticle_flutter_sdk/events/mp_event.dart';
import 'package:mparticle_flutter_sdk/events/commerce_event.dart';
import 'package:mparticle_flutter_sdk/events/product.dart';
import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/transaction_attributes.dart';
import 'package:mparticle_flutter_sdk/events/promotion.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';
import 'package:mparticle_flutter_sdk/events/impression.dart';
import 'package:mparticle_flutter_sdk/events/screen_event.dart';
import 'package:mparticle_flutter_sdk/identity/alias_request.dart';
import 'package:mparticle_flutter_sdk/apple/authorization_status.dart';

void main() {
  const MethodChannel channel = MethodChannel('mparticle_flutter_sdk');
  MethodCall? methodCall;
  TestWidgetsFlutterBinding.ensureInitialized();

  MparticleFlutterSdk mp = MparticleFlutterSdk();

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall call) async {
      methodCall = call;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    methodCall = null;
  });

  group('mParticle Dart API Layer', () {
    test('logEvent', () async {
      MPEvent event =
          MPEvent(eventName: 'Clicked Search Bar', eventType: EventType.Search)
            ..customAttributes = {'key1': 'value1'}
            ..customFlags = {'flag1': 'value1'};

      await mp.logEvent(event);
      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: {
            'eventName': 'Clicked Search Bar',
            'eventType': 3,
            'customAttributes': {'key1': 'value1'},
            'customFlags': {'flag1': 'value1'},
            'shouldUploadEvent': null
          },
        ),
      );
    });

    test('log product action commerce event', () async {
      final Product product1 =
          Product(name: 'Orange', sku: '123abc', price: 5.0, quantity: 1);
      final Product product2 =
          Product(name: 'Apple', sku: '456abc', price: 10.5, quantity: 2);
      final TransactionAttributes transactionAttributes = TransactionAttributes(
          transactionId: '123456',
          affiliation: 'affiliation',
          couponCode: '12412342',
          shipping: 1.34,
          tax: 43.232,
          revenue: 242.2);
      CommerceEvent commerceEvent = CommerceEvent.withProduct(
          productActionType: ProductActionType.Purchase, product: product1)
        ..products.add(product2)
        ..transactionAttributes = transactionAttributes
        ..currency = 'US'
        ..screenName = 'One Click Purchase';
      mp.logCommerceEvent(commerceEvent);
      expect(
        methodCall,
        isMethodCall(
          'logCommerceEvent',
          arguments: {
            'commerceEvent': {
              'products': [product1.toJson(), product2.toJson()],
              'promotions': [],
              'impressions': [],
              'transactionAttributes': transactionAttributes.toJson(),
              'checkoutOptions': null,
              'currency': 'US',
              'productListName': null,
              'productListSource': null,
              'screenName': 'One Click Purchase',
              'checkoutStep': null,
              'nonInteractive': null,
              'shouldUploadEvent': null,
              'customAttributes': null,
              'customFlags': null,
              'productActionType': 8,
              'jsProductActionType': 6,
              'androidProductActionType': 'purchase',
            }
          },
        ),
      );
    });

    test('log promotion commerce event', () async {
      final Promotion promotion1 = Promotion(
          promotionId: '12312',
          creative: 'Jennifer Slater',
          name: 'BOGO Bonanza',
          position: 'top');
      final Promotion promotion2 = Promotion(
          promotionId: '15632',
          creative: 'Gregor Roman',
          name: 'Eco Living',
          position: 'mid');

      CommerceEvent commerceEvent = CommerceEvent.withPromotion(
          promotionActionType: PromotionActionType.View, promotion: promotion1)
        ..promotions.add(promotion2)
        ..currency = 'US'
        ..screenName = 'Promotion Screen Name';
      mp.logCommerceEvent(commerceEvent);
      expect(
        methodCall,
        isMethodCall(
          'logCommerceEvent',
          arguments: {
            'commerceEvent': {
              'products': [],
              'promotions': [
                {
                  'promotionId': '12312',
                  'creative': 'Jennifer Slater',
                  'name': 'BOGO Bonanza',
                  'position': 'top'
                },
                {
                  'promotionId': '15632',
                  'creative': 'Gregor Roman',
                  'name': 'Eco Living',
                  'position': 'mid'
                }
              ],
              'impressions': [],
              'transactionAttributes': null,
              'checkoutOptions': null,
              'currency': 'US',
              'productListName': null,
              'productListSource': null,
              'screenName': 'Promotion Screen Name',
              'checkoutStep': null,
              'nonInteractive': null,
              'shouldUploadEvent': null,
              'customAttributes': null,
              'customFlags': null,
              'promotionActionType': 1,
              'androidPromotionActionType': 'view',
              'jsPromotionActionType': 1
            }
          },
        ),
      );
    });

    test('log impression commerce event', () async {
      final Product product1 =
          Product(name: 'Orange', sku: '123abc', price: 2.4, quantity: 1);
      final Impression impression1 =
          Impression(impressionListName: 'produce', products: [product1]);
      final Impression impression2 =
          Impression(impressionListName: 'citrus', products: [product1]);
      CommerceEvent commerceEvent =
          CommerceEvent.withImpression(impression: impression1)
            ..impressions.add(impression2)
            ..currency = 'US'
            ..screenName = 'One Click Purchase';
      mp.logCommerceEvent(commerceEvent);
      expect(
        methodCall,
        isMethodCall(
          'logCommerceEvent',
          arguments: {
            'commerceEvent': {
              'products': [],
              'promotions': [],
              'impressions': [impression1.toJson(), impression2.toJson()],
              'transactionAttributes': null,
              'checkoutOptions': null,
              'currency': 'US',
              'productListName': null,
              'productListSource': null,
              'screenName': 'One Click Purchase',
              'checkoutStep': null,
              'nonInteractive': null,
              'shouldUploadEvent': null,
              'customAttributes': null,
              'customFlags': null,
            }
          },
        ),
      );
    });

    test('log error', () async {
      mp.logError(eventName: 'Error', customAttributes: {'key1': 'value1'});

      expect(
        methodCall,
        isMethodCall('logError', arguments: {
          'eventName': 'Error',
          'customAttributes': {'key1': 'value1'},
        }),
      );
    });

    test('log push registration', () async {
      mp.logPushRegistration(
          pushToken: 'pushToken123', senderId: 'senderId123');

      expect(
        methodCall,
        isMethodCall('logPushRegistration', arguments: {
          'pushToken': 'pushToken123',
          'senderId': 'senderId123',
        }),
      );
    });

    test('log screen event', () async {
      ScreenEvent screenEvent = ScreenEvent(eventName: 'Screen event logged')
        ..customAttributes = {'key1': 'value1'}
        ..customFlags = {'flag1': 'value1'};
      mp.logScreenEvent(screenEvent);

      expect(
        methodCall,
        isMethodCall('logScreenEvent', arguments: {
          'eventName': 'Screen event logged',
          'customAttributes': {'key1': 'value1'},
          'customFlags': {'flag1': 'value1'},
        }),
      );
    });

    test('set att status', () async {
      mp.setATTStatus(
          attStatus: MPATTAuthorizationStatus.Authorized,
          timestampInMillis: 1000);
      expect(
        methodCall,
        isMethodCall('setATTStatus',
            arguments: {'attStatus': 3, 'timestampInMillis': 1000}),
      );
    });

    test('set opt out', () async {
      mp.setOptOut(true);
      expect(
        methodCall,
        isMethodCall('setOptOut', arguments: {'optOutBoolean': true}),
      );
    });

    test('upload', () async {
      mp.upload();
      expect(
        methodCall,
        isMethodCall('upload', arguments: null),
      );
    });

    test('alias users', () async {
      var userAliasRequest = AliasRequest(
          sourceMpid: 'sourceMPID', destinationMpid: 'destinationMPID');
      userAliasRequest.setStartTime(123);
      userAliasRequest.setEndTime(456);
      mp.identity.aliasUsers(userAliasRequest);
      expect(
        methodCall,
        isMethodCall('aliasUsers', arguments: {
          "aliasRequest": {
            'sourceMpid': 'sourceMPID',
            'destinationMpid': 'destinationMPID',
            'startTime': 123,
            'endTime': 456,
          }
        }),
      );
    });
  });
}
