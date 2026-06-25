import 'package:flutter/material.dart';
import 'package:eco/data/repositories/auth_repository.dart';
import 'package:eco/data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

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
    notifyListeners();
  }

  /// Sign In menggunakan Username dan Password.
  Future<bool> signIn(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signIn(username: username, password: password);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register user baru.
  Future<bool> signUp({
    required String username,
    required String password,
    required String displayName,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
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
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal keluar: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user profile dari server
  Future<void> loadUserProfile() async {
    try {
      _user = await _authRepository.getUserProfile();
      notifyListeners();
    } catch (e) {
      // Fail silently, keep existing user data
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
