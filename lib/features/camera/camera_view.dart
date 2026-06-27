import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/features/camera/camera_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraViewModel _cameraVM;
  String _selectedMode = 'multiple'; // 'single' or 'multiple'

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
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
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
                              if (cameraVM.errorMessage!.contains('CameraAccessDenied') ||
                                  cameraVM.errorMessage!.contains('permission was denied')) ...[
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => cameraVM.initializeCamera(),
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text(
                                    'Coba Minta Izin Lagi',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => openAppSettings(),
                                  icon: const Icon(Icons.settings, color: Colors.white54, size: 18),
                                  label: const Text(
                                    'Buka Pengaturan Aplikasi',
                                    style: TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                ),
              ),

            // Multiple scan: scanning frame overlay
            if (_selectedMode == 'multiple')
              _buildScanFrameOverlay(),

            // Top: mode selector
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildModeSelector(),
            ),

            // Top hint text
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedMode == 'single'
                        ? 'Arahkan ke sampah spesifik (jumlah sedikit)'
                        : 'Arahkan ke pemandangan kotor / lingkungan luas',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
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
                            color: _selectedMode == 'single'
                                ? AppColors.accent
                                : AppColors.primary,
                            width: 4,
                          ),
                        ),
                        child: cameraVM.isTakingPicture
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: _selectedMode == 'single'
                                      ? AppColors.accent
                                      : AppColors.primary,
                                ),
                              )
                            : Icon(
                                _selectedMode == 'single'
                                    ? Icons.eco_rounded
                                    : Icons.camera,
                                color: _selectedMode == 'single'
                                    ? AppColors.accent
                                    : AppColors.primary,
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

  Widget _buildModeSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ModeTab(
            label: '🌿 Scan Single',
            selected: _selectedMode == 'single',
            selectedColor: AppColors.accent,
            onTap: () => setState(() => _selectedMode = 'single'),
          ),
          _ModeTab(
            label: '🔍 Scan Multiple',
            selected: _selectedMode == 'multiple',
            selectedColor: AppColors.primary,
            onTap: () => setState(() => _selectedMode = 'multiple'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanFrameOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner accents
            ..._buildCorners(AppColors.primary),
            // Center label
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Area Scan Lingkungan',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners(Color color) {
    const size = 20.0;
    const thickness = 3.0;
    return [
      Positioned(top: 0, left: 0, child: _Corner(color: color, size: size, thickness: thickness, top: true, left: true)),
      Positioned(top: 0, right: 0, child: _Corner(color: color, size: size, thickness: thickness, top: true, left: false)),
      Positioned(bottom: 0, left: 0, child: _Corner(color: color, size: size, thickness: thickness, top: false, left: true)),
      Positioned(bottom: 0, right: 0, child: _Corner(color: color, size: size, thickness: thickness, top: false, left: false)),
    ];
  }

  Future<void> _captureImage(BuildContext context, CameraViewModel cameraVM) async {
    final bytes = await cameraVM.captureImage();
    if (bytes != null && context.mounted) {
      Navigator.of(context).pushNamed(
        '/scan-result',
        arguments: {'bytes': bytes, 'mode': _selectedMode},
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context, CameraViewModel cameraVM) async {
    final bytes = await cameraVM.pickFromGallery();
    if (bytes != null && context.mounted) {
      Navigator.of(context).pushNamed(
        '/scan-result',
        arguments: {'bytes': bytes, 'mode': _selectedMode},
      );
    }
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double size;
  final double thickness;
  final bool top;
  final bool left;

  const _Corner({
    required this.color,
    required this.size,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(color: color, thickness: thickness, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  _CornerPainter({required this.color, required this.thickness, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
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
