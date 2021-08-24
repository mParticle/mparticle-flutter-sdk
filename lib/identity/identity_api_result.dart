import 'package:mparticle_flutter_sdk/src/user.dart';

class IdentityApiResult {
  late User user;
  User? previousUser;

  IdentityApiResult(mpid, previousMpid) {
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
