import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/condition_type_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/nrbroom_area_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/property_detail_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/PropertyType.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Title_Desc_Update extends StatefulWidget {
  final Property property;
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  Title_Desc_Update({
    Key? key,
    required this.property,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  _Title_Desc_UpdateState createState() => _Title_Desc_UpdateState();
}

class _Title_Desc_UpdateState extends State<Title_Desc_Update> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Amenities> selectedAmenities = [];
  double progress = 2 / 7; // Current step 1 of 3

  @override
  void initState() {
    super.initState();
    print("Received property type: ${widget.property.propertyType}");
    print("Received property condition: ${widget.property.propertyCondition}");
    print("Title: ${widget.property.title}");
    print("Description: ${widget.property.description}");
    print("Nbr rooms: ${widget.property.nbrRooms}");
    print("Area: ${widget.property.totalArea}");

    // Initialize the area from the property model if it's already set
    titleController.text = widget.property.title ?? '';

    // Initialize selected number of rooms from property model if set
    descriptionController.text = widget.property.description ?? '';
  }

  void _updateProperty() {
    final List<String> amenitiesAsString = widget.selectedAmenities
        .map((amenity) => amenity.toString().split('.').last.toLowerCase())
        .toList();
    final Property updatedProperty = Property(
      description: descriptionController.text,
      fileUrls: [], // Updated after image upload
      userId: 'userId', // Ideally, this should come from your auth system
      title: titleController.text,
      price: widget.property.price,
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
                content: const Text(
                    "Le titre et la description de la propriété est Modifié avec succès."),
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
          // Utilisez SingleChildScrollView pour éviter les problèmes de débordement
          child: Column(
            children: <Widget>[
              const Padding(
                padding: const EdgeInsets.only(
                    top: 100.0, right: 20, left: 20, bottom: 40),
                child: Text(
                  "À présent, donnez un titre à votre annonce.",
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
                    top: 0.0, right: 20, left: 20, bottom: 40),
                child: Text(
                  "Les titres courts sont généralement les plus efficaces. Ne vous inquiétez pas, vous pourrez toujours le modifier plus tard.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Increased rounded corners for a more pronounced effect
                  ),
                  elevation:
                      6, // Increased elevation for a more noticeable shadow
                  child: Container(
                    height: 80, // Specified height for more space
                    color: Colors
                        .white, // Ensuring the entire container is fully white
                    padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical:
                            10), // Adjusted padding for consistent spacing
                    child: TextFormField(
                      controller: titleController,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black), // Clear and visible text style
                      decoration: InputDecoration(
                        hintText: "Entrez le titre de votre annonce",
                        hintStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 15,
                            color: Colors
                                .grey[600]), // Subtle and stylish hint text
                        border: InputBorder.none, // No border in any state
                        enabledBorder: InputBorder
                            .none, // No border when the TextFormField is enabled
                        focusedBorder: InputBorder
                            .none, // No border when the TextFormField is focused
                        disabledBorder: InputBorder
                            .none, // No border even when the TextFormField is disabled
                        contentPadding: EdgeInsets.zero,
                        filled: true, // Enable filling of the background
                        fillColor: Colors
                            .white, // Set the fill color to white// Removed internal padding to maximize space
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(top: 40.0, right: 80, left: 0, bottom: 20),
                child: Text(
                  "Créez votre description.",
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
                    top: 0.0, right: 20, left: 20, bottom: 40),
                child: Text(
                  "Racontez ce qui rend votre logement unique.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Increased rounded corners for a more pronounced effect
                  ),
                  elevation:
                      6, // Increased elevation for a more noticeable shadow
                  child: Container(
                    height: 130, // Specified height for more space
                    color: Colors
                        .white, // Ensuring the entire container is fully white
                    padding: EdgeInsets.all(
                        15), // Padding applied here for consistent spacing
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines:
                          null, // Allows for multiple lines of text, adjusting internally
                      keyboardType: TextInputType
                          .multiline, // Suitable for multi-line text input
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black), // Clear and visible text style
                      decoration: InputDecoration(
                        hintText: "Décrivez ce qui rend votre logement unique",
                        hintStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 15,
                            color: Colors
                                .grey[600]), // Subtle and stylish hint text
                        border: InputBorder.none, // No border in any state
                        enabledBorder: InputBorder
                            .none, // No border when the TextFormField is enabled
                        focusedBorder: InputBorder
                            .none, // No border when the TextFormField is focused
                        disabledBorder: InputBorder
                            .none, // No border even when the TextFormField is disabled
                        contentPadding: EdgeInsets.zero,
                        filled: true, // Enable filling of the background
                        fillColor: Colors
                            .white, // Set the fill color to white // Removed internal padding to maximize space
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
  }
}
