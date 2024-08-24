import 'package:madidou/data/enums/PropertyType.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/amenities.dart';

class PropertyFilter {
  String? region;
  double? minPrice;
  double? maxPrice;
  String? searchTerm;
  double? minArea;
  double? maxArea;
  List<int> nbrRooms = [];
  final double? latitude;
  final double? longitude;
  List<PropertyType>? propertyType;
// Changed PropertyType to propertyType
  List<PropertyCondition>?
      propertyCondition; // Allow multiple property conditions
  List<Amenities>? amenities;

  PropertyFilter(
      {this.region,
      this.minPrice,
      this.maxPrice,
      this.minArea,
      this.maxArea,
      required this.nbrRooms,
      this.propertyType,
      this.propertyCondition,
      this.searchTerm,
      this.latitude,
      this.longitude,
      this.amenities});
}
