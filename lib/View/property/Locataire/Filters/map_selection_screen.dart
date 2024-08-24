import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapSelectionScreen extends StatefulWidget {
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final MapController mapController = MapController();
  final TextEditingController locationController = TextEditingController();
  LatLng center = const LatLng(48.8566, 2.3522); // Default to Paris, France
  String searchTermm = '';
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
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: center,
                    zoom: 13.0,
                    onTap: (tapPosition, latlng) {
                      setState(() {
                        center = latlng;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point:
                              center, // This ensures the marker position updates when the center changes
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.location_on,
                              color: Color.fromARGB(255, 255, 112, 137),
                              size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 80.0,
                  left: 16.0,
                  right: 16.0,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(20),
                    child: Autocomplete<String>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text == '' ||
                            textEditingValue.text.length < 3) {
                          return const Iterable<String>.empty();
                        }
                        // Fetch the suggestions
                        return await getSuggestions(textEditingValue.text);
                      },
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return Container(
                          decoration: BoxDecoration(
                            // Container background color
                            borderRadius: BorderRadius.circular(
                                15), // Rounded corners for the container
                          ),
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Où chercher-Vous',
                                  filled: true,
                                  fillColor:
                                      Colors.white, // TextField fill color
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none, // No border
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  contentPadding: const EdgeInsets.only(
                                      left: 20, right: 50), // Adjust padding
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF5e5f99), // Hint text color
                                    fontSize: 17,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF5e5f99), // Input text color
                                  fontSize: 16,
                                ),
                              ),
                              const Positioned(
                                right: 15,
                                child: Icon(
                                  Icons.map, // Icon next to the text field
                                  color: Color(0xFF5e5f99), // Icon color
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onSelected: (String selection) {
                        debugPrint('You selected: $selection');
                        updateLocation(
                            selection); // Call method to update location based on the selection

                        // Handle the selection, e.g., update a filter

                        searchTermm =
                            selection; // Update the searchTerm with the selection
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: _buildNavigationRow(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Ensures the row only takes up needed space
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Go back without changes
          child: const Text('Retour'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
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
        const SizedBox(width: 150), // Adjust spacing as needed
        TextButton(
          onPressed: () {
            // Send back the current center coordinates of the map
// This should be in an event where you finalize the selection, e.g., a button press.
            Navigator.pop(context,
                {'latitude': center.latitude, 'longitude': center.longitude});
          },
          child: const Text('Confirmer'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF5e5f99), // Button background color
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

  void updateLocation(String address) async {
    try {
      var url = Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=$address&key=63d1959b8a36466bbcdf01d4adcd9b30&pretty=1');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['results'].length > 0) {
          var firstResult = json['results'][0];
          double lat = firstResult['geometry']['lat'];
          double lng = firstResult['geometry']['lng'];
          setState(() {
            center =
                LatLng(lat, lng); // Update the map center to the new location
            mapController.move(center,
                15.0); // Move map view to the new center with a closer zoom
          });
        }
      } else {
        throw Exception('Failed to fetch location');
      }
    } catch (e) {
      // print('Error occurred while fetching location: $e');
    }
  }

  void _searchAndUpdateLocation(String query) {
    // Here, you'd use a geocoding API to find the coordinates for the search query
    // For example, using Geolocator or a similar package to fetch the location
  }
}
