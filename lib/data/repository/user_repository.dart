import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/services/user/user_api_service.dart';
import 'package:path/path.dart';

class UserRepository {
  final ApiUserService apiService;

  UserRepository({required this.apiService});

  // Assuming getUserImage directly returns the image URL as a String
// In UserRepository
  Future<String> getUserImageById(String userId) async {
    try {
      String imageUrl = await apiService.getUserImage(userId);
      // Check if imageUrl is null or empty and provide a default
      if (imageUrl.isEmpty) {
        return 'https://via.placeholder.com/150'; // Default or placeholder image URL
      }
      return imageUrl;
    } catch (e) {
      print("Failed to load user image: $e");
      return 'https://via.placeholder.com/150'; // Default or placeholder image URL on error
    }
  }

  Future<List<Users>> getUserFriends(String userId) async {
    try {
      var response = await apiService.getUserFriends(userId);
      if (response.statusCode == 200) {
        List<dynamic> friendData = json.decode(response.body);
        return friendData.map((data) => Users.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load friends: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching friends: $e');
    }
  }

  Future<bool> addFriend(String userId, String friendId) async {
    try {
      var response = await apiService.addFriend(userId, friendId);
      if (response.statusCode == 200) {
        return true; // Friend added successfully
      } else {
        throw Exception('Failed to add friend: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding friend: $e');
    }
  }

  // In user_repository.dart

  Future<bool> deleteFriend(String userId, String friendId) async {
    try {
      var response = await apiService.deleteFriend(userId, friendId);
      if (response.statusCode == 200) {
        return true; // Friend deleted successfully
      } else {
        throw Exception('Failed to delete friend: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting friend: $e');
    }
  }

  Future<bool> updateFCMToken(String userId, String token) async {
    try {
      var response = await apiService.updateFCMToken(userId, token);
      if (response.statusCode == 200) {
        return true;
      } else {
        // Log the error message or handle it in a way that's appropriate for your application
        print('Failed to update FCM token: ${response.body}');
        return false;
      }
    } catch (e) {
      // Log the error message or handle it in a way that's appropriate for your application
      print('Error updating FCM token: $e');
      return false;
    }
  }

  Future<String> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = basename(imagePath);
      final storageRef =
          FirebaseStorage.instance.ref().child('user_images/$fileName');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      print("Failed to upload image: $e");
      throw Exception('Failed to upload image');
    }
  }

  Future<List<Users>> getUsers() async {
    final response = await apiService.getUsers();
    if (response.statusCode == 200) {
      final List<dynamic> userJson = json.decode(response.body);
      return userJson.map((json) => Users.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Users');
    }
  }

  Future<Users> createUser(Users user, File? image) async {
    // Prepare user data
    final userData = user.toJson();
    // Note: Remove fileUrl from userData if it's included, as the image will be sent separately

    final response = await apiService.createUserWithImage(userData, image);
    if (response.statusCode == 200) {
      // Assuming your backend sends back the created user
      return Users.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<Users> getUserById(String userId) async {
    final response = await apiService.getUserById(userId);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Users.fromJson(responseData);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<Users> updateUser(String userId, Users user) async {
    Map<String, dynamic> updatedUserData = user.toJson();

    // Check if an image path was provided and prepare the image file if so

    // Make sure the updateUser call includes all required arguments
    final response = await apiService.updateUser(userId, updatedUserData);

    if (response.statusCode == 200) {
      return Users.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<Users> updateUserRole(
      String id, Map<String, dynamic> roleData, String userId) async {
    final response = await apiService.updateUserRole(id, roleData, userId);

    if (response.statusCode == 200) {
      return Users.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<bool> updateUserImage(String userId, File imageFile) async {
    try {
      var response = await apiService.updateUserImage(userId, imageFile);
      if (response.statusCode == 200) {
        return true; // Image updated successfully
      } else {
        throw Exception('Failed to update image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update image: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await apiService.deleteUser(userId);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
