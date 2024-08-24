class Favorite {
  final String id; // Unique identifier for the favorite entry
  final String
      userId; // Identifier of the user who marked the property as favorite
  final String propertyId; // Identifier of the property marked as favorite
  final DateTime createdAt; // Timestamp when the favorite was added

  // Constructor
  Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.createdAt,
  });

  // Method to create a new Favorite instance from JSON data
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to convert a Favorite instance into JSON format
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'propertyId': propertyId,
        'createdAt': createdAt.toIso8601String(),
      };

  // Method to create a copy of a Favorite instance with modified fields
  Favorite copyWith({
    String? id,
    String? userId,
    String? propertyId,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
