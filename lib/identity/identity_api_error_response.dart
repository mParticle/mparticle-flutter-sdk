import 'package:mparticle_flutter_sdk/identity/client_error_codes.dart';

/// An object returned when an identity request fails for some reason.
///
//  This is passed to the handler for both client and server errors.
class IdentityAPIErrorResponse {
  int? httpCode;
  String? mpid;
  List<Error> errors = List.empty();
  IdentityClientErrorCodes? clientErrorCode;

  IdentityAPIErrorResponse(
      this.httpCode, this.mpid, this.errors, this.clientErrorCode);

  @override
  String toString() {
    return "httpCode: $httpCode\n"
        "mpid: $mpid\n"
        "errors: ${errors.map((e) => "code: ${e.code} message: ${e.message}\n")}\n"
        "clientErrorCode: ${clientErrorCode.toString().substring(clientErrorCode.toString().indexOf('.') + 1)}";
  }
}

/// An Error class to be used for the [FailureResponse] [errors] property.
class Error {
  String code;
  String message;

  Error(this.code, this.message);
}
