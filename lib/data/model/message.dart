class Message {
  String? id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool read;
  final DateTime timestamp;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.read,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ??
          'default_id', // Provide default values or handle null
      senderId: json['senderId'] as String? ?? 'default_sender',
      receiverId: json['receiverId'] as String? ?? 'default_receiver',
      content: json['content'] as String? ?? 'No content',
      read: json['read'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['timestamp']['_seconds'] * 1000 +
                  json['timestamp']['_nanoseconds'] ~/ 1000000)
          : DateTime.now(), // Use current time as default if timestamp is null
    );
  }
}
