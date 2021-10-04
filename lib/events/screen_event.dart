/// This class represents a screen event to be logged using the mParticle SDK

class ScreenEvent {
  /// The name of the screen event to be logged.
  String eventName;

  /// A map containing further information about the screen event.
  Map<String, String?>? customAttributes;

  /// A map containing kit-specific flags about the screen event.
  Map<String, dynamic>? customFlags;

  ScreenEvent(
      {required this.eventName, this.customAttributes, this.customFlags});
}
