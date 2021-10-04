/// This class represents an Consent Object to be logged using the mParticle SDK
class Consent {
  /// Whether the user consented to data collection
  bool consented;

  /// The data collection document to which the user consented or did not consent
  String? document;

  /// Timestamp when the user was prompted for consent
  int? timestamp;

  /// Where the consent prompt took place. This can be a physical or digital location (e.g. URL)
  String? location;

  /// The device ID associated with this consent record
  String? hardwareId;

  Consent(
      {required this.consented,
      this.document,
      this.timestamp,
      this.location,
      this.hardwareId});
}
