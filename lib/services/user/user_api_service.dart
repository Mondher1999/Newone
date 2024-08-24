import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiUserService {
  //final String baseUrl = 'http://10.0.2.2:3000/user';
  final String baseUrl = 'https://madidou-backend.onrender.com/user';

  Future<http.Response> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load users');
    }
  }

  // In user_api_service.dart

  Future<http.Response> deleteFriend(String userId, String friendId) async {
    var uri = Uri.parse('$baseUrl/users/$userId/friends/$friendId');
    try {
      var response = await http.delete(uri);
      return response;
    } catch (e) {
      throw Exception('Failed to delete friend: $e');
    }
  }

  Future<http.Response> getUserFriends(String userId) async {
    var uri = Uri.parse('$baseUrl/users/$userId/friends');
    try {
      var response = await http.get(uri);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch friends: $e');
    }
  }

  Future<http.Response> addFriend(String userId, String friendId) async {
    var uri = Uri.parse('$baseUrl/users/$userId/friends');
    try {
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'friendId': friendId}),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to add friend: $e');
    }
  }

  Future<http.Response> updateFCMToken(String userId, String token) async {
    var uri = Uri.parse('$baseUrl/users/$userId/token');
    try {
      var response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fcmToken': token}),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

// In ApiUserService
  Future<String> getUserImage(String userId) async {
    var url = Uri.parse('$baseUrl/users/$userId/image');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['fileUrl'] ?? 'https://via.placeholder.com/150';
      } else {
        print(
            'Failed to fetch user image with status code: ${response.statusCode}');
        return 'https://via.placeholder.com/150';
      }
    } catch (e) {
      print("Error fetching user image: $e");
      return 'https://via.placeholder.com/150';
    }
  }

  Future<http.Response> getUserById(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    final response = await http.get(url);
    return response;
  }

  Future<http.Response> createUserWithImage(
      Map<String, dynamic> user, File? image) async {
    var uri = Uri.parse('$baseUrl/users'); // Adjust as necessary
    var request = http.MultipartRequest('POST', uri);

    // Add user fields
    user.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image file to the request if it exists
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file', // This should match the name expected by your backend
        image.path,
        // Adjust the media type based on your image type
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<http.Response> createUser(Map<String, dynamic> user) {
    return http.post(
      Uri.parse('$baseUrl/users'), // Adjust this if your endpoint is different
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
  }

  Future<http.Response> updateUserImage(String userId, File imageFile) async {
    var uri = Uri.parse('$baseUrl/users/$userId/image');
    var request = http.MultipartRequest('PATCH', uri);

    // Add image file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'file', // Ensure this matches the field name expected by your backend
      imageFile.path,
    ));

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateUser(
      String userid, Map<String, dynamic> user) async {
    var uri = Uri.parse('$baseUrl/users/$userid');
    var request = http.MultipartRequest('PATCH', uri);

    user.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateUserRole(
      String id, Map<String, dynamic> user, String userId) async {
    var uri = Uri.parse('$baseUrl/users/$userId/role');
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
    return response;
  }

  Future<http.Response> deleteUser(String id) {
    return http.delete(Uri.parse('$baseUrl/users/$id'));
  }
}
