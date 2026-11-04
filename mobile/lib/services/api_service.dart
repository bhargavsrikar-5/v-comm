import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/search_history_model.dart';
import '../utils/constants.dart';
import 'auth_state.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> _authenticatedHeaders() async {
    final headers = <String, String>{...defaultHeaders};
    final token = AuthState().accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // =========================================================================
  // AUTHENTICATION APIs
  // =========================================================================

  /// POST /api/auth/login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: defaultHeaders,
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': UserModel.fromJson(data['user']),
          'token': data['token'] as String,
          'tokenType': data['tokenType'] ?? 'Bearer',
          'expiresInSeconds': data['expiresInSeconds'] as int,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid email or password',
        };
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  /// POST /api/auth/change-password
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? (response.statusCode == 200 ? 'Password changed' : 'Failed to change password'),
      };
    } catch (e) {
      debugPrint("Change password error: $e");
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =========================================================================
  // USER APIs
  // =========================================================================

  /// GET /api/users (with optional search query)
  static Future<List<UserModel>> searchUsers({String? query}) async {
    try {
      final uri = query != null && query.isNotEmpty
          ? Uri.parse('$baseUrl/users?query=${Uri.encodeComponent(query)}')
          : Uri.parse('$baseUrl/users');

      final response = await http.get(uri, headers: await _authenticatedHeaders());
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => UserModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
    return [];
  }

  /// GET /api/users/{id}
  static Future<UserModel?> getUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching user $id: $e");
    }
    return null;
  }

  /// PUT /api/users/{id}
  static Future<UserModel?> updateUser(int id, {
    String? name,
    String? dept,
    String? customId,
    String? phoneNumber,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({
          if (name != null) 'name': name.trim(),
          if (dept != null) 'dept': dept.trim(),
          if (customId != null) 'customId': customId.trim(),
          if (phoneNumber != null) 'phoneNumber': phoneNumber.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error updating user $id: $e");
    }
    return null;
  }

  /// PUT /api/users/{id}/status
  static Future<UserModel?> updateStatus(int id, bool isPresent) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id/status'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({'isPresent': isPresent}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
    return null;
  }

  /// PUT /api/users/{id}/timetable
  static Future<UserModel?> updateTimetable(int id, String timetableUrl) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id/timetable'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({'timetableUrl': timetableUrl.trim()}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error updating timetable: $e");
    }
    return null;
  }

  /// GET /api/users/{id}/search-history
  static Future<List<SearchHistoryModel>> getSearchHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/search-history'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => SearchHistoryModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error getting search history: $e");
    }
    return [];
  }

  /// POST /api/users/{id}/search-history
  static Future<void> saveSearchHistory(int userId, int searchedUserId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/users/$userId/search-history'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({'searchedUserId': searchedUserId}),
      );
    } catch (e) {
      debugPrint("Error saving search history: $e");
    }
  }

  /// DELETE /api/users/{id}/search-history
  static Future<void> clearSearchHistory(int userId, {int? searchedUserId}) async {
    try {
      final uri = searchedUserId != null
          ? Uri.parse('$baseUrl/users/$userId/search-history?searchedUserId=$searchedUserId')
          : Uri.parse('$baseUrl/users/$userId/search-history');
      await http.delete(uri, headers: await _authenticatedHeaders());
    } catch (e) {
      debugPrint("Error clearing search history: $e");
    }
  }

  // =========================================================================
  // EVENTS APIs
  // =========================================================================

  /// GET /api/events/today?userId={userId}
  static Future<List<EventModel>> getTodayEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/today'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching today events: $e");
    }
    return [];
  }

  /// GET /api/events/upcoming?userId={userId}
  static Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching upcoming events: $e");
    }
    return [];
  }

  /// GET /api/events?userId={userId}&date={date}
  static Future<List<EventModel>> getEvents({DateTime? date}) async {
    try {
      String dateStr = '';
      if (date != null) {
        dateStr = "date=${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      final response = await http.get(
        Uri.parse(dateStr.isEmpty ? '$baseUrl/events' : '$baseUrl/events?$dateStr'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
    }
    return [];
  }

  /// POST /api/events
  static Future<EventModel?> createEvent({
    required String title,
    required String time,
    required DateTime eventDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({
          'title': title.trim(),
          'time': time.trim(),
          'eventDate': "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
        }),
      );

      if (response.statusCode == 200) {
        return EventModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error creating event: $e");
    }
    return null;
  }

  /// PUT /api/events/{id}
  static Future<EventModel?> updateEvent(int id, {
    required String title,
    required String time,
    DateTime? eventDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/$id'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({
          'title': title.trim(),
          'time': time.trim(),
          if (eventDate != null)
            'eventDate': "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
        }),
      );

      if (response.statusCode == 200) {
        return EventModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error updating event $id: $e");
    }
    return null;
  }

  /// DELETE /api/events/{id}
  static Future<bool> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$id'),
        headers: await _authenticatedHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error deleting event $id: $e");
      return false;
    }
  }

  // =========================================================================
  // CHAT & MESSAGING APIs
  // =========================================================================

  /// GET /api/messages/conversations?userId={userId}
  static Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => ConversationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching conversations: $e");
    }
    return [];
  }

  /// GET /api/messages/history?user1={user1}&user2={user2}
  static Future<List<MessageModel>> getChatHistory(int otherUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/history?otherUserId=$otherUserId'),
        headers: await _authenticatedHeaders(),
      );
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((json) => MessageModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching chat history: $e");
    }
    return [];
  }

  /// POST /api/messages
  static Future<MessageModel?> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: await _authenticatedHeaders(),
        body: jsonEncode({
          'receiverId': receiverId,
          'content': content.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return MessageModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
    return null;
  }
}
