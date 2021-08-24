import 'dart:js';
import 'dart:convert';

String? convertIntIdentityToStringIdentity(int identityType) {
  switch (identityType) {
    case 0:
      return 'other';
    case 1:
      return 'customerid';
    case 2:
      return 'facebook';
    case 3:
      return 'twitter';
    case 4:
      return 'google';
    case 5:
      return 'microsoft';
    case 6:
      return 'yahoo';
    case 7:
      return 'email';
    // case 8 is "alias", which is deprecated
    case 9:
      return 'facebookcustomaudienceid';
    case 10:
      return 'other2';
    case 11:
      return 'other3';
    case 12:
      return 'other4';
    case 13:
      return 'other5';
    case 14:
      return 'other6';
    case 15:
      return 'other7';
    case 16:
      return 'other8';
    case 17:
      return 'other9';
    case 18:
      return 'other10';
    case 19:
      return 'mobile_number';
    case 20:
      return 'phone_number_2';
    case 21:
      return 'phone_number_3';
    default:
      print('You passed in an identity that is not supported on Web');
      return null;
  }
}

createWebIdentityRequest(identitiesKeyedOnType) {
  var identitiesKeyedOnString = {};
  identitiesKeyedOnType.forEach((key, value) {
    var identity = convertIntIdentityToStringIdentity(key);
    if (identity != null) {
      identitiesKeyedOnString[convertIntIdentityToStringIdentity(key)] = value;
    }
  });
  return {"userIdentities": identitiesKeyedOnString};
}

String? convertIdentityNameToStringifiedNumber(String identityName) {
  switch (identityName) {
    case 'other':
      return '0';
    case 'customerid':
      return '1';
    case 'facebook':
      return '2';
    case 'twitter':
      return '3';
    case 'google':
      return '4';
    case 'microsoft':
      return '5';
    case 'yahoo':
      return '6';
    case 'email':
      return '7';
    // case 8 is 'alias' which will never be returned by the server
    case 'facebookcustomaudienceid':
      return '9';
    case 'other2':
      return '10';
    case 'other3':
      return '11';
    case 'other4':
      return '12';
    case 'other5':
      return '13';
    case 'other6':
      return '14';
    case 'other7':
      return '15';
    case 'other8':
      return '16';
    case 'other9':
      return '17';
    case 'other10':
      return '18';
    case 'mobile_number':
      return '19';
    case 'phone_number_2':
      return '20';
    case 'phone_number_3':
      return '21';
    default:
      print('You passed in an identity that is not supported on Web');
      return null;
  }
}

convertJSErrorArraytoDartErrorList(result) {
  List<Map<String, String?>>? errors = [];
  String errorsString =
      context['JSON'].callMethod('stringify', [result['body']['errors']]);
  List<dynamic> errorList = jsonDecode(errorsString);
  errorList.forEach((error) {
    errors.add({'code': error['code'], 'message': error['message']});
  });

  return errors;
}

Map<String, dynamic> createAliasRequest(aliasRequest, mParticle, mpIdentity) {
  String sourceMpid = aliasRequest['sourceMpid'];
  String destinationMpid = aliasRequest['destinationMpid'];

  int timeNowInMs = DateTime.now().millisecondsSinceEpoch;
  int aliasMaxWindow = mParticle.callMethod('getInstance')['_Store']
      ['SDKConfig']['aliasMaxWindow']; // in days
  int aliasMaxWindowInMs = aliasMaxWindow * 24 * 60 * 60 * 1000;
  int minFirstSeenTimeMs = timeNowInMs - aliasMaxWindowInMs;
  int startTime = mpIdentity
      .callMethod('getUser', [sourceMpid]).callMethod('getFirstSeenTime');

  var endTime = mpIdentity
      .callMethod('getUser', [sourceMpid]).callMethod('getLastSeenTime');
  if (endTime == null) {
    endTime = timeNowInMs;
  }
  if (startTime < minFirstSeenTimeMs) {
    startTime = minFirstSeenTimeMs;
    if (endTime < startTime) {
      print(
          'Source User has not been seen in the last $aliasMaxWindow days. Alias request will likely fail');
    }
  }

  return Map.from({
    'destinationMpid': destinationMpid,
    'sourceMpid': sourceMpid,
    'startTime': startTime,
    'endTime': endTime,
  });
}
