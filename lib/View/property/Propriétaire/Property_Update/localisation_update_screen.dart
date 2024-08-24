import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Locataire/Filters/map_selection_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/nrbroom_area_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/select_images_screen.dart';
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
import 'package:http/http.dart' as http;

class Localisation_Update_Screen extends StatefulWidget {
  final Property property;
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  Localisation_Update_Screen({
    Key? key,
    required this.property,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  _Localisation_Update_ScreenState createState() =>
      _Localisation_Update_ScreenState();
}

class _Localisation_Update_ScreenState
    extends State<Localisation_Update_Screen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();
  String searchTermm = ''; // Add this line

  final TextEditingController priceController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  List<Amenities> selectedAmenities = [];

  final TextEditingController fieldTextEditingController =
      TextEditingController();
  double progress = 4 / 7; // Current step 1 of 3
  String? selectedLocation; // Variable to hold the selected location

  String? selectedRegion;

  List<String> regions = [
    "Pas de sélection",
    'Île de France',
    'Bretagne',
    'Normandie',
    'Grand Est',
    'Pays de la Loire',
    'Hauts de France',
    'Centre Val de Loire'
  ];
  @override
  void initState() {
    super.initState();
    if (regions.contains(widget.property.region)) {
      // Ensure that the region from the widget is valid and in the list
      selectedRegion = widget.property.region;
    } else if (regions.isNotEmpty) {
      // Safely set the first item of the list if no region is pre-selected
      selectedRegion = regions.first;
    } else {
      // Handle the case where no regions are available
      selectedRegion = null;
    }
// Default to the first region if none is set

    if (widget.property.lat != 1.3 && widget.property.lng != 1.3) {
      selectedLocation =
          "Location set at ${widget.property.lat}, ${widget.property.lng}";
    }

    print("Received property details: ${widget.property}");
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
      propertyType: widget.property.propertyType,
      address: widget.property.address,
      region: selectedRegion.toString(),
      propertyCondition: widget.property.propertyCondition,
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

  Widget buildLocationPickerCard() {
    // Check if the location has been changed from the default (1.3, 1.3)
    bool isLocationSelected =
        widget.property.lat != 1.3 && widget.property.lng != 1.3;

    // Define colors, icons, and messages based on the selection status
    Color backgroundColor =
        isLocationSelected ? Colors.green[600]! : Colors.red[600]!;
    IconData icon =
        isLocationSelected ? Icons.check_circle_outline : Icons.location_on;
    String message = isLocationSelected
        ? "L'emplacement est saisi correctement."
        : "Sélectionnez l'emplacement de votre logement.";

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(20),
      child: InkWell(
        onTap: _pickLocation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLocationSelected
                  ? [Colors.green[300]!, Colors.green[500]!]
                  : [Colors.red[300]!, Colors.red[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSelectionScreen()),
    );

    if (result != null) {
      setState(() {
        widget.property.lat = result['latitude'];
        widget.property.lng = result['longitude'];
        selectedLocation =
            "Location set at ${widget.property.lat}, ${widget.property.lng}";
      });
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

  Future<List<String>> getSuggestions(String input) async {
    var url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$input&key=63d1959b8a36466bbcdf01d4adcd9b30&language=en&pretty=1');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var results = json['results'] as List;
      // Transform the results to a List<String> using map
      List<String> suggestions =
          results.map((result) => result['formatted'] as String).toList();
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> regions = [
      "Pas de sélection",
      'Île de France',
      'Bretagne',
      'Normandie',
      'Grand Est',
      'Pays de la Loire',
      'Hauts de France',
      'Centre Val de Loire'
    ];
    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem<String>(
        value: null,
        child: Text("Select a Region"),
      ),
      ...regions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ];
    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertyUpdateSuccess) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Succès'),
                content: const Text(
                    "La localisation et la region de la propriété est Modifié avec succès."),
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
                "Où est situé votre bien ? Veuillez indiquer l'adresse précise et sélectionner la région correspondante dans la liste déroulante.",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                  mainAxisSize:
                      MainAxisSize.min, // Minimize the row size to fit content
                  children: [
                    Icon(
                      Icons.filter_list, // Example icon for "Type de bien"
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Localisation",
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
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: buildLocationPickerCard(),
            ),
            const Padding(
              padding: EdgeInsets.all(10.0),
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
                        "Region",
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
            ),
            const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 112, 137),
                      width: 2),
                  color: Colors.white, // Background color for the dropdown
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value:
                        selectedRegion, // This can be null if no initial selection is made
                    hint: const Text(
                        "Select Region"), // Displayed when `selectedRegion` is null
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color.fromARGB(255, 255, 112, 137)),
                    items: regions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRegion = newValue;
                        widget.property.region =
                            newValue!; // Update the property's region
                      });
                    },
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 0),
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

  void _navigateTonextScreen() {
    if (widget.property.lat == 1.3 && widget.property.lng == 1.2 ||
        selectedRegion == regions.first) {
      // Show an alert dialog to inform the user to provide the necessary information
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Information manquante'),
            content: const Text(
                'Veuillez sélectionner un emplacement sur la carte et choisir une région.'),
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
      // If both fields are filled, update the property model and navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SixthScreen(
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
}
