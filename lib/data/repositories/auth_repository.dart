import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eco/data/services/supabase_service.dart';
import 'package:eco/data/models/user_model.dart';
import 'package:eco/core/constants/api_constants.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize(
        serverClientId: ApiConstants.googleWebClientId,
      );
      _initialized = true;
    }
  }

  /// Sign in with Google via Supabase
  Future<AuthResponse> signInWithGoogle() async {
    await _ensureInitialized();

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Google Sign-In gagal: ID Token tidak ditemukan');
    }

    final response = await SupabaseService.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await SupabaseService.auth.signOut();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => SupabaseService.isAuthenticated;

  /// Get current user
  User? get currentUser => SupabaseService.currentUser;

  /// Get user profile from Supabase
  Future<UserModel?> getUserProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;

    final response = await SupabaseService.profiles
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      // Merge auth email with profile data
      response['email'] = currentUser?.email ?? '';
      return UserModel.fromJson(response);
    }
    return null;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges =>
      SupabaseService.auth.onAuthStateChange;
}
