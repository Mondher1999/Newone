import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/property/Locataire/Property_Read/property_detail.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_user.dart';

class PropertyFavorisListWidget extends StatefulWidget {
  final List<Property> properties;
  final Function(String) onPropertyDelete;
  final Function(String) onPropertyUpdate;

  const PropertyFavorisListWidget({
    Key? key,
    required this.properties,
    required this.onPropertyDelete,
    required this.onPropertyUpdate,
  }) : super(key: key);

  @override
  _PropertyFavorisListWidgetState createState() =>
      _PropertyFavorisListWidgetState();
}

class _PropertyFavorisListWidgetState extends State<PropertyFavorisListWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize filteredProperties here as well
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
        // Handle favorite removal success
        if (state is FavoriteRemoveSuccess) {
          BlocProvider.of<FavoriteBloc>(context)
              .add(FetchFavorites(authUser.id));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFededf6),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10),
                  child: Text(
                    "Favoris",
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF5e5f99),
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthStateLocataire ||
                        authState is AuthStateProprietaire) {
                      // User is logged in, show favorite properties
                      return ListView.builder(
                        itemCount: widget.properties.length,
                        itemBuilder: (context, index) {
                          final property = widget.properties[index];
                          var screenSize = MediaQuery.of(context)
                              .size; // Get the current screen size

                          return GestureDetector(
                            onTap: () {
                              // Navigate to the property detail screen, passing the selected property
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailScreen(property: property),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(7.5),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(
                                      0xFFededf6), // Background color of the container
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align children to the start of the column
                                  children: [
                                    // Use Stack to overlay the favorite icon on the image
                                    Stack(
                                      children: [
                                        CarouselSlider.builder(
                                          itemCount: property.fileUrls
                                              .length, // Number of images in the list
                                          itemBuilder: (BuildContext context,
                                                  int itemIndex,
                                                  int pageViewIndex) =>
                                              Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal:
                                                    5.0), // Add some space between images
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  20), // Rounded corners for a modern look
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  20), // Ensure the image respects the rounded borders of the container
                                              child: CachedNetworkImage(
                                                imageUrl: property
                                                    .fileUrls[itemIndex],
                                                height: screenSize.height *
                                                    0.3, // Dynamic height based on screen size
                                                width: screenSize
                                                    .width, // Uses the full width of the screen
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          options: CarouselOptions(
                                            autoPlay:
                                                true, // Automatically scroll images for a dynamic user experience
                                            enlargeCenterPage:
                                                true, // Highlight the central image by enlarging it slightly
                                            viewportFraction:
                                                0.8, // Allows viewing part of the previous and next images
                                            aspectRatio: 16 /
                                                9, // A wide aspect ratio for a modern full-screen display
                                            initialPage: 0,
                                            autoPlayCurve: Curves
                                                .fastOutSlowIn, // An animation curve for a smooth transition between images
                                            autoPlayInterval: const Duration(
                                                seconds:
                                                    3), // Auto-scroll interval
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.favorite,
                                              color: Colors
                                                  .red, // Icon is always favorited for demonstration
                                            ),
                                            onPressed: () {
                                              final firebaseUser = FirebaseAuth
                                                  .instance.currentUser;
                                              final AuthUser authUser =
                                                  AuthUser.fromFirebase(
                                                      firebaseUser!);
                                              BlocProvider.of<FavoriteBloc>(
                                                      context)
                                                  .add(RemoveFavorite(
                                                      property.id,
                                                      authUser.id));
                                              // Update the favorite status here
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Very transparent white area for texts below the image
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFededf6),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 1),
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Icon(
                                                          Icons.location_on,
                                                          color: Colors.black,
                                                          size: 20.0),
                                                      const SizedBox(width: 2),
                                                      Expanded(
                                                        // Using Expanded to prevent overflow
                                                        child: Text(
                                                          "Superbe appartement au coeur de la ville",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 17,
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis, // Prevent text from overflowing
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 23.0),
                                                  child: Text(
                                                    '${property.propertyType} de ${property.totalArea}m²',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                              255, 71, 71, 71)
                                                          .withOpacity(0.9),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 23.0),
                                                  child: Text(
                                                    'Situé au coeur de ${property.region} ${property.propertyType} composé de ${property.nbrRooms} pièces',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                              255, 71, 71, 71)
                                                          .withOpacity(0.9),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          '850 €',
                                                          style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.9),
                                                            fontSize: 17,
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' / mois',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Montserrat",
                                                            color: Color
                                                                    .fromRGBO(
                                                                        38,
                                                                        38,
                                                                        39,
                                                                        1)
                                                                .withOpacity(
                                                                    0.8),
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                          );
                        },
                      );
                    } else {
                      // Loading or other states
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 40, left: 20, right: 15),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: SizedBox(
                                  width:
                                      100, // Set the width of the container to determine the length of the divider
                                  child: Divider(),
                                ),
                              ),
                            ),
                            const Text(
                              "Connectez-vous pour consulter vos favoris.",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                            const Text(
                              "",
                              style: TextStyle(
                                fontSize: 8,
                              ),
                            ),
                            Text(
                              "Vous pouvez créer, consulter ou modifier les favoris en vous connectant à votre compte.",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to login screen
                                  context.read<AuthBloc>().add(
                                        const AuthEventShouldLogIn(),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  // Définit la couleur de fond du bouton (par exemple, bleu)
                                  backgroundColor: const Color(0xFF5e5f99),
                                  // Définit la taille minimum du bouton
                                  minimumSize:
                                      // ignore: prefer_const_constructors
                                      Size(140, 50), // Taille plus petite
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          16), // Ajuste le padding à l'intérieur du bouton
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Coins arrondis
                                  ),
                                ),
                                child: const Text(
                                  "Connexion",
                                  style: TextStyle(
                                      color: Colors
                                          .white, // Couleur du texte en blanc
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
