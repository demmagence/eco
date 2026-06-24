import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eco/data/services/supabase_service.dart';
import 'package:eco/data/models/user_model.dart';

/// Repository for profile-specific operations: avatar upload/delete and
/// profile field updates.
class ProfileRepository {
  /// Upload avatar bytes to the `avatars` bucket and return the public URL.
  Future<String> uploadAvatar(Uint8List bytes, String fileName) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final path = '$userId/$fileName';

    // Remove old file at that path if it exists (ignore errors)
    try {
      await SupabaseService.avatarsBucket.remove([path]);
    } catch (_) {}

    await SupabaseService.avatarsBucket.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: true,
      ),
    );

    final publicUrl = SupabaseService.avatarsBucket.getPublicUrl(path);
    return publicUrl;
  }

  /// Delete the avatar file from storage.
  Future<void> deleteAvatar(String url) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    // Extract path from URL — the path after '/avatars/'
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final bucketIdx = segments.indexOf('avatars');
    if (bucketIdx >= 0 && bucketIdx < segments.length - 1) {
      final path = segments.sublist(bucketIdx + 1).join('/');
      try {
        await SupabaseService.avatarsBucket.remove([path]);
      } catch (_) {}
    }
  }

  /// Update profile fields in the `profiles` table.
  Future<UserModel?> updateProfile({
    String? displayName,
    String? photoUrl,
    bool clearPhoto = false,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (clearPhoto) {
      updates['photo_url'] = null;
    } else if (photoUrl != null) {
      updates['photo_url'] = photoUrl;
    }

    if (updates.isEmpty) return null;

    await SupabaseService.profiles
        .update(updates)
        .eq('id', userId);

    // Fetch updated profile
    final response = await SupabaseService.profiles
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      response['email'] = SupabaseService.currentUser?.email ?? '';
      return UserModel.fromJson(response);
    }
    return null;
  }
}
