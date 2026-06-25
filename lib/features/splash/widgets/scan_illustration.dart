import 'package:flutter/material.dart';

class ScanIllustration extends StatefulWidget {
  const ScanIllustration({super.key});

  @override
  State<ScanIllustration> createState() => _ScanIllustrationState();
}

class _ScanIllustrationState extends State<ScanIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  static const double _frameSize = 252;
  static const double _framePadding = 18;
  static const List<Offset> _markerPositions = [
    Offset(0.28, 0.38), // kualitas udara
    Offset(0.68, 0.50), // suhu
    Offset(0.45, 0.74), // kelembapan
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _frameSize,
          height: _frameSize,
          padding: const EdgeInsets.all(_framePadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF11543F), Color(0xFF0B3B2C)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                const Positioned.fill(child: _Landscape()),
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, _) {
                    return Stack(
                      children: _markerPositions
                          .map((pos) => _detectionDot(pos, _scanController.value))
                          .toList(),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, _) {
                    final innerHeight = _frameSize - _framePadding * 2;
                    final top = _scanController.value * (innerHeight - 3);
                    return Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFCFFF6B),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFCFFF6B).withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        ..._cornerBrackets(),
      ],
    );
  }

  Widget _detectionDot(Offset relativePos, double scanValue) {
    final dx = relativePos.dx * (_frameSize - _framePadding * 2);
    final dy = relativePos.dy * (_frameSize - _framePadding * 2);
    final distance = (scanValue - relativePos.dy).abs();
    final glow = (1 - (distance * 4)).clamp(0.0, 1.0);

    return Positioned(
      left: dx - 5,
      top: dy - 5,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            Colors.white.withValues(alpha: 0.35),
            const Color(0xFFCFFF6B),
            glow,
          ),
          boxShadow: glow > 0.3
              ? [
                  BoxShadow(
                    color: const Color(0xFFCFFF6B).withValues(alpha: glow * 0.7),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  List<Widget> _cornerBrackets() {
    const len = 22.0;
    const thick = 3.0;
    const color = Colors.white;
    Widget h() => Container(width: len, height: thick, color: color);
    Widget v() => Container(width: thick, height: len, color: color);

    return [
      Positioned(top: -2, left: -2, child: h()),
      Positioned(top: -2, left: -2, child: v()),
      Positioned(top: -2, right: -2, child: h()),
      Positioned(top: -2, right: -2, child: v()),
      Positioned(bottom: -2, left: -2, child: h()),
      Positioned(bottom: -2, left: -2, child: v()),
      Positioned(bottom: -2, right: -2, child: h()),
      Positioned(bottom: -2, right: -2, child: v()),
    ];
  }
}

class _Landscape extends StatelessWidget {
  const _Landscape();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 14,
          right: 18,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCFFF6B).withValues(alpha: 0.85),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -20,
          child: Container(
            width: 180,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1B6B4E).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          right: -30,
          child: Container(
            width: 200,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF14573F),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.eco, size: 46, color: Colors.white),
        ),
      ],
    );
  }
}