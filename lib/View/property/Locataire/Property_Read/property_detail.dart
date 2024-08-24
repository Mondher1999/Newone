import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/appointments/calenderappointments.dart';
import 'package:madidou/View/auth/login_view.dart';
import 'package:madidou/View/auth/update_housing_files_screen.dart';
import 'package:madidou/View/auth/update_profile_view.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/property.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({Key? key, required this.property})
      : super(key: key);

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _current = 0; // État pour suivre l'index actuel du carousel

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Initial data fetch
  }

  @override
  void dispose() {
    // Reset dialog flag when disposing the widget
    super.dispose();
  }

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

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 30, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 10), // Espacement en haut du carrousel
                  child: CarouselSlider.builder(
                    itemCount: widget.property.fileUrls.length,
                    itemBuilder: (BuildContext context, int itemIndex,
                            int pageViewIndex) =>
                        ClipRRect(
                      borderRadius: BorderRadius.circular(
                          18), // Coins arrondis du carrousel
                      child: CachedNetworkImage(
                        imageUrl: widget.property.fileUrls[itemIndex],
                        fit: BoxFit.cover,
                        width: double
                            .infinity, // Utilise toute la largeur disponible
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: true,
                      aspectRatio:
                          20 / 9, // Ajustez selon les besoins de votre design
                      viewportFraction:
                          0.85, // Utilisez 1.0 pour occuper toute la largeur
                      height: MediaQuery.of(context).size.height *
                          0.36, // Hauteur du carrousel ajustée ici
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.property.fileUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == entry.key
                              ? const Color(0xFF5e5f99)
                              : Colors.grey.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFededf6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
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
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Color.fromARGB(255, 255, 112, 137),
                                size: 30),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.property.region,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 20, bottom: 10.0, left: 13, right: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Superbe appartement au coeur de la ville",
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Padding(
                          padding:
                              EdgeInsets.only(left: 10, top: 10.0, bottom: 20),
                          child: SizedBox(
                            width:
                                350, // Set the width of the container to determine the length of the divider
                            child: Divider(),
                          ),
                        ),
                        // ignore: prefer_const_constructors
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5, left: 15.0, bottom: 20),
                          child: const Text(
                            " Description",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 17, // Adjust text color for readability
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 23.0),
                          child: Text(
                            // ignore: prefer_interpolation_to_compose_strings
                            widget.property.propertyType.toString() +
                                ' de ' +
                                widget.property.totalArea.toString() +
                                ' m²' +
                                ' composer de ' +
                                widget.property.nbrRooms.toString() +
                                " Chambres",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w500,
                              fontSize: 15, // Adjust text color for readability
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 20, left: 15.0, bottom: 0),
                          child: Text(
                            " Ce que propose ce logement",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 17, // Adjust text color for readability
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 10,
                            children: widget.property.amenities
                                .map((amenity) => buildAmenityWidget(amenity))
                                .toList(),
                          ),
                        ),

                        const Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 18.0, bottom: 0),
                          child: Text(
                            " Type de Location",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 17, // Adjust text color for readability
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildPropertyConditionWidget(
                              widget.property.propertyCondition),
                        ),
                        const SizedBox(height: 40),
                        const Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Color(0xFF5e5f99), size: 30),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "Ou se situe le logement",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Card(
                          margin: const EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Applies rounded corners to the entire card
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: 400,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ), // Apply rounded corners only to the top of the container
                                  color: Colors
                                      .white, // Ensure the map container background matches the card
                                ),
                                child: ClipRRect(
                                  // Ensures the map does not overflow the rounded corners
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: FlutterMap(
                                    options: MapOptions(
                                      // ignore: deprecated_member_use
                                      center: LatLng(widget.property.lat,
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
                                            point: LatLng(widget.property.lat,
                                                widget.property.lng),
                                            width: 80,
                                            height: 80,
                                            child: GestureDetector(
                                              onTap: () => _openMaps(
                                                  widget.property.lat,
                                                  widget.property.lng),
                                              child: const Icon(Icons.house,
                                                  size: 35.0,
                                                  color: Colors.red),
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

                        const SizedBox(height: 100),

                        // Ajoutez ici d'autres éléments si nécessaire
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white, // or any other color
              padding: const EdgeInsets.only(
                  right: 0, left: 0, bottom: 15), // Adjust padding as needed
              child: Column(
                mainAxisSize: MainAxisSize.min, // To fit content size
                children: [
                  // Adjust space between elements as needed
                  Align(
                    alignment: Alignment.center, // Adjust alignment as needed
                    child: Column(
                      children: [
                        const SizedBox(
                          // Set the width of the container to determine the length of the divider
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 7.0, top: 7),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the row only takes up needed space
                          children: [
                            Text(
                              "Prix: ${widget.property.price} € ", // Your dynamic text here
                              style: const TextStyle(
                                color:
                                    Colors.black, // Adjust text color as needed
                                fontSize: 16,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight
                                    .w700, // Adjust font size as needed
                              ),
                            ),
                            const SizedBox(width: 130),
                            BlocListener<UserBloc, UserState>(
                              listener: (context, state) {
                                // Listener is now more passive, not triggering dialogs directly from user load success.
                              },
                              child: BlocBuilder<UserBloc, UserState>(
                                builder: (context, state) {
                                  return TextButton(
                                    onPressed: () {
                                      final firebaseUser =
                                          FirebaseAuth.instance.currentUser;
                                      if (firebaseUser == null) {
                                        // No user logged in, show login prompt dialog
                                        _showLoginDialog(context);
                                      } else {
                                        // User is logged in, check validation and decide action
                                        if (state is UserLoadSuccess) {
                                          if (state.user.validefilesuser ==
                                                  'non validé' ||
                                              state.user.valideinfouser ==
                                                  'non validé') {
                                            // Check if the update dialog has not been shown yet

                                            _showUpdateDialog(
                                                context, state.user);
                                          } else {
                                            // User is valid, proceed with application or other actions
                                            // Add your application logic here
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StylishCalendarScreen(
                                                          property:
                                                              widget.property),
                                                ));
                                          }
                                        } else {
                                          // Fetch user data if not already loaded or in case of needing refresh
                                          context
                                              .read<UserBloc>()
                                              .add(FetchUser(firebaseUser.uid));
                                        }
                                      }
                                    },
                                    child: const Text('Postuler'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 112, 137),
                                      textStyle: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 27, vertical: 16),
                                    ),
                                  );
                                },
                              ),
                            ),

// Space between text and button
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Connexion requise"),
          content: Text("Vous devez vous connecter pour postuler."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                context.read<AuthBloc>().add(const AuthEventShouldLogIn());
              },
              child: Text("Se connecter"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, Users user) {
    String message = ''; // Message to be displayed in the dialog

    if (user.validefilesuser == 'non validé' &&
        user.valideinfouser == 'non validé') {
      message =
          "Vous devez mettre à jour vos dossiers et vos informations personnelles pour postuler.";
    } else if (user.validefilesuser == 'non validé') {
      message = "Vous devez mettre à jour vos dossiers pour postuler.";
    } else if (user.valideinfouser == 'non validé') {
      message =
          "Vous devez mettre à jour vos informations personnelles pour postuler.";
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Mise à jour requise"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and reset the dialog flag
                Navigator.pop(dialogContext);
                resetDialogFlag(); // Reset the flag after closing
              },
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                // Navigate without resetting flag here
                Navigator.pop(dialogContext);
                _navigateToUpdateScreen(context, user);
              },
              child: Text("Mettre à jour"),
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure the flag is reset when the dialog is dismissed by any means
      if (mounted) {
        resetDialogFlag();
      }
    });
  }

  void resetDialogFlag() {
    if (mounted) {
      setState(() {
        //  _isDialogShown = false; // Reset the dialog showing flag
      });
    }
  }

  void _navigateToUpdateScreen(BuildContext context, Users user) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => user.validefilesuser == 'validé' &&
                    user.valideinfouser == 'non validé'
                ? UpdateProfileScreen()
                : UpdateHousingFilesScreen())).then((_) {
      // This callback is triggered when returning back to the main screen
      if (mounted) {
        fetchUserData(); // Fetch user data to refresh the state
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserData(); // Refresh user data when coming back to the screen
  }

  void fetchUserData() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      BlocProvider.of<UserBloc>(context).add(FetchUser(firebaseUser.uid));
    }
  }
}
