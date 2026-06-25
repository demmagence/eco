import 'package:flutter/material.dart';
import 'package:eco/data/repositories/auth_repository.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SplashViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  /// Check if user is already authenticated via stored JWT token
  Future<String> getInitialRoute() async {
    // Small delay for splash animation
    await Future.delayed(const Duration(milliseconds: 600));

    if (_authRepository.isAuthenticated) {
      return '/home';
    }
    return '/welcome'; // 🔧 sebelumnya '/login'
  }
}