import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:madidou/View/property/Locataire/Filters/PropertyFilterScreen.dart';
import 'package:madidou/View/property/Locataire/Filters/property_filter_region.dart';
import 'package:madidou/View/property/Locataire/Property_Read/property_detail.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/data/model/LatLng.dart';
import 'package:madidou/data/model/PropertyFilter.dart';
import 'package:madidou/data/model/property.dart';
import 'package:http/http.dart' as http;
import 'package:madidou/services/auth/auth_user.dart';

class PropertyListLocataireWidget extends StatefulWidget {
  final List<Property> properties;
  final Function(String) onPropertyDelete;
  final Function(String) onPropertyUpdate;

  const PropertyListLocataireWidget({
    super.key,
    required this.properties,
    required this.onPropertyDelete,
    required this.onPropertyUpdate,
  });

  @override
  State<PropertyListLocataireWidget> createState() =>
      _PropertyListLocataireWidgetState();
}

class _PropertyListLocataireWidgetState
    extends State<PropertyListLocataireWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Property> filteredProperties = [];

  @override
  void initState() {
    super.initState();

    // Initialize filteredProperties here as well
    filteredProperties = widget.properties;
    _searchController.addListener(_filterProperties);
    _searchController.clear();
  }

  @override
  void didUpdateWidget(PropertyListLocataireWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the list of properties has changed, update filteredPropertiesffieldTextEditingController
    if (oldWidget.properties != widget.properties) {
      _filterProperties();
    }
  }

  Future<List<Property>> filterPropertiesByCoordinates(
      LatLng coordinates) async {
    // Filter the properties based on distance
    List<Property> filteredProperties = widget.properties.where((property) {
      return _calculateDistance(property.lat, property.lng,
              coordinates.latitude, coordinates.longitude) <=
          3; // Assuming distance is in kilometers or as per your units
    }).toList();

    // If no properties match the criteria, filteredProperties will already be an empty list
    return filteredProperties;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Pi / 180
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> handleLocationSelection(String selection) async {
    try {
      final LatLng coordinates = await getCoordinatesFromQuery(selection);
      debugPrint(
          'Coordinates: ${coordinates.latitude}, ${coordinates.longitude}');

      // Use the coordinates to filter properties
      List<Property> newFilteredProperties =
          await filterPropertiesByCoordinates(coordinates);

      // Update your UI with the filtered properties
      setState(() {
        this.filteredProperties = newFilteredProperties;
      });
    } catch (e) {
      debugPrint("Error fetching coordinates: $e");
      // Optionally, handle errors or show a message to the user
    }
  }

  Future<void> applyFiltersWithLocation(PropertyFilter filter) async {
    LatLng? coordinates;
    // Check if a search term is provided and fetch coordinates
    if (filter.searchTerm != null && filter.searchTerm!.isNotEmpty) {
      try {
        coordinates = await getCoordinatesFromQuery(filter.searchTerm!);
      } catch (e) {
        // Handle error (e.g., could not fetch coordinates)
        return;
      }
    }

    // Now apply filters including location-based filtering if coordinates are available
    _filterPropertiesBasedOn(filter, coordinates);
  }

  Future<LatLng> getCoordinatesFromQuery(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$encodedQuery&key=63d1959b8a36466bbcdf01d4adcd9b30');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final firstResult = jsonResponse['results'][0];
        final geometry = firstResult['geometry'];
        final lat = geometry['lat'] as double;
        final lng = geometry['lng'] as double;
        return LatLng(lat, lng);
      } else {
        throw Exception('Failed to fetch location data from OpenCage');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to decode location data');
    }
  }

  void _filterPropertiesBasedOn(PropertyFilter filter, LatLng? coordinates) {
    print(
        "Applying filters with: Region: ${filter.region}, Price: ${filter.minPrice}-${filter.maxPrice}");

    setState(() {
      filteredProperties = widget.properties.where((property) {
        final matchesRegion =
            filter.region == null || property.region == filter.region;
        final price = double.tryParse(property.price) ?? 0;
        final matchesPrice =
            (filter.minPrice == null || price >= filter.minPrice!) &&
                (filter.maxPrice == null || price <= filter.maxPrice!);
        final area = double.tryParse(property.totalArea) ?? 0;
        final matchesArea =
            (filter.minArea == null || area >= filter.minArea!) &&
                (filter.maxArea == null || area <= filter.maxArea!);

        // Direct comparison for number of rooms
        final matchesNumberOfRooms = filter.nbrRooms.isEmpty ||
            filter.nbrRooms.contains(int.tryParse(property.nbrRooms));

        // Check for property type; if the list is null or empty, it matches by default
        final matchesTypeproperty = filter.propertyType == null ||
            filter.propertyType!.isEmpty ||
            filter.propertyType!.any((typeEnum) =>
                typeEnum.toString().split('.').last == property.propertyType);

        // Similar logic for property condition
        final matchesConditionproperty = filter.propertyCondition == null ||
            filter.propertyCondition!.isEmpty ||
            filter.propertyCondition!.any((conditionEnum) =>
                conditionEnum.toString().split('.').last ==
                property.propertyCondition);

        final matchesAmenitiesproperty = filter.amenities == null ||
            filter.amenities!.isEmpty ||
            filter.amenities!.every((filterAmenity) => property.amenities
                .contains(filterAmenity.toString().split('.').last));

        final matchesLocation = filter.latitude == null ||
            filter.longitude == null ||
            _calculateDistance(property.lat, property.lng, filter.latitude!,
                    filter.longitude!) <=
                50; // For example, filter properties within 50km radius

        print("hello ${filter.region}");

        // Update the return statement to include the new condition
        return matchesRegion &&
            matchesPrice &&
            matchesAmenitiesproperty &&
            matchesNumberOfRooms &&
            matchesArea &&
            matchesTypeproperty &&
            matchesConditionproperty &&
            matchesLocation;
        // The new check;
      }).toList();
      print(
          "Filtered count: ${filteredProperties.length} , ${filter.amenities}");
    });
  }

  // search bar by description

  void _filterProperties() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProperties = query.isEmpty
          ? widget.properties
          : widget.properties
              .where((property) =>
                  property.description.toLowerCase().contains(query))
              .toList();
    });
  }

  // slider of regions Filter
  void _filterPropertiesByRegion(String regionName) {
    setState(() {
      filteredProperties = widget.properties
          .where((property) => property.region == regionName)
          .toList();
      // You might need to adjust this based on your data structure.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFededf6),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Autocomplete<String>(
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text == '' ||
                              textEditingValue.text.length < 3) {
                            return const Iterable<String>.empty();
                          }
                          return await getSuggestions(textEditingValue.text);
                        },
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          return TextField(
                            controller:
                                fieldTextEditingController, // Bind the field controller
                            focusNode: fieldFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Votre recherche...',
                              fillColor: const Color(0xFFc3c0e0),
                              filled: true,
                              suffixIcon: const Icon(Icons.search,
                                  color: Color(0xFF5e5f99)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              hintStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontFamily: 'Montserrat'),
                            ),
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                        onSelected: (String selection) {
                          handleLocationSelection(selection);
                          // Handle the selection: e.g., perform a search based on the selected suggestion
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/filter.svg',
                      color: const Color(0xFF5e5f99),
                      width: 32,
                      height: 32,
                    ),
                    onPressed: () async {
                      // Navigate to the filter screen and await the result
                      final filterResult = await Navigator.push<PropertyFilter>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyFilterScreen(
                            onFilterApply: (PropertyFilter filter) {
                              Navigator.pop(context,
                                  filter); // This should correctly return the filter
                            },
                            properties: [],
                          ),
                        ),
                      );

                      if (filterResult != null) {
                        await applyFiltersWithLocation(filterResult);

                        // Clear text field
                        _searchController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            /*      Padding(
                padding: const EdgeInsets.only(top: 20, left: 240),
                child: const Row(
                  children: [
                    Text(
                      "Bonjour Eric", // Replace with the actual user name
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5e5f99),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 10), // Adds vertical spacing
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://www.benouaiche.com/wp-content/uploads/2018/12/homme-medecine-chirurgie-esthetique-dr-benouaiche-paris.jpg', // Replace with the actual user image URL
                      ),
                      radius: 20,
                    ),
                  ],
                ),
              ), */
            const Padding(
              padding: EdgeInsets.only(top: 30, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "C'est parti pour votre Logement !", // Replace with the actual user name
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, top: 20.0, bottom: 7),
                child: Row(
                  children: [
                    Expanded(
                      // Makes PropertyRegionList flexible to take up available space
                      child: PropertyRegionList(
                        onRegionSelected: (selectedRegion) {
                          _filterPropertiesByRegion(selectedRegion);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Example of adding another widget next to it
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                  builder: (context, state) {
                List<String> favoritePropertyIds = [];
                if (state is FavoritesLoaded) {
                  favoritePropertyIds =
                      state.properties.map((e) => e.id).toList();
                } else if (state is FavoriteRemoveSuccess) {
                  // Assuming the FavoriteBloc can reload the favorites, trigger that action
                  final firebaseUser = FirebaseAuth.instance.currentUser;
                  final AuthUser authUser =
                      AuthUser.fromFirebase(firebaseUser!);
                  BlocProvider.of<FavoriteBloc>(context)
                      .add(FetchFavorites(authUser.id));
                }
                {}
                return ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    final isFavorite =
                        favoritePropertyIds.contains(property.id);

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
                                            int itemIndex, int pageViewIndex) =>
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
                                          imageUrl:
                                              property.fileUrls[itemIndex],
                                          height:
                                              300, // Maintain a consistent size across devices
                                          width: MediaQuery.of(context)
                                              .size
                                              .width, // Uses the full width of the screen
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
                                          true, // Automatically scroll images for a dynamic user experience
                                      enlargeCenterPage:
                                          true, // Highlight the central image by enlarging it slightly
                                      viewportFraction:
                                          0.8, // Allows viewing part of the previous and next images
                                      aspectRatio: 11 /
                                          9, // A wide aspect ratio for a modern full-screen display
                                      initialPage: 0,
                                      autoPlayCurve: Curves
                                          .fastOutSlowIn, // An animation curve for a smooth transition between images
                                      autoPlayInterval: const Duration(
                                          seconds: 3), // Auto-scroll interval
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: Icon(
                                        FirebaseAuth.instance.currentUser !=
                                                    null &&
                                                isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            FirebaseAuth.instance.currentUser !=
                                                        null &&
                                                    isFavorite
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                      onPressed: () {
                                        final firebaseUser =
                                            FirebaseAuth.instance.currentUser;
                                        if (firebaseUser != null) {
                                          final AuthUser authUser =
                                              AuthUser.fromFirebase(
                                                  firebaseUser);
                                          if (isFavorite) {
                                            BlocProvider.of<FavoriteBloc>(
                                                    context)
                                                .add(RemoveFavorite(
                                                    property.id, authUser.id));
                                          } else {
                                            BlocProvider.of<FavoriteBloc>(
                                                    context)
                                                .add(AddFavorite(
                                                    property.id, authUser.id));
                                          }
                                        } else {
                                          // If no user is logged in, trigger a login prompt
                                          context.read<AuthBloc>().add(
                                              const AuthEventShouldLogIn());
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
                                  padding:
                                      const EdgeInsets.only(top: 20, left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 1),
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(Icons.location_on,
                                                color: Colors.black,
                                                size: 20.0),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                property.region,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
                                            color:
                                                Color.fromARGB(255, 71, 71, 71)
                                                    .withOpacity(0.9),
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 23.0),
                                        child: Text(
                                          'Situé au coeur de ${property.region} ${property.propertyType} composé de ${property.nbrRooms} pièces',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 71, 71, 71)
                                                    .withOpacity(0.9),
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${property.price} €',
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.9),
                                                  fontSize: 17,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                ' / mois',
                                                style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  color: Color.fromRGBO(
                                                          38, 38, 39, 1)
                                                      .withOpacity(0.8),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<Iterable<String>> getSuggestions(String query) async {
    // URL encode the query
    final encodedQuery = Uri.encodeComponent(query);
    // Construct the request URL for OpenCage Geocoding API
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$encodedQuery&key=63d1959b8a36466bbcdf01d4adcd9b30&limit=5');

    try {
      // Make the HTTP GET request
      final response = await http.get(url, headers: {
        // OpenCage requires a User-Agent header, but it can be more generic
        'User-Agent': 'YourApp/1.0'
      });

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final jsonResponse = json.decode(response.body);

        // OpenCage places are located under the 'results' key
        final results = jsonResponse['results'] as List<dynamic>;

        // Extract the formatted string of the places
        final suggestions =
            results.map((result) => result['formatted'] as String).toList();

        return suggestions;
      } else {
        // Handle error or non-200 responses
        throw Exception('Failed to load suggestions from OpenCage');
      }
    } catch (e) {
      // Handle any exceptions
      print(e);
      return const Iterable<String>.empty();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
