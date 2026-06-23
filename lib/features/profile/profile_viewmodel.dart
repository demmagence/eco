import 'package:flutter/material.dart';
import 'package:eco/data/models/user_model.dart';
import 'package:eco/data/repositories/auth_repository.dart';
import 'package:eco/data/repositories/scan_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ScanRepository _scanRepository;

  UserModel? _user;
  int _totalScans = 0;
  bool _isLoading = true;

  ProfileViewModel({
    AuthRepository? authRepository,
    ScanRepository? scanRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _scanRepository = scanRepository ?? ScanRepository();

  // Getters
  UserModel? get user => _user;
  int get totalScans => _totalScans;
  bool get isLoading => _isLoading;

  /// Load profile data
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authRepository.getUserProfile();
      _totalScans = await _scanRepository.getScanCount();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
