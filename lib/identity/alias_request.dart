/// A request to copy data from one user to another, constrained to a particular time period.
///
/// A [sourceMPID] and [destinationMPID] are required. You must either set both
/// a [startTime] and [endTime], or exclude both and allow the underlying
/// platform mParticle SDK to set them for you.
class AliasRequest {
  String sourceMpid;
  String destinationMpid;
  int? startTime;
  int? endTime;

  AliasRequest(this.sourceMpid, this.destinationMpid,
      [this.endTime, this.startTime]);

  setEndTime(endTime) {
    this.endTime = endTime;
  }

  setStartTime(startTime) {
    this.startTime = startTime;
  }
}
