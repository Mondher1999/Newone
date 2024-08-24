import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/guide_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property_Update/property_detail_update_screen.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';

class PropertyListProprietaireWidget extends StatefulWidget {
  final List<Property> properties;
  final Function(String) onPropertyDelete;
  final Function(String) onPropertyUpdate;
  final List<XFile> images;
  final List<Amenities> selectedAmenities;

  const PropertyListProprietaireWidget({
    Key? key,
    required this.properties,
    required this.onPropertyDelete,
    required this.onPropertyUpdate,
    required this.images,
    required this.selectedAmenities,
  }) : super(key: key);

  @override
  State<PropertyListProprietaireWidget> createState() =>
      _PropertyListProprietaireWidgetState();
}

class _PropertyListProprietaireWidgetState
    extends State<PropertyListProprietaireWidget> {
  List<Property> filteredProperties = [];

  @override
  void initState() {
    super.initState();

    // Initialize filteredProperties here as well

    filteredProperties = widget.properties;
  }

  @override
  void didUpdateWidget(covariant PropertyListProprietaireWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.properties != widget.properties) {
      setState(() {
        filteredProperties = widget.properties;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFededf6),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 20.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Material(
                color: Color.fromARGB(
                    255, 255, 112, 137), // Set the background color here
                shape:
                    CircleBorder(), // Defines the material's shape as a circle
                elevation: 4, // Adds elevation for a shadow effect
                child: IconButton(
                  icon: const Icon(Icons.add,
                      size: 30, color: Colors.white), // Icon configuration
                  onPressed: () {
                    // Navigation method
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => FirstScreen(
                                images: widget.images,
                                selectedAmenities: widget.selectedAmenities,
                              )),
                    );
                  },
                ),
              ),
            ),
          ),

          // Correctly placed within a Column

          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 0),
              child: Text(
                "Mes annonces",
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),
          Expanded(
            // To ensure ListView takes the remaining space
            child: ListView.builder(
              itemCount: filteredProperties.length,
              itemBuilder: (context, index) {
                final property = filteredProperties[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the property detail screen, passing the selected property
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailUpdateScreen(
                          property: property,
                          selectedAmenities: widget.selectedAmenities,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7.5),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFededf6),
                        // Background color of the container
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
                                    .length, // Nombre d'images dans la liste
                                itemBuilder: (BuildContext context,
                                        int itemIndex, int pageViewIndex) =>
                                    Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal:
                                          5.0), // Ajoute un peu d'espace entre les images
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        20), // Coins plus arrondis pour un look moderne
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        20), // Assure que l'image respecte les bordures arrondies du conteneur
                                    child: CachedNetworkImage(
                                      imageUrl: property.fileUrls[itemIndex],
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.5, // Hauteur dynamique basée sur la taille de l'écran
                                      width: MediaQuery.of(context)
                                          .size
                                          .width, // Utilise la largeur complète de l'écran
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                options: CarouselOptions(
                                  autoPlay:
                                      false, // Pour une expérience utilisateur dynamique, laissez défiler automatiquement les images
                                  enlargeCenterPage:
                                      true, // Met en valeur l'image centrale en l'agrandissant légèrement
                                  viewportFraction:
                                      0.8, // Permet de voir une partie des images précédente et suivante
                                  aspectRatio: 16 /
                                      13, // Un ratio d'aspect large pour un affichage plein écran moderne
                                  initialPage: 0,
                                  autoPlayCurve: Curves
                                      .fastOutSlowIn, // Une courbe d'animation pour une transition fluide entre les images
                                  autoPlayInterval: const Duration(
                                      seconds:
                                          3), // Intervalle de défilement automatique
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
                              padding: const EdgeInsets.only(top: 20, left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 1),
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons
                                                  .location_on, // Icon de localisation
                                              color: Colors
                                                  .black, // Couleur de l'icône, ajustez selon le besoin
                                              size:
                                                  20.0, // Taille de l'icône, ajustez selon le besoin
                                            ),

                                            const SizedBox(
                                                width:
                                                    2), // Espace entre l'icône et le texte
                                            Text(
                                              property.region,
                                              style: const TextStyle(
                                                color: Colors
                                                    .black, // Ajustez la couleur du texte pour la lisibilité
                                                fontSize: 17,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 23.0),
                                        child: Text(
                                          '${property.propertyType} de ${property.totalArea}m²',
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                    255, 71, 71, 71)
                                                .withOpacity(0.9),
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w500,
                                            fontSize:
                                                14, // Adjust text color for readability
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 34),
                                      const SizedBox(height: 4),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                        ),
                                      ),
                                    ],
                                  )
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
            ),
          ),
        ],
      ),
    );
  }
}
