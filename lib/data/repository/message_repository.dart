import 'dart:convert';
import 'package:madidou/data/model/message.dart';
import 'package:madidou/services/message/message_api_service.dart';

class MessageRepository {
  final MessageApiService apiService;

  MessageRepository({required this.apiService});

// In MessageRepository
  Future<Message> sendMessage(
      String senderId, String receiverId, String content) async {
    try {
      final response =
          await apiService.sendMessage(senderId, receiverId, content, false);
      if (response.statusCode == 200) {
        return Message.fromJson(json.decode(
            response.body)); // Assuming the server returns a Message object
      } else {
        throw Exception('Failed to send message: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending message from $senderId to $receiverId: $e');
      throw Exception('Error sending message: $e');
    }
  }

  Future<List<Message>> getMessagesByUser(
      String userId1, String userId2) async {
    try {
      final messages = await apiService.getMessagesByUser(userId1, userId2);
      return messages;
    } catch (e) {
      print('Error fetching messages between $userId1 and $userId2: $e');
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<bool> updateMessageStatus(String messageId, bool readStatus) async {
    try {
      final response =
          await apiService.updateMessageStatus(messageId, readStatus);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to update message status: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating message status for $messageId: $e');
      throw Exception('Error updating message status: $e');
    }
  }
}
