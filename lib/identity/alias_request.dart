/// A request to copy data from one user to another, constrained to a particular time period.
///
/// A [sourceMPID] and [destinationMPID] are required. You must either set both
/// a [startTime] and [endTime], or exclude both and allow the underlying
/// platform mParticle SDK to set them for you.
class AliasRequest {
  /// The MPID of the user that has existing data.
  String sourceMpid;

  /// The MPID of the user that should receive the copied data.
  String destinationMpid;

  /// The timestamp of the earliest data that should be copied, defaults to the source user’s first seen timestamp.
  int? startTime;

  /// The timestamp of the latest data that should be copied, defaults to the source user’s last seen timestamp.
  int? endTime;

  AliasRequest(
      {required this.sourceMpid,
      required this.destinationMpid,
      this.endTime,
      this.startTime});

  setEndTime(endTime) {
    this.endTime = endTime;
  }

  setStartTime(startTime) {
    this.startTime = startTime;
  }
}
