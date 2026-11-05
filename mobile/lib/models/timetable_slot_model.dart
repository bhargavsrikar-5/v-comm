class TimetableSlotModel {
  final int id;
  final int userId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String courseName;
  final String? activityDetails;
  final String? location;

  const TimetableSlotModel({required this.id, required this.userId, required this.dayOfWeek,
    required this.startTime, required this.endTime, required this.courseName,
    this.activityDetails, this.location});

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) => TimetableSlotModel(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    userId: json['userId'] is int ? json['userId'] : int.tryParse('${json['userId']}') ?? 0,
    dayOfWeek: json['dayOfWeek'] ?? 'MONDAY', startTime: json['startTime'] ?? '09:00:00',
    endTime: json['endTime'] ?? '10:00:00', courseName: json['courseName'] ?? '',
    activityDetails: json['activityDetails'], location: json['location']);
}
