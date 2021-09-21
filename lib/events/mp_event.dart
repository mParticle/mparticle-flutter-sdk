import 'event_type.dart';

/// This class represents an event to be logged using the mParticle SDK
class MPEvent {
  String eventName;
  final EventType? eventType;
  Map<String, String?>? customAttributes;
  Map<String, dynamic>? customFlags;
  bool? shouldUploadEvent;

  MPEvent(this.eventName, [this.eventType]);
}
