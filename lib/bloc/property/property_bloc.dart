import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/data/repository/property_repository.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepository propertyRepository;

  PropertyBloc({required this.propertyRepository})
      : super(PropertiesLoading()) {
    on<FetchProperties>((event, emit) async {
      emit(PropertiesLoading()); // Emitting a loading state
      try {
        final properties = await propertyRepository
            .getProperties(); // Fetch posts from the repository
        emit(PropertiesLoaded(
            properties)); // Emitting a loaded state with the posts
      } catch (e) {
        emit(PropertyError()); // Emitting an error state if an exception occurs
      }
    });

    on<FetchPropertiesByUserId>((event, emit) async {
      emit(PropertiesLoading()); // Emitting a loading state
      try {
        final properties = await propertyRepository.getPropertiesByUserId(
            event.userId); // Fetch posts from the repository
        emit(PropertiesLoaded(properties
            as List<Property>)); // Emitting a loaded state with the posts
      } catch (e) {
        emit(PropertyError()); // Emitting an error state if an exception occurs
      }
    });

    on<AddProperty>((event, emit) async {
      emit(PropertyCreating());
      try {
        List<File> imageFiles = [];
        if (event.imagePaths != null) {
          for (var path in event.imagePaths!) {
            imageFiles.add(File(path));
          }
        }
        //  print('Creating property...');
        final newProperty = await propertyRepository.createProperty(
            event.property, imageFiles, event.userId);
        //  print('Property created successfully: ${newProperty.toString()}');
        emit(PropertyCreationSuccess(newProperty));
        final properties =
            await propertyRepository.getPropertiesByUserId(event.userId);
        emit(PropertiesLoaded(properties as List<Property>));
      } catch (e) {
        //    print('Error creating property: $e'); // Log the error
        emit(PropertyError());
      }
    });

    on<UpdatePropertyImage>((event, emit) async {
      emit(PropertyUpdatingImage());
      try {
        bool success = await propertyRepository.updatePropertyImage(
            event.propertId, event.imageFile);
        if (success) {
          emit(PropertyUpdatingSuccessImage());
          final properties =
              await propertyRepository.getPropertiesByUserId(event.userId);
          emit(PropertiesLoaded(properties as List<Property>));

          // Fetch the updated user data or just the new image URL
          // Pass the new image URL with the state
        } else {
          emit(PropertyError());
          //  emit(UserError("Failed to update image."));
        }
      } catch (e) {
        //  emit(UserError(e.toString()));
        emit(PropertyError());
      }
    });

    on<FetchProperty>((event, emit) async {
      emit(PropertyLoading());
      try {
        final property =
            await propertyRepository.getPropertyById(event.propertyId);
        emit(PropertyLoadSuccess(property));
      } catch (e) {
        emit(PropertyError());
        //print(e.toString()); // For debugging
      }
    });
    on<UpdateProperty>((event, emit) async {
      emit(PropertyUpdating());
      try {
        final updatedProperty = await propertyRepository.updateProperty(
            event.property.id, event.property); // Pass imagePath directly
        emit(PropertyUpdateSuccess(updatedProperty));
        final properties =
            await propertyRepository.getPropertiesByUserId(event.userId);
        emit(PropertiesLoaded(properties as List<Property>));
        // Refresh posts list
      } catch (e) {
        emit(PropertyError());
        print(e.toString()); // For debugging
      }
    });
    on<DeleteProperty>((event, emit) async {
      emit(PropertyDeleting());
      try {
        // Await the completion of the deletion process
        bool success = await propertyRepository
            .deleteProperty(event.propertyId); // Make sure to await this call

        if (success) {
          emit(PropertiesDeleteSucess());
          final properties =
              await propertyRepository.getPropertiesByUserId(event.userId);
          emit(PropertiesLoaded(properties as List<Property>));

          // Fetch the updated user data or just the new image URL
          // Pass the new image URL with the state
        } else {
          emit(PropertyError());
          //  emit(UserError("Failed to update image."));
        }
      } catch (_) {
        emit(
            PropertyError()); // It's good practice to handle errors and inform the user
      }
    });
  }
}
