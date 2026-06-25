import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  // --- Base URL Configuration ---
  // On Web / Windows / Linux / macOS, the backend runs on localhost:3000
  // On Android Emulator, the host machine localhost is mapped to 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    // defaultTargetPlatform not needed, use kIsWeb and let others use localhost
    return 'http://localhost:3000/api';
  }

  // --- SharedPreferences Keys ---
  static const String _tokenKey = 'auth_jwt_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _userNisKey = 'auth_user_nis';
  static const String _userDisplayNameKey = 'auth_user_display_name';
  static const String _userUsernameKey = 'auth_user_username';
  static const String _userEmailKey = 'auth_user_email';
  static const String _userPhotoUrlKey = 'auth_user_photo_url';
  static const String _userCreatedAtKey = 'auth_user_created_at';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences — call once at app startup.
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Token Management ---
  static String? get token => _prefs?.getString(_tokenKey);

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(_tokenKey);
  }

  // --- Current User State ---
  static String? get currentUserId => _prefs?.getString(_userIdKey);
  static String? get currentUserNis => _prefs?.getString(_userNisKey);
  static String? get currentUserDisplayName => _prefs?.getString(_userDisplayNameKey);
  static String? get currentUserUsername => _prefs?.getString(_userUsernameKey);
  static String? get currentUserEmail => _prefs?.getString(_userEmailKey);
  static String? get currentUserPhotoUrl => _prefs?.getString(_userPhotoUrlKey);
  static String? get currentUserCreatedAt => _prefs?.getString(_userCreatedAtKey);
  static bool get isAuthenticated => token != null && currentUserId != null;

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setString(_userIdKey, user['id'] as String? ?? '');
    await _prefs?.setString(_userNisKey, user['nis'] as String? ?? '');
    await _prefs?.setString(_userDisplayNameKey, user['display_name'] as String? ?? '');
    final username = user['username'] as String?;
    if (username != null) await _prefs?.setString(_userUsernameKey, username);
    final email = user['email'] as String?;
    if (email != null) await _prefs?.setString(_userEmailKey, email);
    final photoUrl = user['photo_url'] as String?;
    if (photoUrl != null) {
      await _prefs?.setString(_userPhotoUrlKey, photoUrl);
    } else {
      await _prefs?.remove(_userPhotoUrlKey);
    }
    final createdAt = user['created_at']?.toString();
    if (createdAt != null) await _prefs?.setString(_userCreatedAtKey, createdAt);
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_userNisKey);
    await _prefs?.remove(_userDisplayNameKey);
    await _prefs?.remove(_userUsernameKey);
    await _prefs?.remove(_userEmailKey);
    await _prefs?.remove(_userPhotoUrlKey);
    await _prefs?.remove(_userCreatedAtKey);
  }

  static Future<void> signOut() async {
    await clearToken();
    await clearUser();
  }

  // --- HTTP Helpers ---
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  /// GET request
  static Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: _headers);
  }

  /// POST request with JSON body
  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: _headers, body: jsonEncode(body));
  }

  /// PUT request with JSON body
  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.put(uri, headers: _headers, body: jsonEncode(body));
  }

  /// DELETE request
  static Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: _headers);
  }

  /// Multipart POST for file upload
  static Future<http.StreamedResponse> uploadFile(
    String path,
    List<int> fileBytes,
    String fieldName,
    String filename,
    String mimeType,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${token ?? ""}';

    request.files.add(http.MultipartFile.fromBytes(
      fieldName,
      fileBytes,
      filename: filename,
    ));

    return request.send();
  }

  /// Resolve the full URL for a relative server path (e.g. "uploads/avatars/x.jpg")
  static String resolveUrl(String relativePath) {
    final base = kIsWeb ? 'http://localhost:3000' : 'http://localhost:3000';
    if (relativePath.startsWith('http')) return relativePath;
    return '$base/$relativePath';
  }

  /// Decode JSON response or throw formatted error
  static Map<String, dynamic> decodeResponse(http.Response response) {
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['error'] ?? 'Terjadi kesalahan server (${response.statusCode})');
  }
}
