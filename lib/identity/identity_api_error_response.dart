import 'package:mparticle_flutter_sdk/identity/client_error_codes.dart';

/// A class that returns when an identity request fails for some reason.
///
///  This is passed to the handler for both client and server errors.
class IdentityAPIErrorResponse {
  /// The http response code for errors returned by the server.
  int? httpCode;

  /// The MPID of the user.
  String? mpid;

  /// Errors that are returned.  This can be client side, or server side.
  List<Error> errors = List.empty();

  /// Client side error codes. If this exists, the Identity Request never was sent to the server.
  IdentityClientErrorCodes? clientErrorCode;

  IdentityAPIErrorResponse(
      {required this.errors, this.httpCode, this.mpid, this.clientErrorCode});

  @override
  String toString() {
    return "httpCode: $httpCode\n"
        "mpid: $mpid\n"
        "errors: ${errors.map((e) => "code: ${e.code} message: ${e.message}\n")}\n"
        "clientErrorCode: ${clientErrorCode.toString().substring(clientErrorCode.toString().indexOf('.') + 1)}";
  }
}

class Error {
  String code;
  String message;

  Error(this.code, this.message);
}
