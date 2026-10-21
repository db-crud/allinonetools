import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/pdf_document.dart';
import '../../home/view_models/home_view_model.dart';

class PdfReaderModal extends StatefulWidget {
  final PdfDocument document;
  final HomeViewModel viewModel;

  const PdfReaderModal({
    super.key,
    required this.document,
    required this.viewModel,
  });

  static Future<void> show(
    BuildContext context, {
    required PdfDocument document,
    required HomeViewModel viewModel,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PdfReaderModal(document: document, viewModel: viewModel),
      ),
    );
  }

  @override
  State<PdfReaderModal> createState() => _PdfReaderModalState();
}

class _PdfReaderModalState extends State<PdfReaderModal> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${doc.sizeFormatted} • Page $_currentPage of ${doc.pageCount}',
              style: AppTypography.bodySm,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              doc.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: doc.isFavorite ? Colors.amber : AppColors.onSurfaceVariant,
            ),
            onPressed: () {
              widget.viewModel.toggleFavorite(doc.id);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing document link / PDF copy...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Simulated PDF Canvas Area
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.0,
              child: Center(
                child: Container(
                  width: 340,
                  height: 480,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              doc.category.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          Text('Page $_currentPage', style: AppTypography.bodySm),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        doc.title.replaceAll('_', ' ').replaceAll('.pdf', ''),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 2, width: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      // Mock text lines
                      ...List.generate(
                        6,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            height: 10,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? Colors.black12 : Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mock table or chart container
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Center(
                          child: Icon(Icons.analytics_outlined, color: AppColors.primary, size: 36),
                        ),
                      ),
                      const Spacer(),
                      // Signature line
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Verified with DB PDF Engine', style: AppTypography.labelSm.copyWith(color: AppColors.secondaryText)),
                          const Icon(Icons.verified, color: AppColors.success, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom reading toolbar
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                Text(
                  '$_currentPage / ${doc.pageCount}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _currentPage < doc.pageCount ? () => setState(() => _currentPage++) : null,
                ),
                const VerticalDivider(indent: 12, endIndent: 12),
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Sign', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signature tool opened for this document')),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.compress_rounded, size: 16, color: AppColors.primary),
                  label: const Text('Compress', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compress tool opened for this document')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
