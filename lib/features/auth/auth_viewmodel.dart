import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eco/data/repositories/auth_repository.dart';
import 'package:eco/data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authStateSub;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;
  bool _isAuthenticated = false;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  /// Prepare Google Sign-In. Must be called before sign-in so the web button
  /// can render and the credential-exchange listener is wired up.
  ///
  /// Subscribing to auth-state changes is done here (not in the constructor)
  /// because it touches Supabase, which is only initialized once the app has
  /// booted via `main()` — keeping the constructor side-effect-free lets the
  /// widget test build the view model without a live Supabase instance.
  Future<void> initialize() async {
    try {
      _isAuthenticated = _authRepository.isAuthenticated;
      // Completion of sign-in (web button or mobile flow) surfaces here once
      // the ID token has been exchanged for a Supabase session.
      _authStateSub ??=
          _authRepository.authStateChanges.listen(_onAuthStateChanged);

      await _authRepository.ensureInitialized();
    } catch (e) {
      _errorMessage = 'Gagal menyiapkan Google Sign-In: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(AuthState state) async {
    final signedIn = state.session != null;
    _isAuthenticated = signedIn;
    if (signedIn) {
      _user = await _authRepository.getUserProfile();
      _isLoading = false;
      _errorMessage = null;
    } else {
      _user = null;
    }
    notifyListeners();
  }

  /// Trigger the native Google Sign-In flow on mobile/desktop.
  ///
  /// On Web this is a no-op: the rendered Google button (see
  /// `google_sign_in_button.dart`) starts the flow instead, and completion is
  /// handled by [_onAuthStateChanged].
  Future<void> signInWithGoogle() async {
    if (kIsWeb) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signInWithGoogle();
      // Success (profile load + isAuthenticated) arrives via the auth-state
      // listener; keep showing the loader until then.
    } catch (e) {
      _errorMessage = 'Gagal masuk: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal keluar: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user profile
  Future<void> loadUserProfile() async {
    try {
      _user = await _authRepository.getUserProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSub?.cancel();
    _authRepository.dispose();
    super.dispose();
  }
}
