import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  String? _errorMessage;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isTakingPicture => _isTakingPicture;
  String? get errorMessage => _errorMessage;

  /// Initialize camera
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _errorMessage = 'Tidak ada kamera yang tersedia';
        notifyListeners();
        return;
      }

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal mengakses kamera: $e';
      notifyListeners();
    }
  }

  /// Capture image from camera
  Future<Uint8List?> captureImage() async {
    if (_controller == null || !_isInitialized || _isTakingPicture) return null;

    _isTakingPicture = true;
    notifyListeners();

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      _isTakingPicture = false;
      notifyListeners();
      return bytes;
    } catch (e) {
      _errorMessage = 'Gagal mengambil foto: $e';
      _isTakingPicture = false;
      notifyListeners();
      return null;
    }
  }

  /// Pick image from gallery
  Future<Uint8List?> pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file != null) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      _errorMessage = 'Gagal memilih foto: $e';
      notifyListeners();
      return null;
    }
  }

  /// Dispose camera controller
  void disposeCamera() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }
}
