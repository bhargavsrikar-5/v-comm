class UserModel {
  final int id;
  final String name;
  final String email;
  final String dept;
  final String customId;
  final String phoneNumber;
  final String? photoUrl;
  final String? timetableUrl;
  final bool isPresent;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.dept,
    required this.customId,
    required this.phoneNumber,
    this.photoUrl,
    this.timetableUrl,
    required this.isPresent,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      dept: json['dept'] ?? '',
      customId: json['customId'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      photoUrl: json['photoUrl'],
      timetableUrl: json['timetableUrl'],
      isPresent: json['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dept': dept,
      'customId': customId,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'timetableUrl': timetableUrl,
      'isPresent': isPresent,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? dept,
    String? customId,
    String? phoneNumber,
    String? photoUrl,
    String? timetableUrl,
    bool? isPresent,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dept: dept ?? this.dept,
      customId: customId ?? this.customId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      timetableUrl: timetableUrl ?? this.timetableUrl,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}
