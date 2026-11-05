class GroupMemberModel {
  final int userId;
  final String name;
  final String email;
  final String role;
  const GroupMemberModel({required this.userId, required this.name, required this.email, required this.role});
  factory GroupMemberModel.fromJson(Map<String, dynamic> json) => GroupMemberModel(
    userId: json['userId'] is int ? json['userId'] : int.tryParse('${json['userId']}') ?? 0,
    name: json['name'] ?? '', email: json['email'] ?? '', role: json['role'] ?? 'MEMBER');
}

class GroupModel {
  final int id;
  final String name;
  final String description;
  final int ownerId;
  final String? myRole;
  final int unreadCount;
  final String lastMessage;
  final List<GroupMemberModel> members;
  const GroupModel({required this.id, required this.name, required this.description,
    required this.ownerId, required this.myRole, required this.unreadCount,
    required this.lastMessage, required this.members});
  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    name: json['name'] ?? '', description: json['description'] ?? '',
    ownerId: json['ownerId'] is int ? json['ownerId'] : int.tryParse('${json['ownerId']}') ?? 0,
    myRole: json['myRole'],
    unreadCount: json['unreadCount'] is int ? json['unreadCount'] : int.tryParse('${json['unreadCount']}') ?? 0,
    lastMessage: json['lastMessage'] ?? '',
    members: (json['members'] as List? ?? []).map((m) => GroupMemberModel.fromJson(m)).toList());
}

class GroupMessageModel {
  final int id;
  final int groupId;
  final int senderId;
  final String content;
  final DateTime sentAt;
  const GroupMessageModel({required this.id, required this.groupId, required this.senderId, required this.content, required this.sentAt});
  factory GroupMessageModel.fromJson(Map<String, dynamic> json) => GroupMessageModel(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    groupId: json['groupId'] is int ? json['groupId'] : int.tryParse('${json['groupId']}') ?? 0,
    senderId: json['senderId'] is int ? json['senderId'] : int.tryParse('${json['senderId']}') ?? 0,
    content: json['content'] ?? '', sentAt: DateTime.tryParse('${json['sentAt']}') ?? DateTime.now());
}
