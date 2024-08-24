import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/property_detail_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Price_Update_Screen extends StatefulWidget {
  final Property property;
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  Price_Update_Screen({
    Key? key,
    required this.property,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  State<Price_Update_Screen> createState() => _EightthScreenState();
}

class _EightthScreenState extends State<Price_Update_Screen> {
  final TextEditingController priceController = TextEditingController();
  List<XFile>? _imageList = [];
  double progress = 7 / 7; // Current step 1 of 3

  @override
  void initState() {
    super.initState();

    if (widget.property.price != null && widget.property.price.isNotEmpty) {
      priceController.text = widget.property.price;
    }

    print("Received property type: ${widget.property.propertyType}");
    print("Received property condition: ${widget.property.propertyCondition}");
    print("Title: ${widget.property.title}");
    print("Description: ${widget.property.description}");
    print("Nbr rooms: ${widget.property.nbrRooms}");
    print("Area: ${widget.property.totalArea}");
    print("latitude: ${widget.property.lat}");
    print("longitude: ${widget.property.lng}");
    print("Region: ${widget.property.region}");
    // Print the number of images
    print("Number of Images: ${widget.images.length}");
    widget.images.forEach((image) {
      print("Image path: ${image.path}");
      // Print the selected amenities
      print("Selected Amenities:");
      widget.selectedAmenities.forEach((amenity) {
        print("${amenity.toString()}");
      });
    });

    // Optionally, print details of each image
  }

  void _updateProperty() {
    final List<String> amenitiesAsString = widget.selectedAmenities
        .map((amenity) => amenity.toString().split('.').last.toLowerCase())
        .toList();
    final Property updatedProperty = Property(
      description: widget.property.description,
      fileUrls: [], // Updated after image upload
      userId: 'userId', // Ideally, this should come from your auth system
      title: widget.property.title,
      price: priceController.text,
      totalArea: widget.property.totalArea,
      nbrRooms: widget.property.nbrRooms,
      city: widget.property.city,
      propertyType: widget.property.propertyType,
      address: widget.property.address,
      region: widget.property.region,
      propertyCondition: widget.property.propertyCondition,
      id: widget.property.id,
      amenities: amenitiesAsString,
      lat: widget.property.lat,
      lng: widget.property.lng,
      // Add your logic for userId
    );

    // Pass imagePath if a new image is selected; otherwise, pass null
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
    BlocProvider.of<PropertyBloc>(context)
        .add(UpdateProperty(updatedProperty, authUser.id));
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la sortie'),
          content: const Text(
              'Êtes-vous sûr de vouloir quitter la création de l’annonce ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog only
              },
              child: const Text('Continuer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => PropertiesProprietaireScreen()),
                );
              },
              child: const Text('Quitter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertyUpdateSuccess) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Succès'),
                content:
                    const Text("le prix de l'annonce est Modifié avec succès."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      final AuthUser authUser =
                          AuthUser.fromFirebase(firebaseUser!);
                      context.read<AuthBloc>().add(SetAsProprietaire(authUser));
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (state is PropertyUpdating) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(
                      child: Text(
                          "S'il vous plaît attendez jusqu'à la Modification de voter annonce")),
                ],
              ),
              duration: Duration(
                  milliseconds:
                      100), // Optional: adjust the duration according to the expected wait time
              backgroundColor: Color.fromARGB(255, 255, 112, 137),
            ),
          );
        } else if (state is PropertyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erreur lors de l'ajout de la propriété."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          // Ensures the content is scrollable to avoid overflow.
          child: Column(
            children: <Widget>[
              const Padding(
                padding: const EdgeInsets.only(
                    top: 160.0, right: 20, left: 20, bottom: 20),
                child: Text(
                  "À présent, fixez votre prix",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 0.0, right: 20, left: 20, bottom: 10),
                child: Text(
                  "Vous pouvez le modifier à tout moment.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the container
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style:
                        const TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                    decoration: InputDecoration(
                      hintText: "€ Entrez le prix",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {}, // Clear the text field
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 300),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, right: 20, left: 20, bottom: 10),
                child: LinearPercentIndicator(
                  lineHeight: 10.0,
                  percent: progress,
                  backgroundColor: Colors.grey[300],
                  linearGradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                  ),
                  barRadius: const Radius.circular(5),
                  animateFromLastPercent: true,
                  animation: true,
                  animationDuration: 500,
                ),
              ),
              const SizedBox(height: 25),
              _buildNavigationRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Ensures the row only takes up needed space
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            final firebaseUser = FirebaseAuth.instance.currentUser;
            final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
            context.read<AuthBloc>().add(SetAsProprietaire(authUser));
          },
          // Your action here

          child: const Text('Retour'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,

            // Text color inside the button
            textStyle: const TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: 17, // Button text size
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // Rounded corners for the button
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 27, vertical: 16), // Custom padding for the button
          ),
        ),
        const SizedBox(width: 120), // Space between text and button
        TextButton(
          onPressed: _updateProperty,
          // Your action here

          child: const Text('Enregistrer'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,

            backgroundColor:
                const Color(0xFF5e5f99), // Text color inside the button
            textStyle: const TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: 15, // Button text size
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // Rounded corners for the button
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 27, vertical: 16), // Custom padding for the button
          ),
        ),
      ],
    );
  }

  void _navigateTopreviousScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailUpdateScreen(
          property: widget.property,
          selectedAmenities: widget.selectedAmenities,
        ),
      ),
    );

    setState(() {
      widget.property.price = priceController.text;
      ;
    });
  }
}
