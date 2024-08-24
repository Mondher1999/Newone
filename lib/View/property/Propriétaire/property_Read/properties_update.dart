import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';

class UpdatePropertyView extends StatefulWidget {
  final String propertyId;

  const UpdatePropertyView({Key? key, required this.propertyId})
      : super(key: key);

  @override
  _UpdatePropertyViewState createState() => _UpdatePropertyViewState();
}

class _UpdatePropertyViewState extends State<UpdatePropertyView> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  bool _isLoading = true;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
  }

  Future<void> _fetchPropertyDetails() async {
    // Assuming FetchProperty event sets the property details including the imageUrl
    BlocProvider.of<PropertyBloc>(context)
        .add(FetchProperty(widget.propertyId));
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _updateProperty() {
    final Property updatedProperty = Property(
      description: _descriptionController.text,
      fileUrls: [], // Updated after image upload
      userId: 'userId', // Ideally, this should come from your auth system
      title: 'title',
      price: '5',
      totalArea: '55',
      nbrRooms: '5',
      city: "city",
      propertyType: 'propertyType',
      address: 'address',
      region: 'Occitanie',
      propertyCondition: 'propertyCondition',
      id: widget.propertyId,
      amenities: [""],
      lat: 1.1,
      lng: 1.1,
      // Add your logic for userId
    );

    // Pass imagePath if a new image is selected; otherwise, pass null
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
    BlocProvider.of<PropertyBloc>(context)
        .add(UpdateProperty(updatedProperty, authUser.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Property'),
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyUpdateSuccess) {
            _showUpdateSuccessDialog();
          } else if (state is PropertyError) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update Property')));
          } else if (state is PropertyLoadSuccess) {
            _existingImageUrl = state.property.fileUrls[0];
            ;
            _descriptionController.text = state.property.description;
            setState(() {
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          if (state is PropertyUpdating) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (_image != null) Image.file(_image!, height: 200),
                if (_image == null && _existingImageUrl != null)
                  /*  CachedNetworkImage(
                    imageUrl: _existingImageUrl!,
                    height: 200,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ), */
                  ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Select New Image')),
                TextField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Property Description'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _updateProperty,
                    child: const Text('Update Property')),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showUpdateSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Property updated successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PropertiesProprietaireScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
