import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/localisation_screen.dart';
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

class Nrbroom_Area_Update_Screen extends StatefulWidget {
  final Property property; // Property model passed from the first screen
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  Nrbroom_Area_Update_Screen({
    Key? key,
    required this.property,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  State<Nrbroom_Area_Update_Screen> createState() =>
      _Nrbroom_Area_Update_ScreenState();
}

class _Nrbroom_Area_Update_ScreenState
    extends State<Nrbroom_Area_Update_Screen> {
  final TextEditingController areaController = TextEditingController();
  double progress = 3 / 7; // Current step 1 of 3
  List<Amenities> selectedAmenities = [];
  List<int> selectedNumberOfRooms = [];

  @override
  void initState() {
    super.initState();
    // print("Received property type: ${widget.property.propertyType}");
    // print("Received property condition: ${widget.property.propertyCondition}");
    // print("Title: ${widget.property.title}");
    // print("Description: ${widget.property.description}");
    // print("Nbr rooms: ${widget.property.nbrRooms}");
    // print("Area: ${widget.property.totalArea}");

    // Initialize the area from the property model if it's already set
    areaController.text = widget.property.totalArea ?? '';
    // print("Nbr rooms: ${widget.property.nbrRooms}");
    // print("Area: ${widget.property.totalArea}");

    // Initialize selected number of rooms from property model if set
    if (widget.property.nbrRooms.isNotEmpty) {
      int nbrRooms = int.tryParse(widget.property.nbrRooms) ?? 0;
      if (nbrRooms > 0) {
        selectedNumberOfRooms = [nbrRooms];
      }
    }
  }

  void _updateProperty() {
    int nbrRooms =
        selectedNumberOfRooms.isNotEmpty ? selectedNumberOfRooms.last : 0;

    final List<String> amenitiesAsString = widget.selectedAmenities
        .map((amenity) => amenity.toString().split('.').last.toLowerCase())
        .toList();
    final Property updatedProperty = Property(
      description: widget.property.description,
      fileUrls: [], // Updated after image upload
      userId: 'userId', // Ideally, this should come from your auth system
      title: widget.property.title,
      price: widget.property.price,
      totalArea: areaController.text,
      nbrRooms: nbrRooms.toString(),
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

  Widget _buildRoomSelector(int roomNumber) {
    bool isSelected =
        selectedNumberOfRooms.contains(roomNumber); // Mise à jour ici
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedNumberOfRooms.remove(roomNumber);
          } else {
            selectedNumberOfRooms
                .clear(); // Clear previous selections if only one should be selected
            selectedNumberOfRooms.add(roomNumber);
          }
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 112, 137),
            width: isSelected ? 0 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              roomNumber == 5 ? '5+' : roomNumber.toString(),
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
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
                    "Nombre de chambre et surface de la propriété est Modifié avec succès."),
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
          child: Column(
            children: <Widget>[
              const Padding(
                padding: const EdgeInsets.only(
                    top: 90.0, right: 20, left: 20, bottom: 40),
                child: Text(
                  "Quelle est la superficie totale de votre bien et combien de chambres contient-il ? Veuillez fournir ces détails pour aider les intéressés à comprendre l'espace disponible.",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 0),
              InkWell(
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple, // A vibrant color for more appeal
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      // A subtle gradient for a more dynamic look
                      colors: [
                        Colors.deepPurple,
                        Color.fromARGB(255, 255, 112, 137)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Surface: m²",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 255, 112, 137), // Container background color
                    borderRadius: BorderRadius.circular(
                        8), // Rounded corners for the container
                  ),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: areaController,
                        decoration: InputDecoration(
                          hintText: 'Entrer la superficie',
                          filled: true,
                          fillColor: Colors.white, // TextField fill color
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 112, 137),
                                width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 112, 137),
                                width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.only(
                              left: 20, right: 50), // Adjust padding
                          hintStyle: const TextStyle(
                            color: Color(0xFF5e5f99), // Hint text color
                            fontSize: 17,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF5e5f99), // Input text color
                          fontSize: 16,
                        ),
                      ),
                      const Positioned(
                        right: 15,
                        child: Icon(
                          Icons
                              .square_foot_sharp, // Icon next to the text field
                          color: Color(0xFF5e5f99), // Icon color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: InkWell(
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Colors.deepPurple, // A vibrant color for more appeal
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        // A subtle gradient for a more dynamic look
                        colors: [
                          Colors.deepPurple,
                          Color.fromARGB(255, 255, 112, 137)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize
                          .min, // Minimize the row size to fit content
                      children: [
                        Icon(
                          Icons.filter_list, // Example icon for "Type de bien"
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Nombre de chambre",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    List.generate(5, (index) => _buildRoomSelector(index + 1)),
              ),
              const SizedBox(height: 30),
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
        const SizedBox(width: 130), // Space between text and button
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

  void _navigateToNextScreen() {
    RegExp numRegExp = RegExp(
        r'^\d+(\.\d+)?$'); // Expression régulière pour correspondre à des nombres avec ou sans décimales

    // Vérifiez si le champ de la superficie est vide, n'est pas un nombre valide, ou si aucun nombre de chambres n'a été sélectionné
    if (areaController.text.isEmpty ||
        !numRegExp.hasMatch(areaController.text) ||
        selectedNumberOfRooms.isEmpty) {
      String errorMessage =
          'Veuillez vous assurer que tous les champs sont correctement remplis.';
      if (areaController.text.isEmpty ||
          !numRegExp.hasMatch(areaController.text)) {
        errorMessage = 'Veuillez entrer un nombre valide pour la superficie.';
      } else if (selectedNumberOfRooms.isEmpty) {
        errorMessage = 'Veuillez sélectionner le nombre de chambres.';
      }

      // Show an alert dialog to inform the user to provide necessary information
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Information manquante'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // If both fields are filled correctly, update the property model and navigate to the next screen
      setState(() {
        widget.property.totalArea = areaController.text;
        widget.property.nbrRooms = selectedNumberOfRooms.last.toString();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FifthScreen(
            property: widget.property,
            images: widget.images,
            selectedAmenities: widget.selectedAmenities,
          ),
        ),
      );
    }
  }
}
