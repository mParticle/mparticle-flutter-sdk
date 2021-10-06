import 'event_type.dart';

/// This class represents an event to be logged using the mParticle SDK
class MPEvent {
  /// The name of the event to be logged. The event name must not contain more than 255 characters.
  String eventName;

  /// An enum value that indicates the type of event to be logged.
  final EventType? eventType;

  /// A map containing further information about the event.
  Map<String, String?>? customAttributes;

  /// A map containing kit-specific flags about the event.
  Map<String, dynamic>? customFlags;

  /// Flag indicating whether the event should be sent to mParticle's servers.
  bool? shouldUploadEvent;

  MPEvent(
      {required this.eventName,
      this.eventType,
      this.customAttributes,
      this.customFlags});
}
