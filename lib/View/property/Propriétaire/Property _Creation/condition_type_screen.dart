import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/guide_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/title_desc_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/PropertyType.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SecondScreen extends StatefulWidget {
  final Property property; // Property model passed from the first screen
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  SecondScreen(
      {Key? key,
      required this.property,
      required this.images,
      required this.selectedAmenities})
      : super(key: key);

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  double progress = 1 / 7; // Current step 1 of 3

  List<PropertyCondition> selectedPropertyConditions = [];
  List<PropertyType> selectedPropertyType = [];
  IconData getIconForPropertyType(PropertyType type) {
    switch (type) {
      case PropertyType.Appartement:
        return Icons.apartment;
      case PropertyType.Maison:
        return Icons.house;
      // Ajoutez d'autres cas pour les différents types de propriété
      default:
        return Icons.landscape; // Une icône par défaut pour les cas non gérés
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize selectedPropertyType based on property type from the model
    if (widget.property.propertyType.isNotEmpty) {
      PropertyType type = PropertyType.values.firstWhere(
          (e) => e.toString().split('.').last == widget.property.propertyType,
          orElse: () => PropertyType
              .Appartement // Default or a better approach could be handled
          );
      selectedPropertyType.add(type);
    }

    // Initialize selectedPropertyConditions based on property condition from the model
    if (widget.property.propertyCondition.isNotEmpty) {
      PropertyCondition condition = PropertyCondition.values.firstWhere(
          (e) =>
              e.toString().split('.').last == widget.property.propertyCondition,
          orElse: () => PropertyCondition
              .Meuble // Default or a better approach could be handled
          );
      selectedPropertyConditions.add(condition);
    }
  }

  void _updatePropertyType(PropertyType type) {
    setState(() {
      if (selectedPropertyType.contains(type)) {
        // If the type is already selected, deselect it
        selectedPropertyType.remove(type);
        widget.property.propertyType = '';
      } else {
        // Clear any previous selections and add the new selection
        selectedPropertyType.clear();
        selectedPropertyType.add(type);
        widget.property.propertyType = type.toString().split('.').last;
      }
    });
    print("Updated Property Type to: ${widget.property.propertyType}");
  }

  void _updatePropertyCondition(PropertyCondition condition) {
    setState(() {
      if (selectedPropertyConditions.contains(condition)) {
        // If the condition is already selected, deselect it
        selectedPropertyConditions.remove(condition);
        widget.property.propertyCondition = '';
      } else {
        // Deselect all and select the new one
        selectedPropertyConditions.clear();
        selectedPropertyConditions.add(condition);
        widget.property.propertyCondition =
            condition.toString().split('.').last;
      }
    });
  }

  String getPropertyConditionDisplayName(PropertyCondition condition) {
    switch (condition) {
      case PropertyCondition.Meuble:
        return 'Meuble';
      case PropertyCondition.Non_Meuble:
        return 'Non Meuble';
      default:
        return 'Inconnu';
    }
  }

  IconData getIconForPropertyCondition(PropertyCondition condition) {
    switch (condition) {
      case PropertyCondition.Meuble:
        return Icons.chair; // Exemple d'icône pour 'Meublé'
      case PropertyCondition.Non_Meuble:
        return Icons.chair_alt; // Exemple d'icône pour 'Non Meublé'
      default:
        return Icons.question_mark; // Icône par défaut
    }
  }

  Widget _buildPropertyConditionSelector(PropertyCondition type) {
    bool isSelected = selectedPropertyConditions.contains(type);
    IconData icon = getIconForPropertyCondition(type);

    return GestureDetector(
      onTap: () => _updatePropertyCondition(type),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 112, 137),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : const Color(0xFF5e5f99)),
            const SizedBox(width: 8),
            Text(
              getPropertyConditionDisplayName(type),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeSelector(PropertyType type) {
    bool isSelected = selectedPropertyType.contains(type);
    IconData iconData =
        getIconForPropertyType(type); // Get the corresponding icon

    return GestureDetector(
      onTap: () => _updatePropertyType(type),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 112, 137),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData,
                color: isSelected ? Colors.white : const Color(0xFF5e5f99)),
            const SizedBox(width: 8), // Space between the icon and the text
            Text(
              type.toString().split('.').last,
              overflow: TextOverflow.ellipsis, // Manage text overflow
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
    double screenWidth = MediaQuery.of(context)
        .size
        .width; // Obtain screen width for responsive design
    double screenHeight = MediaQuery.of(context)
        .size
        .height; // Obtain screen height for responsive design

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView for scrollable behavior on smaller devices
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.05,
                  right: screenWidth * 0.2), // Responsive padding
              child: Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _showExitConfirmationDialog(context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.025, // Responsive vertical padding
                horizontal: screenWidth * 0.05, // Responsive horizontal padding
              ),
              child: Text(
                "Parmi les propositions suivantes, laquelle décrit le mieux votre logement ?",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: screenWidth * 0.05, // Responsive font size
                ),
                textAlign:
                    TextAlign.center, // Center text for better readability
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  // Implement what happens when you tap this section
                },
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Color.fromARGB(255, 255, 112, 137)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Type de bien",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.04, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15, // Horizontal spacing
              runSpacing: 10, // Vertical spacing for better readability
              children: PropertyType.values
                  .map((type) => _buildPropertyTypeSelector(type))
                  .toList(),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  // Implement what happens when you tap this section
                },
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Color.fromARGB(255, 255, 112, 137)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Type de Location",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.04, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15, // Horizontal spacing
              runSpacing: 10, // Vertical spacing for better readability
              children: PropertyCondition.values
                  .map((type) => _buildPropertyConditionSelector(type))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, // Responsive horizontal padding
                vertical: screenHeight * 0.02, // Responsive vertical padding
              ),
              child: LinearPercentIndicator(
                lineHeight: 10.0,
                percent: progress,
                backgroundColor: Colors.grey[300],
                linearGradient: LinearGradient(
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
          onPressed: (selectedPropertyType.isNotEmpty &&
                  selectedPropertyConditions.isNotEmpty)
              ? _navigateToNextScreen
              : null, // Désactiver le bouton si les conditions ne sont pas remplies
          child: const Text('Suivant'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: (selectedPropertyType.isNotEmpty &&
                    selectedPropertyConditions.isNotEmpty)
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

  void _navigateToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThirdScreen(
          property: widget.property,
          images: widget.images,
          selectedAmenities: widget.selectedAmenities,
        ),
      ),
    );
  }

  void _navigateTopreviousScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirstScreen(
          images: widget.images,
          selectedAmenities: widget.selectedAmenities,
        ),
      ),
    );
  }
}
