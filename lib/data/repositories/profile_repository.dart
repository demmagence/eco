import 'dart:typed_data';
import 'dart:convert';
import 'package:eco/data/services/api_service.dart';
import 'package:eco/data/models/user_model.dart';

/// Repository for profile-specific operations: avatar upload/delete and
/// profile field updates.
class ProfileRepository {
  /// Upload avatar bytes to the server and return the updated UserModel.
  Future<UserModel> uploadAvatar(Uint8List bytes, String fileName) async {
    final response = await ApiService.uploadFile(
      '/profile/avatar',
      bytes,
      'avatar',
      fileName,
      'image/jpeg',
    );

    final body = await response.stream.toBytes();
    final data = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'Gagal mengunggah foto profil.');
    }

    await ApiService.saveUser(data);
    return UserModel.fromJson(data);
  }

  /// Delete the avatar file from the server and return the updated UserModel.
  Future<UserModel> deleteAvatar() async {
    final response = await ApiService.delete('/profile/avatar');
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'Gagal menghapus foto profil.');
    }
    await ApiService.saveUser(data);
    return UserModel.fromJson(data);
  }

  /// Update profile fields.
  Future<UserModel?> updateProfile({
    String? displayName,
    String? photoUrl,
    bool clearPhoto = false,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;

    if (updates.isEmpty) return null;

    final response = await ApiService.put('/profile', updates);
    final data = ApiService.decodeResponse(response);
    await ApiService.saveUser(data);
    return UserModel.fromJson(data);
  }
}
