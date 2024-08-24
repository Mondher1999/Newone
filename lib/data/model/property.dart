class Property {
  final String id;
  String description;
  String title;
  String price;
  String totalArea;
  String nbrRooms;
  String propertyType;
  final String address;
  String region;
  String propertyCondition;
  final List<String> fileUrls; // Now a list to hold multiple URLs
  final String userId;
  List<String> amenities;
  final String city;
  double lat; // Added latitude
  double lng; // Added longitude

  // Existing constructor remains unchanged to maintain compatibility
  Property({
    required this.id,
    required this.description,
    this.fileUrls = const [], // Default to an empty list
    required this.userId,
    required this.title,
    required this.price,
    required this.totalArea,
    required this.nbrRooms,
    required this.address,
    required this.city,
    required this.region,
    required this.propertyCondition,
    required this.propertyType,
    required this.amenities,
    required this.lat, // Initialize in constructor
    required this.lng, // Initialize in constructor
  });

  // Named constructor without fileUrl
  Property.withoutFileUrl({
    required this.id,
    required this.description,
    required this.title,
    required this.price,
    required this.totalArea,
    required this.nbrRooms,
    required this.address,
    required this.city,
    required this.region,
    required this.propertyCondition,
    required this.propertyType,
    required this.amenities,
    required this.lat, // Initialize in constructor
    required this.lng, // Initialize in constructor
    this.fileUrls = const [], // Default to an empty list
// Default to an empty string or any default value you prefer
    required this.userId,
  });

  Property copyWith(
      {String? id, String? description, String? fileUrl, String? userId}) {
    return Property(
      id: id ?? this.id,
      description: description ?? this.description,
      title: title,
      price: price,
      totalArea: totalArea,
      nbrRooms: nbrRooms,
      address: address,
      city: city,
      region: region,
      propertyCondition: propertyCondition,
      propertyType: propertyType,
      amenities: amenities,
      fileUrls: fileUrls,
      userId: userId ?? this.userId,
      lat: lat,
      lng: lng,
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      json['amenities'].forEach((v) {
        amenitiesList.add(v.toString());
      });
    }

    // Parse fileUrls correctly as a List<String>
    List<String> fileUrlsList = List<String>.from(json['fileUrls'] ?? []);

    return Property(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      fileUrls: fileUrlsList,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      nbrRooms: json['nbrRooms'] ?? '',
      totalArea: json['totalArea'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      propertyCondition: json['propertyCondition'] ?? '',
      propertyType: json['propertyType'] ?? '',
      amenities: amenitiesList,
      lat: json['location'] != null
          ? double.parse(json['location']['lat'])
          : 0.0,
      lng: json['location'] != null
          ? double.parse(json['location']['lng'])
          : 0.0,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'fileUrls': fileUrls,
        'userId': userId,
        'title': title,
        'price': price,
        'nbrRooms': nbrRooms,
        'totalArea': totalArea,
        'address': address,
        'city': city,
        'region': region,
        'propertyCondition': propertyCondition,
        'propertyType': propertyType,
        'amenities': amenities,
        'lat': lat, // Include latitude in JSON
        'lng': lng, // Include longitude in JSON
      };
}
