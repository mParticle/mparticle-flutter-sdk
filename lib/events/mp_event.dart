import 'event_type.dart';

class MPEvent {
  String eventName;
  final EventType? eventType;
  Map<String, String?>? customAttributes;
  Map<String, dynamic>? customFlags;
  bool? shouldUploadEvent;

  MPEvent(this.eventName, [this.eventType]);
}
