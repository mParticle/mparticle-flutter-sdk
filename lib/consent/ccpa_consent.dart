/// This class represents an CCPA Consent Object to be logged using the mParticle SDK
class CCPAConsent {
  bool consented;
  String? document;
  int? timestamp;
  String? location;
  String? hardwareId;

  CCPAConsent(this.consented);
}
