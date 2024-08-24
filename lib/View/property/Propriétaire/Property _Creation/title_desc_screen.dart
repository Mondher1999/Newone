import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/condition_type_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/nrbroom_area_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/PropertyType.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ThirdScreen extends StatefulWidget {
  final Property property;
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  ThirdScreen(
      {Key? key,
      required this.property,
      required this.images,
      required this.selectedAmenities})
      : super(key: key);

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Amenities> selectedAmenities = [];
  double progress = 2 / 7; // Current step 1 of 3

  @override
  void initState() {
    super.initState();

    // Initialize the area from the property model if it's already set
    titleController.text = widget.property.title ?? '';

    // Initialize selected number of rooms from property model if set
    descriptionController.text = widget.property.description ?? '';
    titleController.addListener(_updateButtonState);
    descriptionController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers when the widget is disposed of
    titleController.removeListener(_updateButtonState);
    descriptionController.removeListener(_updateButtonState);
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    // Call setState to update the UI based on text changes
    setState(() {});
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
                final firebaseUser = FirebaseAuth.instance.currentUser;
                final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
                context.read<AuthBloc>().add(SetAsProprietaire(authUser));
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
    return Scaffold(
      body: SingleChildScrollView(
        // Utilisez SingleChildScrollView pour éviter les problèmes de débordement
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 80),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _showExitConfirmationDialog(context),
                ),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(top: 40.0, right: 20, left: 20, bottom: 20),
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
                      vertical: 10), // Adjusted padding for consistent spacing
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
                          color:
                              Colors.grey[600]), // Subtle and stylish hint text
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
                  top: 0.0, right: 20, left: 20, bottom: 30),
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
                          fontSize: 14,
                          color:
                              Colors.grey[600]), // Subtle and stylish hint text
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
    );
  }

  Widget _buildNavigationRow(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Ensures the row only takes up needed space
      children: [
        TextButton(
          onPressed: _navigateTopreviousScreen,
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
          onPressed: (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty)
              ? _navigateToNextScreen
              : null, // Désactiver le bouton si les conditions ne sont pas remplies
          child: const Text('Suivant'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty)
                ? const Color(0xFF5e5f99)
                : Colors
                    .grey, // Changer la couleur de fond en fonction de la validité de l'entrée
            textStyle: const TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: 15, // Taille du texte du bouton
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // Coins arrondis pour le bouton
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 27,
                vertical: 16), // Rembourrage personnalisé pour le bouton
          ),
        ),
      ],
    );
  }

  void _navigateTopreviousScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondScreen(
          property: widget.property,
          images: widget.images,
          selectedAmenities: widget.selectedAmenities,
        ),
      ),
    );
  }

  void _navigateToNextScreen() {
    // Regular expression pattern to exclude numbers
    RegExp regex = RegExp(r'^[a-zA-ZÀ-ÿ\s.,;:!()-]+$');

    // Check if the title or description fields are empty or contain numbers
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        !regex.hasMatch(titleController.text) ||
        !regex.hasMatch(descriptionController.text)) {
      // Show an alert dialog to inform the user to fill in all fields correctly
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Information manquante ou invalide'),
            content: Text(
                'Veuillez entrer un titre et une description sans chiffres.'),
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
        widget.property.title = titleController.text;
        widget.property.description = descriptionController.text;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FirthScreen(
            property: widget.property,
            images: widget.images,
            selectedAmenities: widget.selectedAmenities,
          ),
        ),
      );
    }
  }
}
