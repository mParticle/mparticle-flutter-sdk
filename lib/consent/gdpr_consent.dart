/// This class represents an GDPR Consent Object to be logged using the mParticle SDK
class GDPRConsent {
  bool consented;
  String? document;
  int? timestamp;
  String? location;
  String? hardwareId;

  GDPRConsent(this.consented);
}
