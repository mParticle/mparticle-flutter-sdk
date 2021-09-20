/// A Promotion for use with a commerce event
class Promotion {
  Promotion(this.promotionId, [this.creative, this.name, this.position]);

  final String promotionId;
  final String? creative;
  final String? name;
  final String? position;

  static Promotion fromJson(Map<String, dynamic> json) {
    return Promotion(json['promotionId'] as String, json['creative'] as String,
        json['name'] as String, json['position'] as String);
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
