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
    // Selalu pasang listener auth state Supabase — dibutuhkan untuk email/password
    // maupun Google Sign-In flow.
    _isAuthenticated = _authRepository.isAuthenticated;
    _authStateSub ??=
        _authRepository.authStateChanges.listen(_onAuthStateChanged);

    // Google Sign-In init hanya dibutuhkan kalau pakai Google auth.
    // Error-nya diabaikan supaya tidak muncul di form login email/password.
    try {
      await _authRepository.ensureInitialized();
    } catch (_) {
      // Google Sign-In tidak wajib — abaikan saja
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
    } catch (e) {
      _errorMessage = 'Gagal masuk: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login dengan email + password via Supabase
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );
      // Sukses → auth state listener (_onAuthStateChanged) akan update status
    } catch (e) {
      _errorMessage = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Daftar akun baru dengan email + password
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      _errorMessage = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Terjemahkan error Supabase ke pesan yang ramah pengguna
  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Email atau password salah. Coba lagi.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox kamu.';
    }
    if (raw.contains('User already registered')) {
      return 'Email sudah terdaftar. Coba masuk.';
    }
    if (raw.contains('Password should be at least')) {
      return 'Password minimal 6 karakter.';
    }
    if (raw.contains('Unable to validate email')) {
      return 'Format email tidak valid.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
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
