import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/title_desc_screen.dart';
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

class Condition_Type_Update_Screen extends StatefulWidget {
  final Property property; // Property model passed from the first screen
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  Condition_Type_Update_Screen({
    Key? key,
    required this.property,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  State<Condition_Type_Update_Screen> createState() =>
      _Condition_Type_Update_ScreenState();
}

class _Condition_Type_Update_ScreenState
    extends State<Condition_Type_Update_Screen> {
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

  String enumName(Enum e) {
    return e.toString().split('.').last;
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
      price: widget.property.price,
      totalArea: widget.property.totalArea,
      nbrRooms: widget.property.nbrRooms,
      city: widget.property.city,
      propertyType: selectedPropertyType.isNotEmpty
          ? enumName(selectedPropertyType.last)
          : '',

      address: widget.property.address,
      region: widget.property.region,
      propertyCondition: selectedPropertyConditions.isNotEmpty
          ? enumName(selectedPropertyConditions.last)
          : '',
      id: widget.property.id,
      amenities: amenitiesAsString,
      lat: widget.property.lat,
      lng: widget.property.lng,
      // Add your logic for userId
    );
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
    // Pass imagePath if a new image is selected; otherwise, pass null
    BlocProvider.of<PropertyBloc>(context)
        .add(UpdateProperty(updatedProperty, authUser.id));
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
    // print("Updated Property Type to: ${widget.property.propertyType}");
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
                    "Type et condition de la propriété est Modifié avec succès."),
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
        body: Column(
          children: <Widget>[
            const Padding(
              padding:
                  EdgeInsets.only(top: 90.0, right: 20, left: 20, bottom: 40),
              child: Text(
                "Parmi les propositions suivantes, laquelle décrit le mieux votre logement ?",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
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
                        "Type de bien",
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
            const SizedBox(height: 20),
            Wrap(
              spacing: 15, // Espacement horizontal
              children: PropertyType.values
                  .map((type) => _buildPropertyTypeSelector(type))
                  .toList(),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: SizedBox(
                width:
                    350, // Set the width of the container to determine the length of the divider
                child: Divider(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
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
                        "Type de Location",
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
            const SizedBox(height: 20),
            Wrap(
              spacing: 15, // Espacement horizontal
              children: PropertyCondition.values
                  .map((type) => _buildPropertyConditionSelector(type))
                  .toList(),
            ),
            const SizedBox(height: 20),
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
          onPressed: (selectedPropertyType.isNotEmpty &&
                  selectedPropertyConditions.isNotEmpty)
              ? _updateProperty
              : null, // Désactiver le bouton si les conditions ne sont pas remplies
          child: const Text('Enregistrer'),
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
    if (selectedPropertyType.isEmpty || selectedPropertyConditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez sélectionner au moins un type de propriété et une condition.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
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
