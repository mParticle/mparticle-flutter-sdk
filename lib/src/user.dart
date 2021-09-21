import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mparticle_flutter_sdk/identity/identity_type.dart';
import 'package:mparticle_flutter_sdk/src/identity/identity_helpers.dart';
import 'package:mparticle_flutter_sdk/consent/gdpr_consent.dart';
import 'package:mparticle_flutter_sdk/consent/ccpa_consent.dart';

/// Returns a user given an [mpid].
class User {
  static const MethodChannel _channel =
      const MethodChannel('mparticle_flutter_sdk');

  String mpid;
  User(this.mpid);

  String getMPID() {
    return this.mpid;
  }

  /// Returns the first time a user has been seen on the device.
  void getFirstSeen(callback) async {
    String firstSeenTime =
        await _channel.invokeMethod('getFirstSeen', {"mpid": this.mpid});

    callback(firstSeenTime);
  }

  /// Returns the last time a user has been seen on the device.
  void getLastSeen(callback) async {
    String lastSeenTime =
        await _channel.invokeMethod('getLastSeen', {"mpid": this.mpid});

    callback(lastSeenTime);
  }

  /// Returns all user attributes.
  Future<Map> getUserAttributes() async {
    String userAttributesString =
        await _channel.invokeMethod('getUserAttributes', {"mpid": this.mpid});
    Map userAttributesMap = jsonDecode(userAttributesString);
    return userAttributesMap;
  }

  /// Returns all user identities.
  Future<Map> getUserIdentities() async {
    // Calls from the native/web platforms will return a String representation
    // of a Map<String, String> where the keys are stringified IdentityTypes ('1', '2', '3', etc)
    // These need to be converted into Enums to be sent back to the user.
    String userIdentitiesString =
        await _channel.invokeMethod('getUserIdentities', {"mpid": this.mpid});

    // convert from a string based off keys of '1' to Enums
    Map<IdentityType, String> userIdentitiesKeyedByEnum =
        convertIdentityStringToEnumMap(userIdentitiesString);

    return userIdentitiesKeyedByEnum;
  }

  /// Increments a user attribute
  ///
  /// Increments a user attribute given a [key] by a given [value].
  void incrementUserAttribute(String key, int value) async {
    await _channel.invokeMethod('incrementUserAttribute',
        {"attributeKey": key, "attributeValue": value, "mpid": this.mpid});
  }

  /// Removes a user attribute.
  ///
  /// Removes a user attribute given a [key].
  void removeUserAttribute(String key) async {
    await _channel.invokeMethod('removeUserAttribute', {"attributeKey": key});
  }

  /// Sets a user attribute.
  ///
  /// Sets a user attribute [key] given a [value].
  void setUserAttribute(String key, String value) async {
    await _channel.invokeMethod('setUserAttribute',
        {"attributeKey": key, "attributeValue": value, "mpid": this.mpid});
  }

  /// Sets a value of an array to a user attribute.
  ///
  /// Sets a user attribute [key] given a [value].
  void setUserAttributeArray(String key, List<String> value) async {
    await _channel.invokeMethod('setUserAttributeArray',
        {"attributeKey": key, "attributeValue": value, "mpid": this.mpid});
  }

  /// Sets a user tag.
  ///
  /// Sets a given [tag] on a user. This sets a user attribute with a value of null.
  void setUserTag(String key) async {
    await _channel
        .invokeMethod('setUserTag', {"attributeKey": key, "mpid": this.mpid});
  }

  /// Returns all GDPR Consent states with their purpose.
  Future<Map> getGDPRConsentState() async {
    String consentStateString =
        await _channel.invokeMethod('getGDPRConsentState', {"mpid": this.mpid});
    Map consentStateMap = jsonDecode(consentStateString);
    return consentStateMap;
  }

  /// Set a GDPR consent object to a purpose on the user
  ///
  /// Sets a GDPR consent object [consent] to a purpose [purpose] on the user
  void addGDPRConsentState(GDPRConsent consent, String purpose) async {
    return await _channel.invokeMethod('addGDPRConsentState', {
      'consented': consent.consented,
      'document': consent.document,
      'timestamp': consent.timestamp,
      'location': consent.location,
      'hardwareId': consent.hardwareId,
      'purpose': purpose,
      'mpid': this.mpid,
    });
  }

  /// Remove a GDPR consent object from a purpose on the user
  ///
  /// Remove a GDPR consent object from a purpose [purpose] on the user
  void removeGDPRConsentState(String purpose) async {
    return await _channel.invokeMethod('removeGDPRConsentState', {
      'purpose': purpose,
      'mpid': this.mpid,
    });
  }

  /// Returns the CCPA Consent state.
  Future<Map> getCCPAConsentState() async {
    String consentStateString =
        await _channel.invokeMethod('getCCPAConsentState', {"mpid": this.mpid});
    Map consentStateMap = jsonDecode(consentStateString);
    return consentStateMap;
  }

  /// Set a CCPA consent object on the user
  ///
  /// Sets a CCPA consent object [consent] on the user
  void addCCPAConsentState(CCPAConsent consent) async {
    return await _channel.invokeMethod('addCCPAConsentState', {
      'consented': consent.consented,
      'document': consent.document,
      'timestamp': consent.timestamp,
      'location': consent.location,
      'hardwareId': consent.hardwareId,
      'mpid': this.mpid,
    });
  }

  /// Remove the CCPA consent object from the user
  ///
  /// Remove the CCPA consent object from the user
  void removeCCPAConsentState() async {
    return await _channel.invokeMethod('removeCCPAConsentState', {
      'mpid': this.mpid,
    });
  }
}
