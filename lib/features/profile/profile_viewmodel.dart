import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco/data/models/user_model.dart';
import 'package:eco/data/repositories/auth_repository.dart';
import 'package:eco/data/repositories/scan_repository.dart';
import 'package:eco/data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ScanRepository _scanRepository;
  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker = ImagePicker();

  UserModel? _user;
  int _totalScans = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  ProfileViewModel({
    AuthRepository? authRepository,
    ScanRepository? scanRepository,
    ProfileRepository? profileRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _scanRepository = scanRepository ?? ScanRepository(),
        _profileRepository = profileRepository ?? ProfileRepository();

  // Getters
  UserModel? get user => _user;
  int get totalScans => _totalScans;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

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

  /// Update display name
  Future<bool> updateDisplayName(String name) async {
    if (name.isEmpty) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final updatedUser = await _profileRepository.updateProfile(displayName: name);
      if (updatedUser != null) {
        _user = updatedUser;
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isSaving = false;
    notifyListeners();
    return false;
  }

  /// Pick and upload avatar
  Future<bool> pickAndUploadAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image == null) return false;

      _isSaving = true;
      notifyListeners();

      final Uint8List bytes = await image.readAsBytes();
      final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final updatedUser = await _profileRepository.uploadAvatar(bytes, fileName);

      _user = updatedUser;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {}

    _isSaving = false;
    notifyListeners();
    return false;
  }

  /// Remove avatar
  Future<bool> removeAvatar() async {
    if (_user?.photoUrl == null) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final updatedUser = await _profileRepository.deleteAvatar();

      _user = updatedUser;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {}

    _isSaving = false;
    notifyListeners();
    return false;
  }
}
