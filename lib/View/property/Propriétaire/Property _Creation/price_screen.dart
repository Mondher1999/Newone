import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/amenities_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class EighthScreen extends StatefulWidget {
  final Property property;
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  EighthScreen(
      {Key? key,
      required this.property,
      required this.images,
      required this.selectedAmenities})
      : super(key: key);

  @override
  State<EighthScreen> createState() => _EightthScreenState();
}

class _EightthScreenState extends State<EighthScreen> {
  final TextEditingController priceController = TextEditingController();
  List<XFile>? _imageList = [];
  double progress = 7 / 7; // Current step 1 of 3

  @override
  void initState() {
    super.initState();
    priceController.addListener(_updateButtonState);
    if (widget.property.price != null && widget.property.price.isNotEmpty) {
      priceController.text = widget.property.price;
    }

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

  @override
  void dispose() {
    // Remove listeners and dispose controllers when the widget is disposed of
    priceController.removeListener(_updateButtonState);
    priceController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    // Call setState to update the UI based on text changes
    setState(() {});
  }

  void _submitProperty() {
    if (priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir un prix avant de continuer."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final List<String> amenitiesAsString = widget.selectedAmenities
          .map((amenity) => amenity.toString().split('.').last.toLowerCase())
          .toList();

      final Property property = Property(
        id: '',
        description: widget.property.description,
        userId: 'userId',
        title: widget.property.title,
        price: priceController.text,
        totalArea: widget.property.totalArea,
        city: "city",
        propertyType: widget.property.propertyType,
        address: 'address',
        region: widget.property.region,
        propertyCondition: widget.property.propertyCondition,
        nbrRooms: widget.property.nbrRooms,
        lat: widget.property.lat,
        lng: widget.property.lng,
        amenities: amenitiesAsString,
      );

      List<String> imagePaths = widget.images.map((x) => x.path).toList();
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
      BlocProvider.of<PropertyBloc>(context).add(AddProperty(
        property: property,
        imagePaths: imagePaths,
        userId: authUser.id,
      ));
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
    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertyCreationSuccess) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Succès'),
                content: const Text('La propriété a été ajoutée avec succès.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      final AuthUser authUser =
                          AuthUser.fromFirebase(firebaseUser!);
                      context.read<AuthBloc>().add(SetAsProprietaire(authUser));
                    },
                    child: const Text('Quitter'),
                  ),
                ],
              );
            },
          );
        } else if (state is PropertyCreating) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(
                      child: Text(
                          "S'il vous plaît attendez jusqu'à l'ajout de votre annonce")),
                ],
              ),
              duration: Duration(
                  seconds:
                      4), // Optional: adjust the duration according to the expected wait time
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
                    EdgeInsets.only(top: 80.0, right: 20, left: 20, bottom: 20),
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
        const SizedBox(width: 120), // Space between text and button
        TextButton(
          onPressed: (priceController.text.isNotEmpty)
              ? _submitProperty
              : null, // Désactiver le bouton si les conditions ne sont pas remplies
          child: const Text('Confirmer'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: (priceController.text.isNotEmpty)
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
        builder: (context) => SeventhScreen(
          property: widget.property,
          images: widget.images,
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
