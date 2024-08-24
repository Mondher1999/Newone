import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/property_detail_update_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:madidou/data/model/property.dart';

class Amenities_Update_ extends StatefulWidget {
  final Property property;
  final List<XFile> images;

  final List<Amenities> selectedAmenities;
  Amenities_Update_({
    Key? key,
    required this.property,
    required this.images,
    re,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  State<Amenities_Update_> createState() => _Amenities_Update_State();
}

class _Amenities_Update_State extends State<Amenities_Update_> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController priceController = TextEditingController();
  List<Amenities> selectedAmenities = [];
  final TextEditingController areaController = TextEditingController();
  double progress = 6 / 7; // Current step 1 of 3

  @override
  void initState() {
    super.initState();
    // print("Price: ${widget.property.price}");
    selectedAmenities = List<Amenities>.from(widget.selectedAmenities);
  }

  void _updateProperty() {
    final List<String> amenitiesAsString = selectedAmenities
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

  String getPropertyAmenitiesDisplayName(Amenities amenities) {
    switch (amenities) {
      case Amenities.air_conditionne:
        return 'air_conditionne';
      case Amenities.ascenseur:
        return 'Ascenseur';
      case Amenities.parking:
        return 'Parking';
      case Amenities.cave:
        return 'Cave';
      case Amenities.jardin:
        return 'Jardin';
      case Amenities.balcon_terrasse:
        return 'Balcon / Terrasse';
      case Amenities.piscine:
        return 'Piscine';
      case Amenities.renove:
        return 'Rénové';
      default:
        return 'Inconnu';
    }
  }

  String getAmenityDisplayName(Amenities amenity) {
    switch (amenity) {
      case Amenities.air_conditionne:
        return 'Air Conditioned';
      case Amenities.ascenseur:
        return 'Ascenseur';
      case Amenities.parking:
        return 'Parking';
      case Amenities.cave:
        return 'Cave';
      case Amenities.jardin:
        return 'Jardin';
      case Amenities.balcon_terrasse:
        return 'Balcon / Terrasse';
      case Amenities.piscine:
        return 'Piscine';
      case Amenities.renove:
        return 'Rénové';
      default:
        return 'Inconnu';
    }
  }

  IconData getIconForAmenity(Amenities amenity) {
    switch (amenity) {
      case Amenities.ascenseur:
        return Icons.elevator;
      case Amenities.parking:
        return Icons.local_parking;
      case Amenities.cave:
        return Icons.door_back_door;
      case Amenities.jardin:
        return Icons.nature_sharp;
      case Amenities.air_conditionne:
        return Icons.air;
      case Amenities.piscine:
        return Icons.pool;
      case Amenities.balcon_terrasse:
        return Icons.balcony;
      case Amenities.renove:
        return Icons.format_paint;
      // Ajoutez d'autres cas selon vos besoins
      default:
        return Icons.question_mark;
    }
  }

  Widget _buildPropertyAmenitiesSelector(Amenities type) {
    bool isSelected = selectedAmenities.contains(type);
    IconData iconData =
        getIconForAmenity(type); // Assume you have a method to get the icon

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected
              ? selectedAmenities.remove(type)
              : selectedAmenities.add(type);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(
            8), // Ajoute un espacement externe autour de chaque carré
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color:
                const Color.fromARGB(255, 255, 112, 137), // Couleur de bordure
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0), // Ajuste le padding pour agrandir le carré
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Adapte la Row à la taille de son contenu
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF5e5f99)), // Ajoute l'icône
              const SizedBox(width: 10), // Espacement entre l'icône et le texte
              Text(
                getPropertyAmenitiesDisplayName(
                    type), // Utilisez la fonction d'aide ici
                overflow: TextOverflow.ellipsis, // Gère le débordement
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
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
                    "les Commodités de l'annonce est Modifié avec succès."),
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
                  EdgeInsets.only(top: 80.0, right: 20, left: 20, bottom: 40),
              child: Text(
                "Quelles sont les commodités disponibles dans votre bien immobilier ? Veuillez sélectionner toutes les options applicables.",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                        "Commodités",
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
            const SizedBox(height: 40),
            Wrap(
              spacing: 15, // Espacement horizontal
              children: Amenities.values
                  .map((type) => _buildPropertyAmenitiesSelector(type))
                  .toList(),
            ),
            const SizedBox(height: 70),
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
          selectedAmenities: [],
        ),
      ),
    );
  }
}
