import 'user_model.dart';

class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime;
    if (json['sentAt'] != null) {
      parsedTime = DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return MessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      senderId: json['senderId'] is int ? json['senderId'] : int.tryParse(json['senderId'].toString()) ?? 0,
      receiverId: json['receiverId'] is int ? json['receiverId'] : int.tryParse(json['receiverId'].toString()) ?? 0,
      content: json['content'] ?? '',
      sentAt: parsedTime,
      isRead: json['isRead'] ?? false,
    );
  }
}

class ConversationModel {
  final UserModel otherUser;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      otherUser: UserModel.fromJson(json['otherUser']),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: json['unreadCount'] is int ? json['unreadCount'] : int.tryParse(json['unreadCount'].toString()) ?? 0,
    );
  }
}
