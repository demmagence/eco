import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eco/data/services/supabase_service.dart';
import 'package:eco/data/models/user_model.dart';
import 'package:eco/core/constants/api_constants.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventsSub;

  /// Initialize Google Sign-In and wire up the credential exchange. Safe to
  /// call repeatedly; only the first call does any work.
  ///
  /// The google_sign_in 7.x plugin is event-driven: both the native flow
  /// ([signInWithGoogle], mobile/desktop) and the rendered Google button
  /// (web) emit a sign-in event on [GoogleSignIn.authenticationEvents]. We
  /// exchange the resulting Google ID token for a Supabase session in one
  /// place, so the rest of the app only has to watch Supabase auth state.
  Future<void> ensureInitialized() async {
    if (_initialized) return;

    // serverClientId is not supported on Web (the google_sign_in_web plugin
    // asserts it is null); the client ID is supplied via the
    // google-signin-client_id meta tag in web/index.html instead.
    await _googleSignIn.initialize(
      clientId: kIsWeb ? ApiConstants.googleWebClientId : null,
      serverClientId: kIsWeb ? null : ApiConstants.googleWebClientId,
    );

    _authEventsSub =
        _googleSignIn.authenticationEvents.listen(_handleAuthenticationEvent);

    _initialized = true;
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;

    final idToken = event.user.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google Sign-In gagal: ID Token tidak ditemukan');
    }

    await SupabaseService.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  /// Trigger the native Google Sign-In flow (mobile/desktop only).
  Future<void> signInWithGoogle() async {
    await ensureInitialized();
    await _googleSignIn.authenticate();
  }

  /// Sign in dengan email + password via Supabase
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await SupabaseService.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Daftar akun baru dengan email + password via Supabase
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await SupabaseService.auth.signUp(
      email: email.trim(),
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
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

  void dispose() {
    _authEventsSub?.cancel();
    _authEventsSub = null;
  }
}
