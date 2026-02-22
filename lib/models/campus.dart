class Campus {
  final String id;
  final String name;
  final String city;
  final bool isActive;

  Campus({
    required this.id,
    required this.name,
    required this.city,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'isActive': isActive,
      };

  factory Campus.fromJson(Map<String, dynamic> json, String docId) {
    return Campus(
      id: docId,
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Campus && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
