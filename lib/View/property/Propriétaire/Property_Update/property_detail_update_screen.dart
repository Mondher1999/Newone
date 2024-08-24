import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/amenities_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/condition_type_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/localisation_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/nrbroom_area_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/price_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/image_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/title_desc_update_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailUpdateScreen extends StatefulWidget {
  final Property property;
  final List<Amenities> selectedAmenities;

  const PropertyDetailUpdateScreen({
    Key? key,
    required this.property,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  _PropertyDetailUpdateScreenState createState() =>
      _PropertyDetailUpdateScreenState();
}

class _PropertyDetailUpdateScreenState
    extends State<PropertyDetailUpdateScreen> {
  int _current = 0; // État pour suivre l'index actuel du carousel

  @override
  Widget build(BuildContext context) {
    double carouselHeight =
        MediaQuery.of(context).size.height * 0.1; // Taille du carousel

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
        default:
          return Icons.question_mark;
      }
    }

    Amenities? parseAmenity(String amenity) {
      for (var type in Amenities.values) {
        if (type.toString().split('.').last == amenity) {
          return type;
        }
      }
      return null; // or handle as needed if no match is found
    }

    String getPropertyAmenitiesDisplayName(Amenities amenities) {
      switch (amenities) {
        case Amenities.air_conditionne:
          return 'Air Condition';
        case Amenities.ascenseur:
          return 'Ascenseur';
        case Amenities.parking:
          return 'Parking';
        case Amenities.cave:
          return 'Cave';
        case Amenities.jardin:
          return 'Jardin';
        case Amenities.balcon_terrasse:
          return 'Balcon ou terrasse';
        case Amenities.piscine:
          return 'Piscine';
        case Amenities.renove:
          return 'Rénové';
        default:
          return 'Inconnu';
      }
    }

    // Example mapping functions:
    IconData getIconForCondition(String condition) {
      switch (condition) {
        case 'Meuble':
          return Icons.chair;
        case 'Non_Meuble':
          return Icons.chair_alt;
        // Add more cases as needed
        default:
          return Icons.question_mark;
      }
    }

    String getDisplayNameForCondition(String condition) {
      // Assuming the condition comes in a display-ready format
      switch (condition) {
        case 'Meuble':
          return "Meublé";
        case 'Non Meublé':
          return "Non Meublé";
        // Add more cases as needed
        default:
          return "Non Meublé";
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

    Widget buildPropertyConditionWidget(String condition) {
      IconData icon = getIconForCondition(widget.property
          .propertyCondition); // Ensure this function handles string to icon mapping
      String displayName = getDisplayNameForCondition(
          widget.property.propertyCondition); // Map string to display name

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white, // Light background for visibility
          borderRadius:
              BorderRadius.circular(15), // Rounded corners for modern look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow for depth
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 2), // Slight offset for 3D effect
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize
              .min, // Ensures the row takes up only the necessary space
          children: [
            Icon(icon,
                size: 30,
                color: const Color(
                    0xFF5e5f99)), // Icon with color matching the amenities widget
            const SizedBox(width: 10), // Spacing between icon and text
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(
                    255, 255, 112, 137), // Vibrant text color for emphasis
              ),
            ),
          ],
        ),
      );
    }

    Amenities? stringToAmenity(String str) {
      switch (str) {
        case 'air_conditionne':
          return Amenities.air_conditionne;
        case 'ascenseur':
          return Amenities.ascenseur;
        case 'parking':
          return Amenities.parking;
        case 'cave':
          return Amenities.cave;
        case 'jardin':
          return Amenities.jardin;
        case 'balcon_terrasse':
          return Amenities.balcon_terrasse;
        case 'piscine':
          return Amenities.piscine;
        case 'renove':
          return Amenities.renove;
        default:
          return null; // Handle unknown or malformed strings
      }
    }

    Widget buildAmenityWidget(String amenityString) {
      var amenity = parseAmenity(amenityString);
      if (amenity == null) {
        return const SizedBox(); // or some error handling widget
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(getIconForAmenity(amenity),
                size: 30, color: const Color(0xFF5e5f99)),
            const SizedBox(width: 10),
            Text(
              getPropertyAmenitiesDisplayName(amenity),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 112, 137),
              ),
            ),
          ],
        ),
      );
    }

    Future<void> _openMaps(double lat, double lng) async {
      final Uri url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      if (!await launchUrl(url)) {
        throw 'Could not launch $url';
      }
    }

    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertiesDeleteSucess) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Succès'),
                content:
                    const Text('La propriété a été supprimer avec succès.'),
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
        } else if (state is PropertyDeleting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(
                      child: Text(
                          "S'il vous plaît attendez jusqu'à la suppression de votre annonce")),
                ],
              ),
              duration: Duration(
                  milliseconds:
                      300), // Optional: adjust the duration according to the expected wait time
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
        appBar: AppBar(
          toolbarHeight:
              80.0, // Increase the height of the AppBar for more top padding
          title: const Text('Update Property'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 25, color: Colors.black),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              final firebaseUser = FirebaseAuth.instance.currentUser;
              final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
              context.read<AuthBloc>().add(SetAsProprietaire(authUser));
            },
          ),
          actions: <Widget>[
            const Expanded(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centering Row content
                children: [
                  SizedBox(width: 50),
                  Text(
                    "Outil de modification d'annonce",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert, size: 25, color: Colors.black),
              onSelected: (item) {
                switch (item) {
                  case 0:
                    // Insérez ici votre fonctionnalité de suppression
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette propriété ?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(), // Annuler l'opération
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Perform the deletion operation
                                final firebaseUser =
                                    FirebaseAuth.instance.currentUser;
                                final AuthUser authUser =
                                    AuthUser.fromFirebase(firebaseUser!);
                                BlocProvider.of<PropertyBloc>(context).add(
                                    DeleteProperty(
                                        widget.property.id, authUser.id));
                                Navigator.of(context).pop();
                                // Navigate to the next screen after the deletion is triggered
                              },
                              child: const Text('Supprimer'),
                            ),
                          ],
                        );
                      },
                    );
                    break;
                  // Ajoutez plus de cas pour d'autres éléments de menu si nécessaire
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Supprimer votre annonce'),
                ),
                // Vous pouvez ajouter plus d'éléments de menu ici
              ],
            )
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Title_Desc_Update(
                                    property: widget.property,
                                    images: [],
                                    selectedAmenities: [],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 20, left: 30, right: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize
                                      .min, // Use the smallest size that encloses the child
                                  children: <Widget>[
                                    const Text(
                                      "Titre",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            19, // Font size for description title
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            20), // Spacing between title and details
                                    Text(
                                      '${widget.property.title}',
                                      style: TextStyle(
                                        color: Colors.grey[
                                            800], // Text color for property details
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            15, // Font size for property details
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          // ignore: prefer_const_constructors
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Title_Desc_Update(
                                    property: widget.property,
                                    images: [],
                                    selectedAmenities: [],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 20, left: 30, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize
                                      .min, // Use the smallest size that encloses the child
                                  children: <Widget>[
                                    const Text(
                                      "Description",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            19, // Font size for description title
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            20), // Spacing between title and details
                                    Text(
                                      '${widget.property.propertyType} de ${widget.property.totalArea} m² composé de ${widget.property.nbrRooms} Chambres',
                                      style: TextStyle(
                                        color: Colors.grey[
                                            800], // Text color for property details
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            15, // Font size for property details
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () {
                              // Assuming fileUrls are local paths and need conversion to XFile
                              List<XFile> imageFiles = widget.property.fileUrls
                                  .map((path) => XFile(path))
                                  .toList();

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Image_Update_Screen(
                                    property: widget.property,

                                    images:
                                        imageFiles, // Pass the converted XFiles
                                    selectedAmenities: widget.selectedAmenities,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              height: 430,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 25.0),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 30.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Visite photo",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              20, // Font size for description title
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 20.0, left: 20),
                                    child: CarouselSlider.builder(
                                      itemCount:
                                          widget.property.fileUrls.length,
                                      itemBuilder: (BuildContext context,
                                              int itemIndex,
                                              int pageViewIndex) =>
                                          ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            18), // Coins arrondis du carrousel
                                        child: CachedNetworkImage(
                                          imageUrl: widget
                                              .property.fileUrls[itemIndex],
                                          fit: BoxFit.cover,
                                          width: double
                                              .infinity, // Utilise toute la largeur disponible
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      options: CarouselOptions(
                                        autoPlay: false,
                                        enlargeCenterPage: true,
                                        aspectRatio: 20 /
                                            9, // Ajustez selon les besoins de votre design
                                        viewportFraction:
                                            0.65, // Utilisez 1.0 pour occuper toute la largeur
                                        height: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.36, // Hauteur du carrousel ajustée ici
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () {
                              List<Amenities> amenitiesList = widget
                                  .property.amenities
                                  .map((str) => stringToAmenity(str))
                                  .where((item) => item != null)
                                  .cast<Amenities>()
                                  .toList();

                              print("Passing these amenities: $amenitiesList");

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Amenities_Update_(
                                    property: widget.property,

                                    images: [], // Make sure this list is supposed to be empty or updated accordingly
                                    selectedAmenities: amenitiesList,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 20, left: 30, right: 30),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize
                                        .min, // Use the smallest size that encloses the child
                                    children: <Widget>[
                                      const Text(
                                        "Ce que propose ce logement",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              18, // Font size for section title
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              20), // Spacing after the title
                                      Wrap(
                                        spacing: 15,
                                        runSpacing: 10,
                                        children: widget.property.amenities
                                            .map((amenity) =>
                                                buildAmenityWidget(amenity))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Condition_Type_Update_Screen(
                                    property: widget.property,
                                    images: [],
                                    selectedAmenities: widget.selectedAmenities,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 30, bottom: 20, right: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Type de Location",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            18, // Font size for section title
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    buildPropertyConditionWidget(
                                        widget.property.propertyCondition),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Price_Update_Screen(
                                    property: widget.property,
                                    images: [],
                                    selectedAmenities: widget.selectedAmenities,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              height: 105,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 30, bottom: 20, right: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      "Prix",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            18, // Font size for description title
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            15), // Spacing between description title and property details
                                    Text(
                                      '${widget.property.price}€',
                                      style: TextStyle(
                                        color: Colors.grey[
                                            800], // Text color for property details
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            16, // Font size for property details
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Localisation_Update_Screen(
                                    property: widget.property,
                                    images: [],
                                    selectedAmenities: widget.selectedAmenities,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              height: 430,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 30.0,
                                            left: 20,
                                            bottom: 30,
                                            right: 20),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                color: Color(0xFF5e5f99),
                                                size: 25),
                                            SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                "Ou se situe le logement",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Montserrat",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15.0, left: 15),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15), // Applies rounded corners to the entire card
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height: 200,
                                                width: 350,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  ), // Apply rounded corners only to the top of the container
                                                  color: Colors
                                                      .white, // Ensure the map container background matches the card
                                                ),
                                                child: ClipRRect(
                                                  // Ensures the map does not overflow the rounded corners
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  ),
                                                  child: FlutterMap(
                                                    options: MapOptions(
                                                      // ignore: deprecated_member_use
                                                      center: LatLng(
                                                          widget.property.lat,
                                                          widget.property.lng),
                                                      // ignore: deprecated_member_use
                                                      zoom: 15, // Closer view
                                                    ),
                                                    children: [
                                                      TileLayer(
                                                        urlTemplate:
                                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                        userAgentPackageName:
                                                            'com.madidou.madidou',
                                                      ),
                                                      MarkerLayer(
                                                        markers: [
                                                          Marker(
                                                            point: LatLng(
                                                                widget.property
                                                                    .lat,
                                                                widget.property
                                                                    .lng),
                                                            width: 80,
                                                            height: 80,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () => _openMaps(
                                                                  widget
                                                                      .property
                                                                      .lat,
                                                                  widget
                                                                      .property
                                                                      .lng),
                                                              child: const Icon(
                                                                  Icons.house,
                                                                  size: 35.0,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 0.0,
                                            left: 20,
                                            bottom: 20,
                                            right: 20),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_on,
                                                  color: Color.fromARGB(
                                                      255, 255, 112, 137),
                                                  size: 25),
                                              SizedBox(width: 5),
                                              const Text(
                                                "Region de logement",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Montserrat",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 52.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            widget.property.region,
                                            style: TextStyle(
                                              color: Colors.grey[
                                                  800], // Text color for property details
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  16, // Font size for property details
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Nrbroom_Area_Update_Screen(
                                    property: widget.property,
                                    images: [],
                                    selectedAmenities: widget.selectedAmenities,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 400,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Light background for visibility
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners for modern look
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Subtle shadow for depth
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        2, 2), // Slight offset for 3D effect
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 30, bottom: 20, right: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      "Surface de logment ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            18, // Font size for description title
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            15), // Spacing between description title and property details
                                    Text(
                                      '${widget.property.totalArea}m²',
                                      style: TextStyle(
                                        color: Colors.grey[
                                            800], // Text color for property details
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            17, // Font size for property details
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    const Text(
                                      "Nombre de chambre",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            18, // Font size for description title
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            15), // Spacing between description title and property details
                                    Text(
                                      ' S+${widget.property.nbrRooms}',
                                      style: TextStyle(
                                        color: Colors.grey[
                                            800], // Text color for property details
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            17, // Font size for property details
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Ajoutez ici d'autres éléments si nécessaire
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
