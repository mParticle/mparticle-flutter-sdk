import 'package:mparticle_flutter_sdk/src/user.dart';

/// A class that returns when an identity request succeeds.

class IdentityApiResult {
  /// Resolved user as a result of the Identity API request.
  late User user;

  /// User that was active before identity request was sent, if applicable.
  User? previousUser;

  IdentityApiResult({required mpid, previousMpid}) {
    this.user = User(mpid);
    if (previousMpid != null) {
      this.previousUser = User(previousMpid);
    }
  }

  @override
  String toString() {
    var userMPID = this.user.getMPID();
    var previousUserMPID = this.previousUser?.getMPID();
    return "mpid: $userMPID\n"
        "previousMpid: $previousUserMPID";
  }
}
