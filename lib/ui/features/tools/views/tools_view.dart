import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/pdf_tool.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/brand_logo.dart';
import '../views/tool_action_dialog.dart';

class ToolsView extends StatelessWidget {
  final HomeViewModel viewModel;

  const ToolsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: const Row(
          children: [
            BrandLogo(size: 30),
            SizedBox(width: 10),
            Text('PDF Toolbox', style: AppTypography.headlineSm),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategorySection(context, ToolCategory.convert, [
            _findTool('tool-reader'),
            _findTool('tool-pdf2img'),
            _findTool('tool-img2pdf'),
          ]),
          const SizedBox(height: 20),
          _buildCategorySection(context, ToolCategory.organize, [
            _findTool('tool-merge'),
            _findTool('tool-split'),
            _findTool('tool-reorder'),
            _findTool('tool-extract'),
          ]),
          const SizedBox(height: 20),
          _buildCategorySection(context, ToolCategory.edit, [
            _findTool('tool-rotate'),
            _findTool('tool-sign'),
            _findTool('tool-watermark'),
          ]),
          const SizedBox(height: 20),
          _buildCategorySection(context, ToolCategory.security, [
            _findTool('tool-compress'),
            _findTool('tool-protect'),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  PdfTool _findTool(String id) {
    return viewModel.allTools.firstWhere(
      (PdfTool t) => t.id == id,
      orElse: () => viewModel.allTools.first,
    );
  }

  Widget _buildCategorySection(BuildContext context, ToolCategory category, List<PdfTool> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemBuilder: (context, index) {
            final tool = tools[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ToolActionDialog.show(context, tool: tool, viewModel: viewModel),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tool.icon, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tool.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tool.subtitle ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySm.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
