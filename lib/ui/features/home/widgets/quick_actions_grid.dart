import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/pdf_tool.dart';
import '../../scanner/views/scanner_modal.dart';
import '../../tools/views/tool_action_dialog.dart';
import '../view_models/home_view_model.dart';

class QuickActionsGrid extends StatelessWidget {
  final HomeViewModel viewModel;

  const QuickActionsGrid({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 2),
                Text(
                  'Instant',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2x2 Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildScanDocCard(context, cardWidth),
                _buildStandardQuickCard(
                  context,
                  width: cardWidth,
                  title: 'Image to PDF',
                  subtitle: 'JPG, PNG to PDF',
                  icon: Icons.image_outlined,
                  toolId: 'qa-img2pdf',
                ),
                _buildStandardQuickCard(
                  context,
                  width: cardWidth,
                  title: 'Merge PDF',
                  subtitle: 'Combine multiple',
                  icon: Icons.call_merge_rounded,
                  toolId: 'qa-merge',
                ),
                _buildStandardQuickCard(
                  context,
                  width: cardWidth,
                  title: 'Compress PDF',
                  subtitle: 'Reduce file size',
                  icon: Icons.compress_rounded,
                  toolId: 'qa-compress',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildScanDocCard(BuildContext context, double width) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ScannerModal.show(context, viewModel: viewModel),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
            boxShadow: AppColors.cardShadow,
          ),
          child: Stack(
            children: [
              // Subtle blue glow in corner
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Camera icon container
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(37, 99, 235, 0.25),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      // Fast OCR Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Fast OCR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Scan Doc',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Camera to PDF',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardQuickCard(
    BuildContext context, {
    required double width,
    required String title,
    required String subtitle,
    required IconData icon,
    required String toolId,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final tool = viewModel.quickActions.firstWhere(
            (PdfTool t) => t.id == toolId,
            orElse: () => PdfTool(
              id: toolId,
              title: title,
              subtitle: subtitle,
              icon: icon,
              category: ToolCategory.convert,
            ),
          );
          ToolActionDialog.show(context, tool: tool, viewModel: viewModel);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
