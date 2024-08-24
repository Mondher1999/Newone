import 'dart:io';

import 'package:madidou/data/model/property.dart';

abstract class PropertyEvent {}

class FetchProperties extends PropertyEvent {}

class FetchPropertiesByUserId extends PropertyEvent {
  final String userId;
  FetchPropertiesByUserId(this.userId);
}

class AddProperty extends PropertyEvent {
  final String userId;
  final Property property;
  final List<String> imagePaths;

  AddProperty(
      {required this.property,
      required this.imagePaths,
      required String this.userId});
}

class UpdatePropertyImage extends PropertyEvent {
  final String userId;
  final String propertId;
  final File imageFile;

  UpdatePropertyImage(this.propertId, this.imageFile, this.userId);
}

class UpdateProperty extends PropertyEvent {
  final String userId;

  final Property property;

  UpdateProperty(this.property, this.userId);
}

class FetchProperty extends PropertyEvent {
  final String propertyId;

  FetchProperty(this.propertyId);
}

class DeleteProperty extends PropertyEvent {
  final String userId;

  final String propertyId;
  DeleteProperty(this.propertyId, this.userId);
}
