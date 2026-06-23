import 'package:flutter/material.dart';
import 'package:eco/data/repositories/auth_repository.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SplashViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  /// Check if user is already authenticated and determine the next route
  Future<String> getInitialRoute() async {
    // Small delay to let Supabase restore session
    await Future.delayed(const Duration(milliseconds: 500));

    if (_authRepository.isAuthenticated) {
      return '/home';
    }
    return '/login';
  }
}
