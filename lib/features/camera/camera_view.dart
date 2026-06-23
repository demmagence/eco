import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/features/camera/camera_viewmodel.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraViewModel _cameraVM;

  @override
  void initState() {
    super.initState();
    _cameraVM = context.read<CameraViewModel>();
    _cameraVM.initializeCamera();
  }

  @override
  void dispose() {
    _cameraVM.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, cameraVM, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            if (cameraVM.isInitialized && cameraVM.controller != null)
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: cameraVM.controller!.value.previewSize?.height ?? 0,
                    height: cameraVM.controller!.value.previewSize?.width ?? 0,
                    child: CameraPreview(cameraVM.controller!),
                  ),
                ),
              )
            else
              Container(
                color: Colors.black,
                child: Center(
                  child: cameraVM.errorMessage != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.white54,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              cameraVM.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                ),
              ),

            // Top hint
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    AppStrings.cameraHint,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    _ControlButton(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () => _pickFromGallery(context, cameraVM),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: cameraVM.isTakingPicture
                          ? null
                          : () => _captureImage(context, cameraVM),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 4,
                          ),
                        ),
                        child: cameraVM.isTakingPicture
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.camera,
                                color: AppColors.primary,
                                size: 36,
                              ),
                      ),
                    ),

                    // Chatbot button
                    _ControlButton(
                      icon: Icons.chat,
                      label: 'Chatbot',
                      onTap: () => Navigator.of(context).pushNamed('/chatbot'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureImage(
    BuildContext context,
    CameraViewModel cameraVM,
  ) async {
    final bytes = await cameraVM.captureImage();
    if (bytes != null && context.mounted) {
      Navigator.of(context).pushNamed(
        '/scan-result',
        arguments: bytes,
      );
    }
  }

  Future<void> _pickFromGallery(
    BuildContext context,
    CameraViewModel cameraVM,
  ) async {
    final bytes = await cameraVM.pickFromGallery();
    if (bytes != null && context.mounted) {
      Navigator.of(context).pushNamed(
        '/scan-result',
        arguments: bytes,
      );
    }
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
