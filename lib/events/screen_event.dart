/// This class represents a screen event to be logged using the mParticle SDK

class ScreenEvent {
  String eventName;
  Map<String, String?>? customAttributes;
  Map<String, dynamic>? customFlags;

  ScreenEvent(this.eventName);
}
