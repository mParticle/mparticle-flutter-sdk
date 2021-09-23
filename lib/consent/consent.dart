/// This class represents an Consent Object to be logged using the mParticle SDK
class Consent {
  bool consented;
  String? document;
  int? timestamp;
  String? location;
  String? hardwareId;

  Consent(this.consented);
}
