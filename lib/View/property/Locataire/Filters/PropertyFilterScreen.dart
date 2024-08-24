import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:madidou/View/property/Locataire/Filters/map_selection_screen.dart';
import 'package:madidou/data/enums/PropertyCondition.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/LatLng.dart';
import 'package:madidou/data/model/PropertyFilter.dart';
import 'package:madidou/data/enums/PropertyType.dart';
import 'package:http/http.dart' as http;
import 'package:madidou/data/model/property.dart';

class PropertyFilterScreen extends StatefulWidget {
  final Function(PropertyFilter) onFilterApply;
  final List<Property> properties;

  const PropertyFilterScreen(
      {Key? key, required this.onFilterApply, required this.properties})
      : super(key: key);

  @override
  State<PropertyFilterScreen> createState() => _PropertyFilterScreenState();
}

class _PropertyFilterScreenState extends State<PropertyFilterScreen> {
  String? selectedRegion;
  RangeValues _currentRangeValuesPrice = const RangeValues(0, 10000);
  RangeValues _currentRangeValuesArea = const RangeValues(0, 1000);
  List<PropertyCondition> selectedPropertyConditions = [];
  List<PropertyType> selectedPropertyType = [];
  List<Amenities> selectedAmenities = [];
  List<Property> filteredProperties = [];
  String searchTermm = ''; // Add this line
  IconData getIconForPropertyType(PropertyType type) {
    switch (type) {
      case PropertyType.Appartement:
        return Icons.apartment;
      case PropertyType.Maison:
        return Icons.house;
      // Ajoutez d'autres cas pour les différents types de propriété
      default:
        return Icons.landscape; // Une icône par défaut pour les cas non gérés
    }
  }

  List<int> selectedNumberOfRooms = [];

  @override
  void dispose() {
    super.dispose();
  }

  void _onMapTap(LatLng location) {
    Navigator.pop(context,
        {'latitude': location.latitude, 'longitude': location.longitude});
  }

  void applyFilters() {
    PropertyFilter filter = PropertyFilter(
      region: selectedRegion,
      minPrice: _currentRangeValuesPrice.start,
      maxPrice: _currentRangeValuesPrice.end,
      minArea: _currentRangeValuesArea.start,
      maxArea: _currentRangeValuesArea.end,
      nbrRooms: selectedNumberOfRooms, // Add this line
      propertyType: selectedPropertyType, // Add this line
      propertyCondition: selectedPropertyConditions,
      amenities: selectedAmenities,
      latitude: latitude, // Include latitude
      longitude: longitude, // Include longitude
    );
    Navigator.pop(context, filter);
  }

  String getPropertyConditionDisplayName(PropertyCondition condition) {
    switch (condition) {
      case PropertyCondition.Meuble:
        return 'Meublé';
      case PropertyCondition.Non_Meuble:
        return 'Non meublé';
      default:
        return 'Inconnu';
    }
  }

  String getPropertyAmenitiesDisplayName(Amenities amenities) {
    switch (amenities) {
      case Amenities.air_conditionne:
        return 'Air conditionné';
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

  Widget _buildPropertyConditionSelector(PropertyCondition type) {
    bool isSelected = selectedPropertyConditions.contains(type);
    IconData icon =
        getIconForPropertyCondition(type); // Obtenez l'icône pour le type

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected
              ? selectedPropertyConditions.remove(type)
              : selectedPropertyConditions.add(type);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(
            8), // Ajoute de l'espacement autour de chaque carré
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 15), // Agrandit le carré
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 112, 137),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF5e5f99)), // Ajoute l'icône ici
            const SizedBox(width: 8), // Espacement entre l'icône et le texte
            Text(
              getPropertyConditionDisplayName(type),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Pi / 180
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
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

// Exemple de fonction pour obtenir l'icône correspondant à l'agrément
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

  Widget _buildPropertyTypeSelector(PropertyType type) {
    bool isSelected = selectedPropertyType.contains(type);
    IconData iconData =
        getIconForPropertyType(type); // Obtenez l'icône correspondante

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected
              ? selectedPropertyType.remove(type)
              : selectedPropertyType.add(type);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(
            8), // Ajoute un espacement externe autour de chaque sélecteur
        padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15), // Ajuste les dimensions internes du conteneur
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 112, 137),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF5e5f99)), // Ajoute l'icône ici
            const SizedBox(width: 8), // Espacement entre l'icône et le texte
            Text(
              type.toString().split('.').last,
              overflow: TextOverflow.ellipsis, // Gère le débordement
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? latitude;
  double? longitude;

  void pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSelectionScreen()),
    );

    if (result != null) {
      setState(() {
        latitude = result['latitude'];
        longitude = result['longitude'];
      });
    }
  }

  Widget _buildRoomSelector(int roomNumber) {
    bool isSelected =
        selectedNumberOfRooms.contains(roomNumber); // Mise à jour ici
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedNumberOfRooms.remove(roomNumber);
          } else {
            selectedNumberOfRooms.add(roomNumber);
          }
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5e5f99) : Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 112, 137),
            width: isSelected ? 0 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              roomNumber == 5 ? '5+' : roomNumber.toString(),
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : const Color(0xFF5e5f99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Example regions, replace with your actual data
    List<String> regions = [
      'Île de France',
      'Bretagne',
      'Normandie',
      'Grand Est',
      'Pays de la Loire',
      'Hauts de France',
      'Centre Val de Loire'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Le reste de votre widget build...

      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add your autocomplete widget here

              Text(
                "Filtrer les logements",
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      fontSize: 30,
                      color: const Color(0xFF5e5f99),
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 20.0, bottom: 20),
                child: SizedBox(
                  width:
                      60, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Où chercher-Vous",
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
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: InkWell(
                    onTap: pickLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: latitude == null
                            ? const LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Color(0xFF00CED1)
                                ], // Couleurs aqua
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Colors.purpleAccent
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ), // Gradient captivant lors de la sélection
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset:
                                const Offset(0, 4), // Ajoute de la profondeur
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            latitude == null
                                ? 'Sélectionnez un emplacement'
                                : 'Emplacement sélectionné', // Texte en français
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(25.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),

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
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Type de bien",
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
              const SizedBox(height: 30),
              Wrap(
                spacing: 15, // Espacement horizontal
                children: PropertyType.values
                    .map((type) => _buildPropertyTypeSelector(type))
                    .toList(),
              ),
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
              const SizedBox(height: 30),
              DecoratedBox(
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
                    value: selectedRegion,
                    hint: const Text("Select Region"),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color.fromARGB(255, 255, 112, 137),
                    ),
                    items:
                        regions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRegion = newValue;
                      });
                    },
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      const Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Budget: ${_currentRangeValuesPrice.start.round()} € - ${_currentRangeValuesPrice.end.round()} €",
                        key: ValueKey<String>(
                            "${_currentRangeValuesPrice.start}-${_currentRangeValuesPrice.end}"),
                        style: const TextStyle(
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
              const SizedBox(height: 10),
              FlutterSlider(
                values: [
                  _currentRangeValuesPrice.start,
                  _currentRangeValuesPrice.end
                ],
                rangeSlider: true,
                max: 10000,
                min: 0,
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 112, 137),
                  ),
                  inactiveTrackBar: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                ),
                tooltip: FlutterSliderTooltip(
                  textStyle: const TextStyle(fontSize: 17, color: Colors.white),
                  boxStyle: const FlutterSliderTooltipBox(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 112, 137),
                    ),
                  ),
                ),
                handler: FlutterSliderHandler(
                  decoration: const BoxDecoration(),
                  child: Material(
                    type: MaterialType.circle,
                    color: const Color(0xFF5e5f99), // Handler color
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Icon(
                        Icons.circle,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                rightHandler: FlutterSliderHandler(
                  child: Material(
                    type: MaterialType.circle,
                    color: const Color(0xFF5e5f99),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Icon(
                        Icons.circle,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _currentRangeValuesPrice =
                        RangeValues(lowerValue, upperValue);
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Nombre de chambre",
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    List.generate(5, (index) => _buildRoomSelector(index + 1)),
              ),
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      const Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Surface: ${_currentRangeValuesArea.start.round()} m² - ${_currentRangeValuesArea.end.round()} m²",
                        key: ValueKey<String>(
                            "${_currentRangeValuesArea.start}-${_currentRangeValuesArea.end}"),
                        style: const TextStyle(
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
              FlutterSlider(
                values: [
                  _currentRangeValuesArea.start,
                  _currentRangeValuesArea.end
                ],
                rangeSlider: true,
                max: 1000,
                min: 0,
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 112, 137),
                  ),
                  inactiveTrackBar: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                ),
                tooltip: FlutterSliderTooltip(
                  textStyle: const TextStyle(fontSize: 17, color: Colors.white),
                  boxStyle: const FlutterSliderTooltipBox(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 112, 137),
                    ),
                  ),
                ),
                handler: FlutterSliderHandler(
                  decoration: const BoxDecoration(),
                  child: Material(
                    type: MaterialType.circle,
                    color: const Color(0xFF5e5f99), // Handler color
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Icon(
                        Icons.circle,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                rightHandler: FlutterSliderHandler(
                  child: Material(
                    type: MaterialType.circle,
                    color: const Color(0xFF5e5f99),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Icon(
                        Icons.circle,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _currentRangeValuesArea =
                        RangeValues(lowerValue, upperValue);
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 20.0, bottom: 20),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the row size to fit content
                    children: [
                      Icon(
                        Icons.filter_list, // Example icon for "Type de bien"
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Type de Location",
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
              const SizedBox(height: 30),
              Wrap(
                spacing: 15, // Espacement horizontal
                children: PropertyCondition.values
                    .map((type) => _buildPropertyConditionSelector(type))
                    .toList(),
              ),
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: SizedBox(
                  width:
                      350, // Set the width of the container to determine the length of the divider
                  child: Divider(),
                ),
              ),
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
              const SizedBox(height: 30),
              Wrap(
                spacing: 15, // Espacement horizontal
                children: Amenities.values
                    .map((type) => _buildPropertyAmenitiesSelector(type))
                    .toList(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: ElevatedButton(
          onPressed: applyFilters,
          child: const Text('Appliquer les filtres'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor:
                const Color(0xFF5e5f99), // Couleur du texte du bouton
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
