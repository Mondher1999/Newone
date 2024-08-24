import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:madidou/data/model/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:madidou/firebase_options.dart';

class MessageApiService {
  //final String baseUrl = 'http://10.0.2.2:3000/message/messages';
  final String baseUrl =
      'https://madidou-backend.onrender.com/message/messages';

  Future<http.Response> sendMessage(
      String senderId, String receiverId, String content, bool read) async {
    var uri = Uri.parse('$baseUrl/send');
    var response = await http.post(uri,
        body: json.encode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'read': read
        }),
        headers: {'Content-Type': 'application/json'});
    return response;
  }

  Future<List<Message>> getMessagesByUser(String user1, String user2) async {
    var uri = Uri.parse('$baseUrl/$user1/$user2');
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body) as List;
        List<Message> messages = decodedResponse
            .map<Message>(
                (item) => Message.fromJson(item as Map<String, dynamic>))
            .toList();
        return messages;
      } else {
        throw Exception(
            'Failed to load messages with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getMessagesByUser: $e');
      throw Exception('Failed to load messages');
    }
  }

  Future<http.Response> updateMessageStatus(
      String messageId, bool readStatus) async {
    var uri = Uri.parse('$baseUrl/update/$messageId');
    var response = await http.patch(uri,
        body: json.encode({'read': readStatus}),
        headers: {'Content-Type': 'application/json'});
    return response;
  }
}
