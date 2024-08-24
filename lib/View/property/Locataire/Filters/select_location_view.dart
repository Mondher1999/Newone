import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyLocationScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  PropertyLocationScreen(
      {Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  State<PropertyLocationScreen> createState() => _PropertyLocationScreenState();
}

class _PropertyLocationScreenState extends State<PropertyLocationScreen> {
  void _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(widget.latitude, widget.longitude),
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.yourcompany.app',
          ),
        ],
      ),
    );
  }
}
