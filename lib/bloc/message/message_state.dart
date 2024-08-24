import 'package:madidou/data/model/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageSent extends MessageState {
  final Message message;
  MessageSent(this.message);
}

class MessagesLoaded extends MessageState {
  final List<Message> messages;
  MessagesLoaded(this.messages);
}

class MessageUpdated extends MessageState {}

class MessageError extends MessageState {
  final String message;
  MessageError(this.message);
}
