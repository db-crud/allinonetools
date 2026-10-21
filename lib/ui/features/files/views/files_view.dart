import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/brand_logo.dart';
import '../../reader/views/pdf_reader_modal.dart';
import '../../scanner/views/scanner_modal.dart';

class FilesView extends StatelessWidget {
  final HomeViewModel viewModel;

  const FilesView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final files = viewModel.allFiles;
    final filters = ['All', 'Favorites', 'Finance', 'Contracts', 'Travel', 'Scanned'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: const Row(
          children: [
            BrandLogo(size: 30),
            SizedBox(width: 10),
            Text('My Files', style: AppTypography.headlineSm),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
            onPressed: () => ScannerModal.show(context, viewModel: viewModel),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: AppColors.surfaceCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) {
                  final isSelected = viewModel.fileFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(f),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                      selectedColor: AppColors.secondaryContainer,
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => viewModel.setFileFilter(f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // File List
          Expanded(
            child: files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 56, color: AppColors.outline.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text('No documents found', style: AppTypography.headlineSm),
                        const SizedBox(height: 4),
                        const Text('Try changing filters or scanning a new PDF', style: AppTypography.bodySm),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: files.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${file.sizeFormatted} • ${file.pageCount} pages • ${file.category}',
                                    style: AppTypography.bodySm,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                file.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                color: file.isFavorite ? Colors.amber : AppColors.outline,
                              ),
                              onPressed: () => viewModel.toggleFavorite(file.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new_rounded, size: 20, color: AppColors.primary),
                              onPressed: () => PdfReaderModal.show(context, document: file, viewModel: viewModel),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
