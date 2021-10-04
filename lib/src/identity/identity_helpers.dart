import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mparticle_flutter_sdk/identity/identity_api_error_response.dart';
import 'package:mparticle_flutter_sdk/identity/identity_type.dart';
import 'package:mparticle_flutter_sdk/identity/identity_api_result.dart';
import 'package:mparticle_flutter_sdk/identity/client_error_codes.dart';

sendIdentityRequest(Map<IdentityType, String> identitiesByEnum,
    MethodChannel channel, String identityMethod) async {
  Map<int, String> identitiesByString = new Map();

  identitiesByEnum.forEach((key, value) {
    identitiesByString[key.index] = value;
  });
  var responseString = await channel
      .invokeMethod(identityMethod, {'identityRequest': identitiesByString});
  Map response = jsonDecode(responseString);
  if (response["errors"] != null && (response["errors"] as List).isNotEmpty) {
    var httpCode = response["http_code"];
    if (httpCode is String) {
      httpCode = int.tryParse(httpCode);
    }

    IdentityClientErrorCodes? clientErrorCode;

    String platform = response['platform'];
    if (httpCode < 200) {
      switch (httpCode) {
        case -1: // web and android both have a -1 client side error code
          if (platform == 'web') {
            clientErrorCode = IdentityClientErrorCodes.ClientNoConnection;
          } else if (platform == 'android') {
            clientErrorCode = IdentityClientErrorCodes.Unknown;
          }
          break;
        case -2: // Web Code
          clientErrorCode = IdentityClientErrorCodes.RequestInProgress;
          break;
        case -3: // Web Code
          clientErrorCode = IdentityClientErrorCodes.ActiveSession;
          break;
        case -4: // Web Code
          clientErrorCode = IdentityClientErrorCodes.ValidationIssue;
          break;
        case -5: // Web Code
          clientErrorCode = IdentityClientErrorCodes.NativeIdentityRequest;
          break;
        case -6: // Web Code
          clientErrorCode = IdentityClientErrorCodes.OptOut;
          break;

        // iOS error codes
        case 0: // iOS code
          clientErrorCode = IdentityClientErrorCodes.Unknown;
          break;
        case 1: // iOS code
          clientErrorCode = IdentityClientErrorCodes.RequestInProgress;
          break;
        case 2: // iOS code
          clientErrorCode = IdentityClientErrorCodes.ClientSideTimeout;
          break;
        case 3: // iOS code
          clientErrorCode = IdentityClientErrorCodes.ClientNoConnection;
          break;
        case 4: // iOS code
          clientErrorCode = IdentityClientErrorCodes.SSLError;
          break;
        case 5:
          clientErrorCode = IdentityClientErrorCodes.OptOut;
          break;

        default:
          print('IdentityClientErrorCode of $httpCode not supported');
          clientErrorCode = null;
      }
    }

    var error = IdentityAPIErrorResponse(
        httpCode: httpCode,
        mpid: response["mpid"],
        errors: (response["errors"] as List?)
                ?.map((e) => Error(e["code"], e["message"]))
                .toList() ??
            List.empty(),
        clientErrorCode: clientErrorCode);

    return Future.error(error);
  } else {
    var success = IdentityApiResult(
        mpid: response["mpid"], previousMpid: response["previous_mpid"]);
    return success;
  }
}

convertIdentityStringToEnumMap(userIdentitiesString) {
  Map userIdentitiesMap = jsonDecode(userIdentitiesString);
  Map<IdentityType, String> identitiesKeyedByEnum = {};

  try {
    userIdentitiesMap.forEach((key, value) {
      identitiesKeyedByEnum[convertStringifiedIntIdentityToIdentityEnum(key)] =
          value;
    });
  } catch (error, stackTrace) {
    print(
        'An error ocurred when converting identity types to an enum: \n$error\n$stackTrace');
  }

  return identitiesKeyedByEnum;
}

IdentityType convertStringifiedIntIdentityToIdentityEnum(String identityType) {
  switch (identityType) {
    case '0':
      return IdentityType.Other;
    case '1':
      return IdentityType.CustomerId;
    case '2':
      return IdentityType.Facebook;
    case '3':
      return IdentityType.Twitter;
    case '4':
      return IdentityType.Google;
    case '5':
      return IdentityType.Microsoft;
    case '6':
      return IdentityType.Yahoo;
    case '7':
      return IdentityType.Email;
    case '9':
      return IdentityType.FacebookCustomAudienceId;
    case '10':
      return IdentityType.Other2;
    case '11':
      return IdentityType.Other3;
    case '12':
      return IdentityType.Other4;
    case '13':
      return IdentityType.Other5;
    case '14':
      return IdentityType.Other6;
    case '15':
      return IdentityType.Other7;
    case '16':
      return IdentityType.Other8;
    case '17':
      return IdentityType.Other9;
    case '18':
      return IdentityType.Other10;
    case '19':
      return IdentityType.MobileNumber;
    case '20':
      return IdentityType.PhoneNumber2;
    case '21':
      return IdentityType.PhoneNumber3;
    default:
      throw Exception(
          'The server returned an identity type value of "$identityType" that is not mapped');
  }
}
