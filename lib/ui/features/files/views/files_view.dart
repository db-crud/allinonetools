import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/services/storage/file_saver.dart';
import '../../../../domain/models/pdf_document.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/brand_logo.dart';
import '../../reader/views/pdf_reader_modal.dart';
import '../../scanner/views/scanner_modal.dart';

class FilesView extends StatelessWidget {
  final HomeViewModel viewModel;

  const FilesView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final recentFiles = viewModel.allRecentFiles;
    final filters = ['All', 'Favorites', 'PDF', 'CSV', 'TXT', 'DOC'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: const Row(
          children: [
            BrandLogo(size: 30),
            SizedBox(width: 10),
            Text('Recent Files', style: AppTypography.headlineSm),
          ],
        ),
        actions: [
          if (recentFiles.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.error),
              label: const Text('Clear', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
              onPressed: () => _confirmClearHistory(context),
            ),
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
            tooltip: 'Scan New Document',
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
            child: recentFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 56, color: AppColors.outline.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text('No recent files found', style: AppTypography.headlineSm),
                        const SizedBox(height: 4),
                        const Text('Files you process will appear here automatically', style: AppTypography.bodySm),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.bolt, size: 18),
                          label: const Text('Use a PDF Tool'),
                          onPressed: () => viewModel.setNavIndex(2), // switch to tools
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: recentFiles.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final file = recentFiles[index];
                      final isPdf = file.fileType.toUpperCase() == 'PDF';

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
                              child: Center(
                                child: Icon(
                                  file.fileType == 'CSV'
                                      ? Icons.table_chart_rounded
                                      : (file.fileType == 'TXT' ? Icons.text_snippet_rounded : Icons.picture_as_pdf_rounded),
                                  color: isPdf ? AppColors.error : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.processedFileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${file.toolUsed} • ${file.fileSizeFormatted} • ${file.processedAtFormatted}',
                                    style: AppTypography.bodySm.copyWith(fontSize: 12),
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
                              icon: const Icon(Icons.download_rounded, size: 20, color: AppColors.primary),
                              tooltip: 'Download / Export',
                              onPressed: () async {
                                Uint8List? bytes = file.fileBytes;
                                if (bytes == null && !kIsWeb && file.filePath != null) {
                                  try {
                                    final f = io.File(file.filePath!);
                                    if (f.existsSync()) {
                                      bytes = f.readAsBytesSync();
                                    }
                                  } catch (_) {}
                                }

                                if (bytes != null) {
                                  await FileSaver.saveAndDownload(
                                    bytes: bytes,
                                    fileName: file.processedFileName,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Downloading ${file.processedFileName}...')),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('File ${file.processedFileName} saved at ${file.filePath ?? "local storage"}')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new_rounded, size: 20, color: AppColors.primary),
                              tooltip: 'Open',
                              onPressed: () {
                                final doc = PdfDocument(
                                  id: file.id,
                                  title: file.processedFileName,
                                  sizeFormatted: file.fileSizeFormatted,
                                  lastOpenedFormatted: file.processedAtFormatted,
                                  pageCount: file.pageCount,
                                  category: file.toolUsed,
                                  isFavorite: file.isFavorite,
                                  updatedAt: file.processedAt,
                                );
                                PdfReaderModal.show(context, document: doc, viewModel: viewModel);
                              },
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

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Recent Files?'),
        content: const Text('This will remove all recent processed file entries from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              viewModel.clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
