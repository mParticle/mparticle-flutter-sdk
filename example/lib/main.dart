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
              MPEvent event = MPEvent('Test event logged', EventType.Navigation)
                ..customAttributes = {'key1': 'value1'}
                ..customFlags = {'flag1': 'flagValue1'};
              mpInstance?.logEvent(event);
            }),
            buildButton('Log Screen Event', () {
              ScreenEvent screenEvent = ScreenEvent('Screen event logged')
                ..customAttributes = {'key1': 'value1'}
                ..customFlags = {'flag1': 'flagValue1'};
              mpInstance?.logScreenEvent(screenEvent);
            }),
            buildButton('Log Commerce - Product', () {
              final Product product1 = Product('Orange', '123abc', 2.4, 1);
              final Product product2 = Product('Apple', '456abc', 4.1, 2);
              final TransactionAttributes transactionAttributes =
                  TransactionAttributes('123456', 'affiliation', '12412342',
                      1.34, 43.232, 242.2323);
              CommerceEvent commerceEvent = CommerceEvent.withProduct(ProductActionType.Purchase, product1)
                ..products.add(product2)
                ..transactionAttributes = transactionAttributes
                ..currency = 'US'
                ..screenName = 'One Click Purchase';
              mpInstance?.logCommerceEvent(commerceEvent);
            }),
            buildButton('Log Commerce - Promotion', () {
              final Promotion promotion1 =
                  Promotion('12312', 'Jennifer Slater', 'BOGO Bonanza', 'top');
              final Promotion promotion2 =
                  Promotion('15632', 'Gregor Roman', 'Eco Living', 'mid');

              CommerceEvent commerceEvent = CommerceEvent.withPromotion(PromotionActionType.View, promotion1)
                ..promotions.add(promotion2)
                ..currency = 'US'
                ..screenName = 'OneClickPurchase';
              mpInstance?.logCommerceEvent(commerceEvent);
            }),
            buildButton('Log Commerce - Impression', () {
              final Product product1 = Product('Orange', '123abc', 2.4, 1);
              final Product product2 = Product('Apple', '456abc', 4.1, 2);
              final Impression impression1 =
                  Impression('produce', [product1, product2]);
              final Impression impression2 = Impression('citrus', [product1]);
              CommerceEvent commerceEvent = CommerceEvent.withImpression(impression1)
                  ..impressions.add(impression2)
                  ..currency = 'US'
                  ..screenName = 'One Click Purchase';
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
              mpInstance?.setOptOut(optOutBoolean: true);
            }),
            buildButton('Set Opt In', () {
              mpInstance?.setOptOut(optOutBoolean: false);
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
                  .setIdentity(IdentityType.CustomerId, 'customerid')
                  .setIdentity(IdentityType.Email, 'email@gmail.com');

              mpInstance?.identity
                  .identify(identityRequest: identityRequest)
                  .then(identityCallbackSuccess,
                      onError: identityCallbackFailure);
            }),
            buildButton('Login', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(IdentityType.CustomerId, 'customerid2')
                  .setIdentity(IdentityType.Email, 'email2@gmail.com');
              mpInstance?.identity.login(identityRequest: identityRequest).then(
                  identityCallbackSuccess,
                  onError: identityCallbackFailure);
            }),
            buildButton('Modify', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(IdentityType.CustomerId, 'customerid3')
                  .setIdentity(IdentityType.Email, 'email3@gmail.com');
              mpInstance?.identity
                  .modify(identityRequest: identityRequest)
                  .then(identityCallbackSuccess,
                      onError: identityCallbackFailure);
            }),
            buildButton('Logout', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              // Depending on your Identity strategy, an identityRequest with
              // identities passed to logout may result in a server error.
              // To remove this error, comment the next 3 lines out where identities
              // are set on the identityRequest.
              identityRequest
                  .setIdentity(IdentityType.CustomerId, 'customerid4')
                  .setIdentity(IdentityType.Email, 'email4@gmail.com');

              mpInstance?.identity
                  .logout(identityRequest: identityRequest)
                  .then(identityCallbackSuccess,
                      onError: identityCallbackFailure);
            }),
            buildButton('Alias Users with MPIDs and Times', () {
              var startTime = DateTime.now().millisecondsSinceEpoch - 60000;
              var endTime = DateTime.now().millisecondsSinceEpoch;

              var userAliasRequest =
                  AliasRequest('sourceMPID', 'destinationMPID');
              userAliasRequest.setStartTime(startTime);
              userAliasRequest.setEndTime(endTime);
              mpInstance?.identity.aliasUsers(aliasRequest: userAliasRequest);
            }),
            buildButton('Login then Alias Users with just MPIDs', () {
              var identityRequest = MparticleFlutterSdk.identityRequest;
              identityRequest
                  .setIdentity(IdentityType.CustomerId, 'customerid5')
                  .setIdentity(IdentityType.Email, 'email5@gmail.com');
              mpInstance?.identity.login(identityRequest: identityRequest).then(
                  (IdentityApiResult successResponse) {
                String? previousMPID = successResponse.previousUser?.getMPID();
                if (previousMPID != null) {
                  var userAliasRequest = AliasRequest(
                      previousMPID, successResponse.user.getMPID());
                  mpInstance?.identity
                      .aliasUsers(aliasRequest: userAliasRequest);
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
              user?.setUserAttribute('points', '1');
            }),
            buildButton('Set User Tag', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.setUserTag('tag1');
            }),
            buildButton('Set User Attribute Array', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.setUserAttributeArray('arrayOfStrings', ['a', 'b', 'c']);
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
              user?.incrementUserAttribute('points', 1);
            }),
            buildButton('logPushNotification', () async {
              mpInstance?.logPushRegistration(
                  pushToken: 'pushToken123', senderId: 'senderId123');
            }),
            buildButton('user - getFirstSeen time', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.getFirstSeen((time) {
                print(time);
              });
            }),
            buildButton('user - getLastSeen time', () async {
              var user = await mpInstance?.getCurrentUser();
              user?.getLastSeen((time) {
                print(time);
              });
            }),
          ],
        ),
      ),
    );
  }
}
