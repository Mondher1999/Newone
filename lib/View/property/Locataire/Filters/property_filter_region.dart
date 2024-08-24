import 'package:flutter/material.dart';

// Assuming your propertyRegions list is defined outside of the widget
// to avoid rebuilding it on every state change.
final List<Map<String, String>> propertyRegions = [
  {'name': 'Île de France'},
  {'name': 'Bretagne'},
  {'name': 'Centre Val de Loire'},
  {'name': 'Normandie'},
  {'name': 'Occitanie'},
  {'name': 'Pays de la Loire'},
  {'name': 'Grand Est'},
  {'name': 'Hauts de France'},
];

class PropertyRegionList extends StatefulWidget {
  final Function(String) onRegionSelected;
  const PropertyRegionList({Key? key, required this.onRegionSelected})
      : super(key: key);

  @override
  _PropertyRegionListState createState() => _PropertyRegionListState();
}

class _PropertyRegionListState extends State<PropertyRegionList> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.0, // Set a fixed height for the container
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Make the list horizontal
        itemCount: propertyRegions.length, // Number of items in the list
        itemBuilder: (BuildContext context, int index) {
          bool isSelected =
              selectedIndex == index; // Check if the item is selected
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onRegionSelected(propertyRegions[index]['name']!);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Assurez-vous que la colonne prend le minimum d'espace nécessaire
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      propertyRegions[index]
                          ['name']!, // Display the region name
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: isSelected ? 15 : 14,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w400,
                        color: isSelected
                            ? const Color.fromARGB(255, 255, 112, 137)
                            : const Color(0xFF5e5f99),
                        // Change the text color when selected
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) // Si l'élément est sélectionné, montrez le point
                    Container(
                      margin: const EdgeInsets.only(
                          top: 4.0), // Espace entre le texte et le point
                      height: 10.0, // Augmenter la hauteur du point
                      width: 10.0, // Augmenter la largeur du point
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(
                            255, 255, 112, 137), // Couleur du point
                        shape: BoxShape.circle, // Forme du point
                      ),
                    ),
                  if (!isSelected)
                    Container(
                      margin: const EdgeInsets.only(
                          top: 4.0), // Espace entre le texte et le point
                      height: 5.0, // Augmenter la hauteur du point
                      width: 5.0, // Augmenter la largeur du point
                      decoration: const BoxDecoration(
                        color: Color(0xFF5e5f99), // Couleur du point
                        shape: BoxShape.circle, // Forme du point
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
