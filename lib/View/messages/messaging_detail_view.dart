import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:madidou/bloc/message/message_bloc.dart';
import 'package:madidou/bloc/message/message_event.dart';
import 'package:madidou/bloc/message/message_state.dart';
import 'package:madidou/data/model/message.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/data/repository/user_repository.dart';
import 'package:madidou/services/user/user_api_service.dart';

class MessagingScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const MessagingScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Message> _messages = [];
  late UserRepository userRepository;
  Users? _otherUser;
  String _imageUrl = 'https://via.placeholder.com/150';
  DateTime? _lastDisplayedTimestamp;
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(apiService: ApiUserService());
    _initSocket();
    _loadMessages();
    _loadOtherUserProfile();
    _loadUserProfileImage();
  }

  void _initSocket() {
    socket = IO.io('https://madidou-backend.onrender.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      print('Connected to socket');
      socket!.emit('joinRoom', {
        'userId': widget.currentUserId,
        'otherUserId': widget.otherUserId,
      });
    });

    socket!.on('roomJoined', (data) {
      print('Joined room: ${data['roomId']}');
    });

    socket!.on('newMessage', (data) {
      print('New message received: $data');
      if (!mounted) return;
      var message = Message.fromJson(data as Map<String, dynamic>);
      setState(() {
        _messages.insert(0, message);
      });
    });

    socket!.onDisconnect((_) => print('Disconnected from socket'));
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  void _loadMessages() {
    BlocProvider.of<MessageBloc>(context).add(GetMessagesEvent(
      userId1: widget.currentUserId,
      userId2: widget.otherUserId,
    ));
  }

  void _loadOtherUserProfile() async {
    try {
      Users user = await userRepository.getUserById(widget.otherUserId);
      setState(() {
        _otherUser = user;
      });
    } catch (e) {
      print("Error loading user profile: $e");
    }
  }

  void _blockTenant() {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      BlocProvider.of<UserBloc>(context).add(DeleteFriendEvent(
        userId: widget.currentUserId,
        friendId: widget.otherUserId,
      ));
      Navigator.of(context).pop();
      print('contact Bloquer avec succès.');
    } else {
      print('No user found, operation cannot proceed.');
    }
  }

  void _showBlockConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir Bloquer ce Contact ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _blockTenant();
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _loadUserProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("No user logged in.");
      return;
    }
    try {
      String imageUrl =
          await userRepository.getUserImageById(widget.otherUserId);
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print("Failed to load user image: $e");
      setState(() {
        _imageUrl = 'https://via.placeholder.com/150';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: _imageUrl.isNotEmpty
                  ? NetworkImage(_imageUrl)
                  : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            SizedBox(width: 25),
            Text(
              _otherUser != null
                  ? "${_otherUser!.prenom} ${_otherUser!.nom}"
                  : "Loading...",
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF5e5f99),
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, size: 25, color: Colors.black),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Bloquer ce Contact'),
              ),
            ],
            onSelected: (item) {
              if (item == 0) {
                _showBlockConfirmationDialog(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is MessageSent) {
                  _listKey.currentState?.insertItem(0);
                }
              },
              builder: (context, state) {
                if (state is MessagesLoaded) {
                  _messages = state.messages;
                  return AnimatedList(
                    key: _listKey,
                    reverse: true,
                    initialItemCount: _messages.length,
                    itemBuilder: (context, index, animation) {
                      return _buildMessageTile(_messages[index], animation);
                    },
                  );
                } else if (state is MessageError) {
                  return Center(
                      child: Text("Failed to load messages: ${state}"));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF5e5f99),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      final content = _messageController.text;

                      // Add the message to Firestore through the bloc
                      BlocProvider.of<MessageBloc>(context).add(
                        SendMessageEvent(
                          senderId: widget.currentUserId,
                          receiverId: widget.otherUserId,
                          content: content,
                        ),
                      );

                      // Emit the message to the server
                      socket?.emit('sendMessage', {
                        'id': UniqueKey()
                            .toString(), // Unique identifier for the message
                        'senderId': widget.currentUserId,
                        'receiverId': widget.otherUserId,
                        'content': content,
                      });

                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldDisplayTimestamp(DateTime timestamp) {
    if (_lastDisplayedTimestamp == null) {
      _lastDisplayedTimestamp = timestamp;
      return true;
    }

    if (_lastDisplayedTimestamp!.day != timestamp.day ||
        _lastDisplayedTimestamp!.month != timestamp.month ||
        _lastDisplayedTimestamp!.year != timestamp.year ||
        _lastDisplayedTimestamp!.hour != timestamp.hour ||
        _lastDisplayedTimestamp!.minute != timestamp.minute) {
      _lastDisplayedTimestamp = timestamp;
      return true;
    }

    return false;
  }

  Widget _buildMessageTile(Message message, Animation<double> animation) {
    bool isSentByCurrentUser = message.senderId == widget.currentUserId;
    bool shouldDisplayTimestamp = _shouldDisplayTimestamp(message.timestamp);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          if (shouldDisplayTimestamp)
            Text(
              DateFormat('MMM dd, h:mm a').format(message.timestamp),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          if (shouldDisplayTimestamp) SizedBox(height: 2),
          FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: Align(
                alignment: isSentByCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSentByCurrentUser ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        spreadRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isSentByCurrentUser ? Colors.white : Colors.black,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
