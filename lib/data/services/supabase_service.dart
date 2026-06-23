import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eco/core/constants/api_constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      publishableKey: ApiConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get instance => client;

  // Auth shortcuts
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;

  // Table references
  static SupabaseQueryBuilder get profiles => client.from('profiles');
  static SupabaseQueryBuilder get scanResults => client.from('scan_results');
  static SupabaseQueryBuilder get chatSessions => client.from('chat_sessions');
  static SupabaseQueryBuilder get chatMessages => client.from('chat_messages');

  // Storage bucket
  static StorageFileApi get scanImagesBucket =>
      storage.from(ApiConstants.scanImagesBucket);

  // Current user
  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
}
