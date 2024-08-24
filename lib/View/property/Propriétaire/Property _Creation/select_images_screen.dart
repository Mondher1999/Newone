import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/amenities_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/localisation_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:image_picker/image_picker.dart';

class SixthScreen extends StatefulWidget {
  final Property property; // Property model passed from the first screen
  final List<XFile> images; // Ensure this matches the type expected
  final List<Amenities> selectedAmenities;

  SixthScreen(
      {Key? key,
      required this.property,
      required this.images,
      required this.selectedAmenities})
      : super(key: key);

  @override
  State<SixthScreen> createState() => _SixthScreenState();
}

class _SixthScreenState extends State<SixthScreen> {
  final TextEditingController titleController = TextEditingController();
  List<XFile>? _imageList = [];
  final TextEditingController descriptionController = TextEditingController();
  CarouselController _carouselController =
      CarouselController(); // Add this line

  final TextEditingController priceController = TextEditingController();
  List<Amenities> selectedAmenities = [];
  final TextEditingController areaController = TextEditingController();
  double progress = 5 / 7; // Current step 1 of 3

  @override
  void initState() {
    super.initState();
    // Initialize the image list with the passed images if any
    _imageList =
        widget.images.isNotEmpty ? List<XFile>.from(widget.images) : [];
    // Other initializations...

    print("Received property latitude: ${widget.property.lat}");
    print("Received property longitude: ${widget.property.lng}");
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

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        if (_imageList == null) {
          _imageList =
              selectedImages; // Initial assignment if no images were picked before
        } else {
          _imageList!.addAll(
              selectedImages); // Appending new images to the existing list
        }
      });
    } else {
      // Optionally, show an error if no images are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez sélectionner au moins 3 images"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageCarousel() {
    EdgeInsets padding = (_imageList != null && _imageList!.isNotEmpty)
        ? EdgeInsets.only(top: 20) // Add top padding if images are selected
        : EdgeInsets.zero; // No padding if no images selected

    return Padding(
      padding: padding,
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: true,
          viewportFraction: 0.8, // Use a larger viewport fraction
          aspectRatio:
              19 / 12, // Standard widescreen aspect ratio for larger display
          onPageChanged: (index, reason) {
            setState(() {
              // Optionally update some state or UI when the page changes
            });
          },
        ),
        items: _imageList?.map((item) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Image.file(File(item.path),
                          fit: BoxFit.cover, width: 1000.0),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[800]),
                      onPressed: () => _confirmDeletion(
                          item), // Updated to call confirmation dialog
                    ),
                  ),
                ],
              );
            }).toList() ??
            [],
      ),
    );
  }

  void _confirmDeletion(XFile item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous supprimer cette image ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () {
                setState(() {
                  _imageList!.remove(item);
                  _imageList = List<XFile>.from(
                      _imageList!); // Recreate the list to trigger update
                  Navigator.of(context).pop(); // Dismiss the dialog
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePickerCard() {
    // Check if images have been picked and adjust size accordingly
    double cardHeight =
        (_imageList != null && _imageList!.isNotEmpty) ? 70 : 150;
    double cardWidth =
        (_imageList != null && _imageList!.isNotEmpty) ? 170 : 300;
    double iconSize = (_imageList != null && _imageList!.isNotEmpty) ? 30 : 50;
    double fontSize = (_imageList != null && _imageList!.isNotEmpty) ? 14 : 16;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500), // Duration of the animation
      curve: Curves.fastOutSlowIn, // Animation curve
      height: cardHeight,
      width: cardWidth,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        onTap: _pickImages,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.camera_alt, size: iconSize, color: Colors.deepPurple),
            SizedBox(height: 10),
            Text(
              "Tap to add images",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedImageTile(File imageFile, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.redAccent : Colors.transparent,
          width: 3,
        ),
      ),
      child: Image.file(imageFile, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmationDialog(context),
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(top: 50.0, right: 10),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Text(
                "Ajoutez quelques photos de votre logement.",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Pour commencer, vous aurez besoin de 5 photos. Vous pourrez en ajouter d'autres ou faire des modifications plus tard.",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 0),
                child: _buildImagePickerCard(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20), // Add spacing between previous content
                  _buildImageCarousel(),
                  SizedBox(
                      height:
                          20), // Add spacing between image carousel and linear progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  SizedBox(
                      height:
                          15), // Add spacing between linear progress indicator and navigation row
                  _buildNavigationRow(context),
                ],
              ),
            ),
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
          onPressed: (_imageList != null && _imageList!.isNotEmpty)
              ? _navigateTonextScreen
              : null, // Désactiver le bouton si les conditions ne sont pas remplies
          child: const Text('Suivant'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: (_imageList != null && _imageList!.isNotEmpty)
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

  void _navigateTonextScreen() {
    if (_imageList != null && _imageList!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeventhScreen(
            property: widget.property,
            images: _imageList!,
            selectedAmenities: widget.selectedAmenities,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez sélectionner 3 images avant de continuer"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateTopreviousScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FifthScreen(
          property: widget.property,
          images: _imageList!,
          selectedAmenities: widget.selectedAmenities,
        ),
      ),
    );
  }
}
