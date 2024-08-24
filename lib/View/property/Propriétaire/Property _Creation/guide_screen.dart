import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/condition_type_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';

class FirstScreen extends StatefulWidget {
// Property model passed from the first screen
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  FirstScreen({Key? key, required this.images, required this.selectedAmenities})
      : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final Property property = Property(
      id: '',
      description: '',
      userId: '',
      title: '',
      price: '',
      totalArea: '',
      nbrRooms: '',
      address: '',
      city: '',
      region: '',
      propertyCondition: '',
      propertyType: '',
      amenities: [],
      lat: 1.3,
      lng: 1.2);

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
    // Dynamic sizing based on the screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05; // 5% of the screen width

    return Scaffold(
      body: SingleChildScrollView(
        // Added to ensure the content fits on smaller devices
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: 50.0, right: screenWidth * 0.20), // Adjusted dynamically
              child: Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _showExitConfirmationDialog(context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
              child: Text(
                "Commencer sur Madidou, c'est facile",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.06, // Dynamic text size
                ),
              ),
            ),
            // Sections are wrapped in Padding that is responsive
            Padding(
              padding: EdgeInsets.all(padding),
              child: _buildSection(
                  context,
                  'Parlez-nous de votre logement',
                  "Fournissez quelques détails essentiels, tels que l'emplacement de votre logement et sa capacité d'accueil.",
                  'assets/images/litv3.png'),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(padding),
              child: _buildSection(
                  context,
                  'Faites en sorte de vous démarquer',
                  'Ajouter au moins 3 photos, un titre et une description. Nous allons vous aider.',
                  'assets/images/armoirev2.png'),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(padding),
              child: _buildSection(
                  context,
                  'Terminer et publiez',
                  'Fixez un prix initial et mettez votre annonce en ligne.',
                  'assets/images/portev2.png'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Assume all property details are collected and updated
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondScreen(
                        property: property,
                        images: widget.images,
                        selectedAmenities: widget.selectedAmenities,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Commencer',
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      const Color.fromARGB(255, 255, 112, 137), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String description,
      String imagePath) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.045, // Responsive font size
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: screenWidth * 0.035, // Responsive font size
                  color: Colors.grey[600],
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: screenWidth * 0.10), // Dynamic spacing
        Expanded(
          flex: 1,
          child: Image.asset(imagePath),
        ),
      ],
    );
  }
}
