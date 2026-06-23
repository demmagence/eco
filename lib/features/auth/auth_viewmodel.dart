import 'package:flutter/material.dart';
import 'package:eco/data/repositories/auth_repository.dart';
import 'package:eco/data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signInWithGoogle();
      _user = await _authRepository.getUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal masuk: ${e.toString()}';
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
}
