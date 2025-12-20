import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserService {
  static const String baseUrl = 'http://localhost:8000';
  
  // Get all users - PAKAI CookieRequest
  static Future<List<User>> getAllUsers(CookieRequest request) async {
    try {
      print('🔍 Fetching users with authenticated request...');
      
      final response = await request.get('$baseUrl/users/');
      
      print('📊 Response: $response');
      
      if (response != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('❌ Error in getAllUsers: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Promote user ke admin - PAKAI CookieRequest
  static Future<Map<String, dynamic>> promoteUser(
    CookieRequest request, 
    String username
  ) async {
    try {
      print('⬆️ Promoting user: $username');
      
      final response = await request.post(
        '$baseUrl/api/promote-admin/',
        {
          'username': username,
        },
      );

      print('📊 Promote response: $response');

      if (response != null && response['message'] != null) {
        return response;
      } else {
        throw Exception('Failed to promote user');
      }
    } catch (e) {
      print('❌ Error in promoteUser: $e');
      throw Exception('Error promoting user: $e');
    }
  }

  // Demote admin ke user - PAKAI CookieRequest
  static Future<Map<String, dynamic>> demoteUser(
    CookieRequest request,
    String username
  ) async {
    try {
      print('⬇️ Demoting user: $username');
      
      final response = await request.post(
        '$baseUrl/api/demote-admin/',
        {
          'username': username,
        },
      );

      print('📊 Demote response: $response');

      if (response != null && response['message'] != null) {
        return response;
      } else {
        throw Exception('Failed to demote user');
      }
    } catch (e) {
      print('❌ Error in demoteUser: $e');
      throw Exception('Error demoting user: $e');
    }
  }
}

// Model User
class User {
  final String id;
  final String username;
  final bool isAdmin;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.isAdmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'is_admin': isAdmin,
      'created_at': createdAt,
    };
  }

  String get role => isAdmin ? 'Admin' : 'User';
  
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }
}