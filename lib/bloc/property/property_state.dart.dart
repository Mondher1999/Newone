import 'package:madidou/data/model/property.dart';

abstract class PropertyState {}

class PropertiesLoading extends PropertyState {}

class PropertiesLoaded extends PropertyState {
  final List<Property> properties;
  PropertiesLoaded(this.properties);
}

class PropertyCreationSuccess extends PropertyState {
  final Property property; // Optionally hold the created post's details

  PropertyCreationSuccess(this.property);
}

class PropertyUpdateSuccess extends PropertyState {
  final Property property; // Optionally hold the created post's details

  PropertyUpdateSuccess(this.property);
}

class PropertyUpdatingImage extends PropertyState {}

class PropertyUpdatingSuccessImage extends PropertyState {}

class PropertiesDeleteSucess extends PropertyState {}

class PropertyCreating extends PropertyState {}

class PropertyUpdating extends PropertyState {}

class PropertyDeleting extends PropertyState {}

class PropertyError extends PropertyState {}

class PropertyLoading
    extends PropertyState {} // State when loading post details

class PropertyLoadSuccess extends PropertyState {
  final Property property;
  PropertyLoadSuccess(this.property);
}
// State for an error

