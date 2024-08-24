import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/message/message_event.dart';
import 'package:madidou/bloc/message/message_state.dart';
import 'package:madidou/data/model/message.dart';
import 'package:madidou/data/repository/message_repository.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository repository;
  List<Message> messages =
      []; // Assuming you maintain a list of messages in the bloc

  MessageBloc({required this.repository}) : super(MessageInitial()) {
    on<SendMessageEvent>((event, emit) async {
      try {
        // Attempt to send the message using your repository function
        final message = await repository.sendMessage(
            event.senderId, event.receiverId, event.content);

        // Assuming 'messages' is your state list that tracks messages

        // Emit a new state with the updated list of messages
      } catch (error) {
        // Emit an error state with a descriptive error message
        emit(MessageError('Failed to send message: $error'));
      }
    });

    on<NewMessageReceived>((event, emit) {
      messages.insert(0, event.message);
      emit(MessagesLoaded(List.from(messages)));
    });

    on<GetMessagesEvent>((event, emit) async {
      try {
        messages =
            await repository.getMessagesByUser(event.userId1, event.userId2);
        emit(MessagesLoaded(messages));
      } catch (error) {
        emit(MessageError('Failed to fetch messages: $error'));
      }
    });

    on<UpdateMessageStatusEvent>((event, emit) async {
      emit(MessageLoading());
      try {
        await repository.updateMessageStatus(event.messageId, event.readStatus);
        emit(MessageUpdated());
      } catch (error) {
        print('Error updating message status: $error');
        emit(MessageError('Failed to update message status: $error'));
      }
    });
  }
}
