import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Cho Flutter web (Chrome) khi backend listen http://localhost:5201
  static const String baseUrl = 'http://localhost:5201/api';

  // ===== AUTH =====

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    }
    return null;
  }

  static Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> me() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final res = await http.get(
      Uri.parse('$baseUrl/Auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  // ===== COURTS & BOOKINGS =====

  static Future<List<dynamic>> getCourts() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/Court'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getMembers() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/Member'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['items'] as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getBookingsCalendar({
    required DateTime from,
    required DateTime to,
  }) async {
    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse(
      '$baseUrl/Booking/calendar?from=${from.toIso8601String()}&to=${to.toIso8601String()}',
    );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getMyBookings() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/Booking/my-bookings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> createBooking({
    required int courtId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/Booking'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'courtId': courtId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> cancelBooking(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/Booking/cancel/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // ===== WALLET =====

  static Future<bool> deposit({
    required double amount,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse('$baseUrl/Wallet/deposit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount, 'description': description}),
    );

    return res.statusCode == 200;
  }

  static Future<List<dynamic>> walletTransactions() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/Wallet/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> adminAllTransactions() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/Wallet/admin/all'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getTournaments({String? status}) async {
    final token = await _getToken();
    if (token == null) return [];

    var url = '$baseUrl/Tournament';
    if (status != null) url += '?status=$status';

    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> joinTournament({
    required int tournamentId,
    required String? groupName,
    required int teamSize,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse('$baseUrl/Tournament/$tournamentId/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'groupName': groupName, 'teamSize': teamSize}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> createTournament({
    required String name,
    required String? description,
    required DateTime? startDate,
    required DateTime? endDate,
    required double entryFee,
    required int maxPlayers,
    required String type,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/Tournament'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'entryFee': entryFee,
        'maxPlayers': maxPlayers,
        'type': type,
      }),
    );

    return response.statusCode == 200;
  }

  // ===== ADMIN (đơn giản) =====

  static Future<List<dynamic>> adminAllBookings() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/Booking'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getNotifications() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/Notification'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['items'] as List<dynamic>;
    }
    return [];
  }

  static Future<int> getUnreadNotificationCount() async {
    final token = await _getToken();
    if (token == null) return 0;

    final res = await http.get(
      Uri.parse('$baseUrl/Notification'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['unreadCount'] as int? ?? 0;
    }
    return 0;
  }

  // ===== Helpers =====

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
