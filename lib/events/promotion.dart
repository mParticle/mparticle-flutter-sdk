/// A Promotion for use with a commerce event
class Promotion {
  Promotion(
      {required this.promotionId, this.creative, this.name, this.position});

  /// Promotion identifier
  final String promotionId;

  /// Description for the promotion creative
  final String? creative;

  /// Promotion name
  final String? name;

  /// Promotion display position
  final String? position;

  static Promotion fromJson(Map<String, dynamic> json) {
    return Promotion(
        promotionId: json['promotionId'] as String,
        creative: json['creative'] as String,
        name: json['name'] as String,
        position: json['position'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'promotionId': this.promotionId,
      'creative': this.creative,
      'name': this.name,
      'position': this.position
    };
  }
}
