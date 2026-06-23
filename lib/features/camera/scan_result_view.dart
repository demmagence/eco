import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/loading_indicator.dart';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/features/camera/scan_result_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanResultView extends StatefulWidget {
  const ScanResultView({super.key});

  @override
  State<ScanResultView> createState() => _ScanResultViewState();
}

class _ScanResultViewState extends State<ScanResultView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Uint8List) {
        context.read<ScanResultViewModel>().analyzeImage(args);
      } else if (args is ScanResultModel) {
        context.read<ScanResultViewModel>().loadExistingResult(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanResult),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ScanResultViewModel>(
        builder: (context, scanVM, child) {
          if (scanVM.isAnalyzing) {
            return const LoadingIndicator(
              message: AppStrings.analyzing,
            );
          }

          if (scanVM.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      scanVM.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview
                if (scanVM.imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      scanVM.imageBytes!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (scanVM.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: scanVM.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: 200,
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 200,
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Environment Condition
                if (scanVM.environmentCondition?.isNotEmpty == true)
                  _ResultSection(
                    icon: Icons.search,
                    iconColor: AppColors.secondary,
                    title: AppStrings.environmentCondition,
                    content: scanVM.environmentCondition!,
                  ),

                // Impact Prediction
                if (scanVM.impactPrediction?.isNotEmpty == true)
                  _ResultSection(
                    icon: Icons.warning_amber,
                    iconColor: AppColors.warning,
                    title: AppStrings.impactPrediction,
                    content: scanVM.impactPrediction!,
                  ),

                // Suggestions
                if (scanVM.suggestions?.isNotEmpty == true)
                  _ResultSection(
                    icon: Icons.lightbulb_outline,
                    iconColor: AppColors.accent,
                    title: AppStrings.suggestions,
                    content: scanVM.suggestions!,
                  ),

                // Contact Agencies
                if (scanVM.contacts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                  Icons.phone,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.contactAgencies,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...scanVM.contacts.map(
                            (contact) => _ContactItem(contact: contact),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: scanVM.isSaved || scanVM.isSaving
                        ? null
                        : () => scanVM.saveResult(),
                    icon: Icon(
                      scanVM.isSaved
                          ? Icons.check
                          : Icons.save,
                    ),
                    label: Text(
                      scanVM.isSaved
                          ? 'Tersimpan'
                          : scanVM.isSaving
                              ? 'Menyimpan...'
                              : AppStrings.save,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scanVM.isSaved
                          ? AppColors.accent
                          : AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _ResultSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final ContactInfo contact;

  const _ContactItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.business,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (contact.description != null)
                  Text(
                    contact.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          // Phone call button
          IconButton(
            icon: const Icon(
              Icons.phone,
              color: AppColors.primary,
            ),
            onPressed: () {
              final uri = Uri.parse('tel:${contact.phone}');
              launchUrl(uri);
            },
          ),
        ],
      ),
    );
  }
}
