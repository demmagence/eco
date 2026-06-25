import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/loading_indicator.dart';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/data/models/chatbot_args.dart';
import 'package:eco/features/camera/scan_result_viewmodel.dart';
import 'package:eco/routes/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanResultView extends StatefulWidget {
  const ScanResultView({super.key});

  @override
  State<ScanResultView> createState() => _ScanResultViewState();
}

class _ScanResultViewState extends State<ScanResultView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final TextEditingController _chatTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final bytes = args['bytes'] as Uint8List?;
        final mode = args['mode'] as String? ?? 'multiple';
        if (bytes != null) {
          context.read<ScanResultViewModel>().analyzeImage(bytes, scanMode: mode).then((_) {
            _animController.forward();
          });
        }
      } else if (args is Uint8List) {
        // Backward compatibility
        context.read<ScanResultViewModel>().analyzeImage(args).then((_) {
          _animController.forward();
        });
      } else if (args is ScanResultModel) {
        context.read<ScanResultViewModel>().loadExistingResult(args);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _chatTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ScanResultViewModel>(
        builder: (context, scanVM, child) {
          if (scanVM.isAnalyzing) {
            return _buildAnalyzingState();
          }

          if (scanVM.errorMessage != null) {
            return _buildErrorState(scanVM);
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildResultContent(scanVM),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanResult),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const LoadingIndicator(message: AppStrings.analyzing),
    );
  }

  Widget _buildErrorState(ScanResultViewModel scanVM) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanResult),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Analisis Gagal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scanVM.errorMessage!,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent(ScanResultViewModel scanVM) {
    return CustomScrollView(
      slivers: [
        // Hero Header with image
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              AppStrings.scanResult,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
            background: _buildHeroImage(scanVM),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Result body
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode badge
                _buildModeBadge(scanVM.scanType),
                const SizedBox(height: 12),

                // Section label
                _buildSectionLabel('Hasil Analisis AI'),
                const SizedBox(height: 12),

                // ── SINGLE SCAN MODE CARDS ──────────────────────────────
                if (scanVM.scanType == 'single') ...[
                  if (scanVM.correctDisposal?.isNotEmpty == true)
                    _AnalysisCard(
                      gradientColors: const [Color(0xFF1B5E20), Color(0xFF43A047)],
                      icon: Icons.delete_outline_rounded,
                      title: 'Cara Membuang yang Benar',
                      content: scanVM.correctDisposal!,
                      delay: 0,
                    ),
                  if (scanVM.trashClassification?.isNotEmpty == true)
                    _AnalysisCard(
                      gradientColors: const [Color(0xFF4A148C), Color(0xFF9C27B0)],
                      icon: Icons.category_rounded,
                      title: 'Pengelompokan Sampah',
                      content: scanVM.trashClassification!,
                      delay: 60,
                    ),
                  if (scanVM.recyclingInfo?.isNotEmpty == true)
                    _AnalysisCard(
                      gradientColors: const [Color(0xFF0277BD), Color(0xFF29B6F6)],
                      icon: Icons.recycling_rounded,
                      title: 'Informasi Daur Ulang',
                      content: scanVM.recyclingInfo!,
                      delay: 120,
                    ),
                  if (scanVM.teacherMaterial?.isNotEmpty == true)
                    _SuggestionsCard(
                      content: scanVM.teacherMaterial!,
                      title: 'Materi Edukasi untuk Guru',
                      icon: Icons.school_rounded,
                      gradientColors: const [Color(0xFFBF360C), Color(0xFFFF7043)],
                    ),
                ]

                // ── MULTIPLE SCAN MODE CARDS ────────────────────────────
                else ...[
                  if (scanVM.environmentCondition?.isNotEmpty == true)
                    _AnalysisCard(
                      gradientColors: const [Color(0xFF1565C0), Color(0xFF5E92F3)],
                      icon: Icons.search_rounded,
                      title: AppStrings.environmentCondition,
                      content: scanVM.environmentCondition!,
                      delay: 0,
                    ),
                  if (scanVM.impactPrediction?.isNotEmpty == true)
                    _AnalysisCard(
                      gradientColors: const [Color(0xFFE65100), Color(0xFFFF9800)],
                      icon: Icons.warning_amber_rounded,
                      title: AppStrings.impactPrediction,
                      content: scanVM.impactPrediction!,
                      delay: 80,
                    ),
                  if (scanVM.suggestions?.isNotEmpty == true)
                    _SuggestionsCard(
                      content: scanVM.suggestions!,
                    ),
                  if (scanVM.contacts.isNotEmpty) ...[
                    _buildSectionLabel('Instansi Terkait'),
                    const SizedBox(height: 12),
                    _ContactsCard(contacts: scanVM.contacts),
                  ],
                ],

                const SizedBox(height: 16),

                // Chat Assistant Section
                _buildChatAssistantSection(context, scanVM),

                const SizedBox(height: 24),

                // Save button
                _buildSaveButton(scanVM),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(ScanResultViewModel scanVM) {
    Widget imageWidget;
    if (scanVM.imageBytes != null) {
      imageWidget = Image.memory(
        scanVM.imageBytes!,
        width: double.infinity,
        height: 260,
        fit: BoxFit.cover,
      );
    } else if (scanVM.imageUrl != null) {
      imageWidget = CachedNetworkImage(
        imageUrl: scanVM.imageUrl!,
        width: double.infinity,
        height: 260,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        errorWidget: (_, _, _) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.broken_image, size: 48, color: AppColors.onSurfaceVariant),
        ),
      );
    } else {
      imageWidget = Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 64, color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        // Gradient overlay for readability
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
              stops: [0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModeBadge(String scanType) {
    final isSingle = scanType == 'single';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSingle
              ? [const Color(0xFF1B5E20), const Color(0xFF43A047)]
              : [const Color(0xFF1565C0), const Color(0xFF5E92F3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSingle ? Icons.eco_rounded : Icons.search_rounded,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isSingle ? 'Scan Single — Edukasi Sampah' : 'Scan Multiple — Analisis Lingkungan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ScanResultViewModel scanVM) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: scanVM.isSaved || scanVM.isSaving
            ? null
            : () => scanVM.saveResult(),
        icon: Icon(
          scanVM.isSaved ? Icons.check_circle_rounded : Icons.save_rounded,
          size: 20,
        ),
        label: Text(
          scanVM.isSaved
              ? 'Tersimpan'
              : scanVM.isSaving
                  ? 'Menyimpan...'
                  : AppStrings.save,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: scanVM.isSaved ? AppColors.accent : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: scanVM.isSaved ? 0 : 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildChatAssistantSection(BuildContext context, ScanResultViewModel scanVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1565C0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tanya Eco Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingin berdiskusi lebih lanjut mengenai hasil analisis ini? Tanyakan langsung ke Eco Assistant!',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // TextField + Send button row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatTextController,
                        decoration: InputDecoration(
                          hintText: 'Tanyakan sesuatu tentang kondisi ini...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (val) {
                          final text = val.trim();
                          if (text.isNotEmpty) {
                            Navigator.of(context).pushNamed(
                              AppRouter.chatbot,
                              arguments: ChatbotArgs(
                                scanContext: scanVM.scanResult,
                                localImageBytes: scanVM.imageBytes,
                                initialMessage: text,
                              ),
                            );
                            _chatTextController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final text = _chatTextController.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(context).pushNamed(
                            AppRouter.chatbot,
                            arguments: ChatbotArgs(
                              scanContext: scanVM.scanResult,
                              localImageBytes: scanVM.imageBytes,
                              initialMessage: text,
                            ),
                          );
                          _chatTextController.clear();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Text button to go to chat directly
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.chatbot,
                        arguments: ChatbotArgs(
                          scanContext: scanVM.scanResult,
                          localImageBytes: scanVM.imageBytes,
                        ),
                      );
                    },
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    label: const Text('Buka Percakapan Chatbot'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Analysis Card ───────────────────────────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String content;
  final int delay;

  const _AnalysisCard({
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.content,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestions Card (with bullet points) ───────────────────────────────────

class _SuggestionsCard extends StatelessWidget {
  final String content;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;

  const _SuggestionsCard({
    required this.content,
    this.title = AppStrings.suggestions,
    this.icon = Icons.lightbulb_rounded,
    this.gradientColors = const [Color(0xFF2E7D32), Color(0xFF60AD5E)],
  });

  List<String> _parseBullets(String text) {
    // Split by newlines or numbered list patterns
    final lines = text
        .split(RegExp(r'\n|(?<=\.)\s+(?=\d+\.)|(?<=\n)(?=[-•*])'))
        .map((l) => l.replaceAll(RegExp(r'^[-•*\d+\.]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return lines.length > 1 ? lines : [text];
  }

  @override
  Widget build(BuildContext context) {
    final bullets = _parseBullets(content);
    final useBullets = bullets.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: useBullets
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bullets.asMap().entries.map((entry) {
                      return _BulletPoint(
                        index: entry.key + 1,
                        text: entry.value,
                        isLast: entry.key == bullets.length - 1,
                      );
                    }).toList(),
                  )
                : Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.65,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final int index;
  final String text;
  final bool isLast;

  const _BulletPoint({
    required this.index,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contacts Card ───────────────────────────────────────────────────────────

class _ContactsCard extends StatelessWidget {
  final List<ContactInfo> contacts;

  const _ContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  AppStrings.contactAgencies,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${contacts.length} instansi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contact list
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: contacts.asMap().entries.map((entry) {
                final isLast = entry.key == contacts.length - 1;
                return _ContactItem(
                  contact: entry.value,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final ContactInfo contact;
  final bool showDivider;

  const _ContactItem({required this.contact, this.showDivider = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              // Avatar icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Name & description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (contact.description != null &&
                        contact.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 12, color: AppColors.info),
                        const SizedBox(width: 4),
                        Text(
                          contact.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Call button
              GestureDetector(
                onTap: () {
                  final uri = Uri.parse('tel:${contact.phone}');
                  launchUrl(uri);
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.surfaceVariant,
          ),
      ],
    );
  }
}
