import 'package:madidou/data/model/message.dart';

abstract class MessageEvent {}

class SendMessageEvent extends MessageEvent {
  final String senderId;
  final String receiverId;
  final String content;

  SendMessageEvent(
      {required this.senderId,
      required this.receiverId,
      required this.content});
}

class NewMessageReceived extends MessageEvent {
  final Message message;
  NewMessageReceived(this.message);
}

// In your MessageBloc

class GetMessagesEvent extends MessageEvent {
  final String userId1;
  final String userId2;

  GetMessagesEvent({required this.userId1, required this.userId2});
}

class UpdateMessageStatusEvent extends MessageEvent {
  final String messageId;
  final bool readStatus;

  UpdateMessageStatusEvent({required this.messageId, required this.readStatus});
}
