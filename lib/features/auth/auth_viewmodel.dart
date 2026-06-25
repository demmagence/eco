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

  /// Initialize auth state from local storage (SharedPreferences).
  void initialize() {
    _isAuthenticated = _authRepository.isAuthenticated;
    if (_isAuthenticated) {
      _user = _authRepository.currentUser;
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
      _user = await _authRepository.signUp(
        username: username,
        password: password,
        displayName: displayName,
        email: email,
      );
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
