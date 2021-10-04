import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mparticle_flutter_sdk/mparticle_flutter_sdk.dart';
import 'package:mparticle_flutter_sdk/events/event_type.dart';
import 'package:mparticle_flutter_sdk/events/commerce_event.dart';
import 'package:mparticle_flutter_sdk/events/product_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion_action_type.dart';
import 'package:mparticle_flutter_sdk/events/promotion.dart';
import 'package:mparticle_flutter_sdk/events/product.dart';
import 'package:mparticle_flutter_sdk/events/impression.dart';
import 'package:mparticle_flutter_sdk/events/screen_event.dart';
import 'package:mparticle_flutter_sdk/events/mp_event.dart';
import 'package:mparticle_flutter_sdk/events/transaction_attributes.dart';
import 'package:mparticle_flutter_sdk/identity/identity_type.dart';
import 'package:mparticle_flutter_sdk/kits/kits.dart';
import 'package:mparticle_flutter_sdk/identity/alias_request.dart';
import 'package:mparticle_flutter_sdk/identity/identity_api_result.dart';
import 'package:mparticle_flutter_sdk/identity/identity_api_error_response.dart';
import 'package:mparticle_flutter_sdk/identity/client_error_codes.dart';
import 'package:mparticle_flutter_sdk/apple/authorization_status.dart';
import 'package:mparticle_flutter_sdk/consent/consent.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final myController = TextEditingController();

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  TextButton buildButton(text, onPressedFunction) {
    return TextButton(
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.green,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        onPressed: () {
          onPressedFunction();
        });
  }

  @override
  void initState() {
    super.initState();
    initMparticle();
  }

  MparticleFlutterSdk? mpInstance;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initMparticle() async {
    mpInstance = await MparticleFlutterSdk.getInstance();
    if (mpInstance != null) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void identityCallbackSuccess(IdentityApiResult successResponse) {
    print("Success Response: $successResponse");
  }

  void identityCallbackFailure(error) {
    var failureResponse = error as IdentityAPIErrorResponse;
    print("Failure Response: $failureResponse");
    if (failureResponse.clientErrorCode != null) {
      switch (failureResponse.clientErrorCode) {
        case IdentityClientErrorCodes.RequestInProgress:
        default:
          print(failureResponse.clientErrorCode);
          failureResponse.errors
              .forEach((error) => print('${error.code}\n${error.message}'));
      }
    }
    int? httpCode = failureResponse.httpCode;
    if (httpCode != null && httpCode > 400) {
      switch (httpCode) {
        case 400:
        case 401:
        case 429:
        case 529:
        default:
          failureResponse.errors.forEach((error) => print(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Center(
              child: Text('mParticle is initialized: $_isInitialized\n'),
            ),
            Center(
              child: Text('EVENT LOGGING'),
            ),
            buildButton('Log Event', () {
              MPEvent event = MPEvent(
                  eventName: 'Test event logged',
                  eventType: EventType.Navigation,
                  customAttributes: {'key1': 'value1'},
                  customFlags: {'flag1': 'flagValue1'});
              mpInstance?.logEvent(event);
            }),
            buildButton('Log Event - No Upload', () {
              MPEvent event = MPEvent(
                  eventName: 'Test event logged',
                  eventType: EventType.Navigation,
                  customAttributes: {'key1': 'value1'},
                  customFlags: {'flag1': 'flagValue1'})
                ..shouldUploadEvent = false;
              mpInstance?.logEvent(event);
            }),
            buildButton('Log Screen Event', () {
              ScreenEvent screenEvent =
                  ScreenEvent(eventName: 'Screen event logged')
                    ..customAttributes = {'key1': 'value1'}
                    ..customFlags = {'flag1': 'flagValue1'};
              mpInstance?.logScreenEvent(screenEvent);
            }),
            buildButton('Log Commerce - Product', () {
              final Product product1 = Product(
                  name: 'Orange', sku: '123abc', price: 2.4, quantity: 1);
              final Product product2 = Product(
                  name: 'Apple',
                  sku: '456abc',
                  price: 4.1,
                  quantity: 2,
                  variant: 'variant',
                  category: 'category',
                  brand: 'brand',
                  position: 1,
                  couponCode: 'couponCode',
                  attributes: {'key1': 'value1'});
              final TransactionAttributes transactionAttributes =
                  TransactionAttributes(
                      transactionId: '123456',
                      affiliation: 'affiliation',
                      couponCode: '12412342',
                      shipping: 1.34,
                      tax: 43.23,
                      revenue: 242.23);
              CommerceEvent commerceEvent = CommerceEvent.withProduct(
                  productActionType: ProductActionType.Purchase,
                  product: product1)
                ..products.add(product2)
                ..transactionAttributes = transactionAttributes
                ..currency = 'US'
                ..screenName = 'One Click Purchase'
                ..customAttributes = {"foo": "bar", "fuzz": "baz"}
                ..customFlags = {
                  "flag1": "val1",
                  "flag2": ["val2", "val3"]
                };
              mpInstance?.logCommerceEvent(commerceEvent);
            }),
            buildButton('Log Commerce - Promotion', () {
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
                  promotionActionType: PromotionActionType.View,
                  promotion: promotion1)
                ..promotions.add(promotion2)
                ..currency = 'US'
                ..screenName = 'PromotionScreen'
                ..customAttributes = {"foo": "bar", "fuzz": "baz"}
                ..customFlags = {
                  "flag1": "val1",
                  "flag2": ["val2", "val3"]
                };
              mpInstance?.logCommerceEvent(commerceEvent);
            }),
            buildButton('Log Commerce - Impression', () {
              final Product product1 = Product(
                  name: 'Orange', sku: '123abc', price: 2.4, quantity: 1);
              final Product product2 = Product(
                  name: 'Apple',
                  sku: '456abc',
                  price: 4.1,
                  quantity: 2,
                  variant: 'variant',
                  category: 'category',
                  brand: 'brand',
                  position: 1,
                  couponCode: 'couponCode',
                  attributes: {'key1': 'value1'});
              final Impression impression1 = Impression(
                  impressionListName: 'produce',
                  products: [product1, product2]);
              final Impression impression2 = Impression(
                  impressionListName: 'citrus', products: [product1]);
              CommerceEvent commerceEvent =
                  CommerceEvent.withImpression(impression: impression1)
                    ..impressions.add(impression2)
                    ..currency = 'US'
                    ..screenName = 'ImpressionScreen'
                    ..customAttributes = {"foo": "bar", "fuzz": "baz"}
                    ..customFlags = {
                      "flag1": "val1",
                      "flag2": ["val2", "val3"]
                    };
              mpInstance?.logCommerceEvent(commerceEvent);
            }),
            buildButton('Log Commerce - No Upload', () {
              final Product product1 = Product(
                  name: 'Orange', sku: '123abc', price: 2.4, quantity: 1);
              final Product product2 = Product(
                  name: 'Apple', sku: '456abc', price: 4.1, quantity: 2);
              final TransactionAttributes transactionAttributes =
                  TransactionAttributes(
                      transactionId: '123456',
                      affiliation: 'affiliation',
                      couponCode: '12412342',
                      shipping: 1.34,
                      tax: 43.23,
                      revenue: 242.23);
              CommerceEvent commerceEvent = CommerceEvent.withProduct(
                  productActionType: ProductActionType.Purchase,
                  product: product1)
                ..products.add(product2)
                ..transactionAttributes = transactionAttributes
                ..currency = 'US'
                ..screenName = 'One Click Purchase'
                ..customAttributes = {"foo": "bar", "fuzz": "baz"}
                ..customFlags = {
                  "flag1": "val1",
                  "flag2": ["val2", "val3"]
                }
                ..shouldUploadEvent = false;
              mpInstance?.logCommerceEvent(commerceEvent);
            }),
            buildButton('Log Error', () {
              mpInstance?.logError(
                  eventName: 'Error event logged',
                  customAttributes: {'errorKey': 'errorValue'});
            }),
            buildButton('Get Attributions', () async {
              var attributions = await mpInstance?.getAttributions();
              print('Number of Attributions');
              print(attributions?.length);
              attributions?.forEach((key, value) {
                print('key');
                print(key);
                print('value');
                print(value);
              });
            }),
            buildButton('Set opt out', () {
              mpInstance?.setOptOut(true);
            }),
            buildButton('Set Opt In', () {
              mpInstance?.setOptOut(false);
            }),
            buildButton('Get opt out', () async {
              print(await mpInstance?.getOptOut);
            }),
            buildButton('Upload', () {
              mpInstance?.upload();
            }),
            Center(
              child: Text('IDENTITY'),
            ),
            buildButton('Identify', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(
                      identityType: IdentityType.CustomerId,
                      value: 'customerid')
                  .setIdentity(
                      identityType: IdentityType.Email,
                      value: 'email@gmail.com');

              mpInstance?.identity.identify(identityRequest).then(
                  identityCallbackSuccess,
                  onError: identityCallbackFailure);
            }),
            buildButton('Login', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(
                      identityType: IdentityType.CustomerId,
                      value: 'customerid2')
                  .setIdentity(
                      identityType: IdentityType.Email,
                      value: 'email2@gmail.com');
              mpInstance?.identity.login(identityRequest).then(
                  identityCallbackSuccess,
                  onError: identityCallbackFailure);
            }),
            buildButton('Modify', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(
                      identityType: IdentityType.CustomerId,
                      value: 'customerid3')
                  .setIdentity(
                      identityType: IdentityType.Email,
                      value: 'email3@gmail.com');
              mpInstance?.identity.modify(identityRequest).then(
                  identityCallbackSuccess,
                  onError: identityCallbackFailure);
            }),
            buildButton('Logout', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              // Depending on your Identity strategy, an identityRequest with
              // identities passed to logout may result in a server error.
              // To remove this error, comment the next 3 lines out where identities
              // are set on the identityRequest.
              identityRequest
                  .setIdentity(
                      identityType: IdentityType.CustomerId,
                      value: 'customerid4')
                  .setIdentity(
                      identityType: IdentityType.Email,
                      value: 'email4@gmail.com');

              mpInstance?.identity.logout(identityRequest).then(
                  identityCallbackSuccess,
                  onError: identityCallbackFailure);
            }),
            buildButton('Alias Users with MPIDs and Times', () {
              var startTime = DateTime.now().millisecondsSinceEpoch - 60000;
              var endTime = DateTime.now().millisecondsSinceEpoch;

              var userAliasRequest = AliasRequest(
                  sourceMpid: 'sourceMPID', destinationMpid: 'destinationMPID');
              userAliasRequest.setStartTime(startTime);
              userAliasRequest.setEndTime(endTime);
              mpInstance?.identity.aliasUsers(userAliasRequest);
            }),
            buildButton('Login then Alias Users with just MPIDs', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(
                      identityType: IdentityType.CustomerId,
                      value: 'customerid5')
                  .setIdentity(
                      identityType: IdentityType.Email,
                      value: 'email5@gmail.com');
              mpInstance?.identity.login(identityRequest).then(
                  (IdentityApiResult successResponse) {
                String? previousMPID = successResponse.previousUser?.getMPID();
                if (previousMPID != null) {
                  var userAliasRequest = AliasRequest(
                      sourceMpid: previousMPID,
                      destinationMpid: successResponse.user.getMPID());
                  mpInstance?.identity.aliasUsers(userAliasRequest);
                }
              }, onError: (error) {
                var failureResponse = error as IdentityAPIErrorResponse;
                print("Failure Response: $failureResponse");
              });
            }),
            Center(
              child: Text('USER'),
            ),
            buildButton('getCurrentUser', () async {
              var user = await mpInstance?.getCurrentUser();
              print(user?.getMPID());
            }),
            buildButton('setUserAttribute', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.setUserAttribute(key: 'points', value: '1');
            }),
            buildButton('Set User Tag', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.setUserTag(tag: 'tag1');
            }),
            buildButton('Set User Attribute Array', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.setUserAttributeArray(
                  key: 'arrayOfStrings', value: ['a', 'b', 'c']);
            }),
            buildButton('Get User Attributes', () async {
              var user = await mpInstance?.getCurrentUser();
              var attributes = await user?.getUserAttributes();
              attributes?.forEach((key, value) {
                print('key');
                print(key);
                print('value');
                print(value);
              });
            }),
            buildButton('Get User Identities', () async {
              var user = await mpInstance?.getCurrentUser();
              print(user?.getMPID());
              user?.getUserIdentities().then((userIdentities) {
                userIdentities.forEach((key, value) {
                  print('key');
                  print(key);
                  print('value');
                  print(value);
                });
              });
            }),
            Center(
              child: Text('NATIVE ONLY METHODS'),
            ),
            buildButton('is Braze kit active?', () async {
              print(await mpInstance?.isKitActive(kit: Kits['Braze']!));
            }),
            buildButton('Get opt out', () async {
              print(await mpInstance?.getOptOut);
            }),
            buildButton('incrementUserAttribute by 1', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.incrementUserAttribute(key: 'points', value: 1);
            }),
            buildButton('logPushNotification', () async {
              mpInstance?.logPushRegistration(
                  pushToken: 'pushToken123', senderId: 'senderId123');
            }),
            buildButton('user - getFirstSeen time', () async {
              var user = await mpInstance?.getCurrentUser();
              int? time = await user?.getFirstSeen();
              if (time != null) {
                print(time);
              }
            }),
            buildButton('user - getLastSeen time', () async {
              var user = await mpInstance?.getCurrentUser();
              int? time = await user?.getLastSeen();
              if (time != null) {
                print(time);
              }
            }),
            buildButton('user - get GDPR Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              var gdprConsent = await user?.getGDPRConsentState();
              gdprConsent?.forEach((key, value) {
                print('purpose');
                print(key);
                print('GDPR Consent Object');
                print('Consented');
                print(value.consented);
                if (value.timestamp != null) {
                  print('Timestamp');
                  print(value.timestamp);
                }
                print('Document');
                print(value.document);
                print('Hardware ID');
                print(value.hardwareId);
                print('Location');
                print(value.location);
              });
            }),
            buildButton('user - add denied GDPR Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              var gdprConsent = (Consent(consented: false))
                ..document = 'document test'
                ..hardwareId = 'hardwareID'
                ..location = 'loction test'
                ..timestamp = DateTime.now().millisecondsSinceEpoch;
              user?.addGDPRConsentState(consent: gdprConsent, purpose: 'test');
            }),
            buildButton('user - add 2nd approved GDPR Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              var gdprConsent = Consent(consented: true);
              user?.addGDPRConsentState(
                  consent: gdprConsent, purpose: 'test 2');
            }),
            buildButton('user - remove GDPR Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.removeGDPRConsentState(purpose: 'test');
            }),
            buildButton('user - get CCPA Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              var ccpaConsent = await user?.getCCPAConsentState();
              if (ccpaConsent != null) {
                print('CCPA Consent Object');
                print('Consented');
                print(ccpaConsent.consented);
                if (ccpaConsent.timestamp != null) {
                  print('Timestamp');
                  print(ccpaConsent.timestamp);
                }
                print('Document');
                print(ccpaConsent.document);
                print('Hardware ID');
                print(ccpaConsent.hardwareId);
                print('Location');
                print(ccpaConsent.location);
              } else {
                print('No CCPA Consent Set');
              }
            }),
            buildButton('user - add denied CCPA Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              var ccpaConsent = (Consent(consented: false))
                ..document = 'document test'
                ..hardwareId = 'hardwareID'
                ..location = 'loction test'
                ..timestamp = DateTime.now().millisecondsSinceEpoch;
              user?.addCCPAConsentState(consent: ccpaConsent);
            }),
            buildButton('user - add approved CCPA Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              var ccpaConsent = Consent(consented: true);
              user?.addCCPAConsentState(consent: ccpaConsent);
            }),
            buildButton('user - remove CCPA Consent State', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.removeCCPAConsentState();
            }),
            buildButton('set att status', () async {
              mpInstance?.setATTStatus(
                  attStatus: MPATTAuthorizationStatus.Authorized);
            }),
          ],
        ),
      ),
    );
  }
}
