import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class DocumentViewScreen extends StatefulWidget {
  final String url;

  DocumentViewScreen({required this.url});

  @override
  _DocumentViewScreenState createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    validateImageUrl();
  }

  // Validates the image URL by making an HTTP GET request
  void validateImageUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        print("Image URL is valid and accessible.");
      } else {
        throw Exception(
            "Image URL is not accessible, received HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to load image: $e");
      _errorMessage = "Failed to load image: ${e.toString()}";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    } else {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: CachedNetworkImage(
            imageUrl: widget.url,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }
}
