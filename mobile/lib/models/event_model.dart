class EventModel {
  final int id;
  final int userId;
  final String title;
  final String time;
  final DateTime eventDate;
  final String description;
  final String? startTime;
  final String? endTime;
  final String visibility;
  final int? reminderMinutesBefore;

  EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.time,
    required this.eventDate,
    this.description = '',
    this.startTime,
    this.endTime,
    this.visibility = 'PRIVATE',
    this.reminderMinutesBefore,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['eventDate'] != null) {
      parsedDate = DateTime.tryParse(json['eventDate'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return EventModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      eventDate: parsedDate,
      description: json['description'] ?? '',
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      visibility: json['visibility'] ?? 'PRIVATE',
      reminderMinutesBefore: json['reminderMinutesBefore'] is int
          ? json['reminderMinutesBefore'] as int
          : int.tryParse(json['reminderMinutesBefore']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'time': time,
      'eventDate': "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'visibility': visibility,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }
}
