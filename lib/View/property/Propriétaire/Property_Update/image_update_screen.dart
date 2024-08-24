import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/amenities_screen.dart';
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
import 'package:image_picker/image_picker.dart';

class Image_Update_Screen extends StatefulWidget {
  final Property property; // Property model passed from the first screen
  final List<XFile> images; // Accept a list of URLs
  final List<Amenities> selectedAmenities;

  Image_Update_Screen({
    Key? key,
    required this.property,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  State<Image_Update_Screen> createState() => _Image_Update_ScreenState();
}

class _Image_Update_ScreenState extends State<Image_Update_Screen> {
  final TextEditingController titleController = TextEditingController();
  List<XFile>? _imageList = [];
  final TextEditingController descriptionController = TextEditingController();
  CarouselController _carouselController =
      CarouselController(); // Add this line

  final TextEditingController priceController = TextEditingController();
  List<Amenities> selectedAmenities = [];
  final TextEditingController areaController = TextEditingController();
  double progress = 5 / 7; // Current step 1 of 3
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageList =
        List<XFile>.from(widget.images); // Initialize with passed images
    print("Initialized with ${_imageList!.length} images.");
  }

  Future<void> _updatepropertyImage() async {
    if (_imageList != null && _imageList!.isNotEmpty) {
      for (XFile image in _imageList!) {
        final File imageFile = File(image.path);
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
        BlocProvider.of<PropertyBloc>(context, listen: false).add(
            UpdatePropertyImage(widget.property.id, imageFile, authUser.id));
      }
// Optionally, show a message after all images have been submitted for update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No images selected to update."),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _imageList!.addAll(selectedImages); // Add new images to existing list
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one image."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildImageCarousel() {
    List<Widget> allItems = [];

// Asynchronously load each network image and add to carousel if successful
    widget.property.fileUrls.forEach((url) {
      var imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        width: 1000.0,
        errorBuilder: (context, error, stackTrace) {
// Don't add anything if there's an error
          return Container();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
// Image loaded successfully
            return Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: child,
              ),
            );
          } else {
// Still loading
            return Center(
                child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ));
          }
        },
      );
// Add to carousel items
      if (imageWidget != null) {
        allItems.add(imageWidget);
      }
    });

// Load local images
    _imageList?.forEach((file) {
      File imageFile = File(file.path);
      var localImageWidget = Image.file(imageFile,
          fit: BoxFit.cover,
          width: 1000.0, errorBuilder: (context, error, stackTrace) {
// Don't add anything if there's an error
        return Container();
      });

      allItems.add(Container(
        margin: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: localImageWidget,
        ),
      ));
    });
// Add local images to the carousel if available
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        aspectRatio: 19 / 12,
        onPageChanged: (index, reason) {
          setState(() {
// Optionally update some state or UI when the page changes
          });
        },
      ),
      items: allItems.isEmpty
          ? [const Center(child: Text("No images to display"))]
          : allItems,
    );
  }

  void confirmDeletion(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Do you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _imageList!
                      .removeWhere((item) => item.path == imageFile.path);
                  Navigator.of(context)
                      .pop(); // Close the dialog after deleting
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletion(XFile item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous supprimer cette image ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Supprimer'),
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
        (_imageList != null && _imageList!.isNotEmpty) ? 80 : 150;
    double cardWidth =
        (_imageList != null && _imageList!.isNotEmpty) ? 250 : 300;
    double iconSize = (_imageList != null && _imageList!.isNotEmpty) ? 30 : 50;
    double fontSize = (_imageList != null && _imageList!.isNotEmpty) ? 14 : 16;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), // Duration of the animation
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
            offset: const Offset(0, 3),
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
            const SizedBox(height: 10),
            Text(
              "Touchez pour ajouter des images",
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
      duration: const Duration(milliseconds: 300),
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
    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertyUpdatingSuccessImage) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Succès'),
                content: const Text(
                    "Les images de la propriété est Modifié avec succès."),
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
        } else if (state is PropertyUpdatingImage) {
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
                  seconds:
                      2), // Optional: adjust the duration according to the expected wait time
              backgroundColor: Color.fromARGB(255, 255, 112, 137),
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(top: 90.0, right: 20, left: 20, bottom: 20),
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
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: _buildImagePickerCard(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: buildImageCarousel(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 55.0, right: 20, left: 20, bottom: 20),
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
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 0, left: 10),
                child: _buildNavigationRow(context),
              ),
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
        const SizedBox(width: 110), // Space between text and button
        TextButton(
          onPressed: _imageList != null && _imageList!.isNotEmpty
              ? _updatepropertyImage
              : null,
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
        const SnackBar(
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
        builder: (context) => PropertyDetailUpdateScreen(
          property: widget.property,
          selectedAmenities: widget.selectedAmenities,
        ),
      ),
    );
  }
}
