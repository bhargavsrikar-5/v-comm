class SearchHistoryModel {
  final int id;
  final int userId;
  final int searchedUserId;
  final String searchedUserName;
  final String searchedUserDept;
  final String searchedUserCustomId;
  final DateTime searchedAt;

  SearchHistoryModel({
    required this.id,
    required this.userId,
    required this.searchedUserId,
    required this.searchedUserName,
    required this.searchedUserDept,
    required this.searchedUserCustomId,
    required this.searchedAt,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      searchedUserId: json['searchedUserId'] is int ? json['searchedUserId'] : int.tryParse(json['searchedUserId'].toString()) ?? 0,
      searchedUserName: json['searchedUserName'] ?? '',
      searchedUserDept: json['searchedUserDept'] ?? '',
      searchedUserCustomId: json['searchedUserCustomId'] ?? '',
      searchedAt: json['searchedAt'] != null
          ? DateTime.tryParse(json['searchedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
