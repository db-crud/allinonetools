import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/services/storage/file_saver.dart';
import '../../../../domain/models/pdf_document.dart';
import '../../../../domain/models/recent_file.dart';
import '../../reader/views/pdf_reader_modal.dart';
import '../../scanner/views/scanner_modal.dart';
import '../view_models/home_view_model.dart';

class RecentDocumentsSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const RecentDocumentsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final recentFiles = viewModel.recentFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Recent Files',
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
                if (recentFiles.isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _confirmClearHistory(context),
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ),
                InkWell(
                  onTap: () => viewModel.setNavIndex(1), // Switch to Files / Recent page
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of Documents
        if (recentFiles.isEmpty)
          _buildEmptyPrompt(context)
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentFiles.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final file = recentFiles[index];
              return _buildFileTile(context, file);
            },
          ),
          const SizedBox(height: 12),
          _buildEmptyPrompt(context),
        ],
      ],
    );
  }

  Widget _buildFileTile(BuildContext context, RecentFile file) {
    final isPdf = file.fileType.toUpperCase() == 'PDF';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Thumbnail badge
              Container(
                width: 44,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      file.fileType == 'CSV'
                          ? Icons.table_chart_rounded
                          : (file.fileType == 'TXT' ? Icons.text_snippet_rounded : Icons.picture_as_pdf_rounded),
                      color: isPdf ? AppColors.error : AppColors.primary,
                      size: 24,
                    ),
                    Positioned(
                      bottom: 4,
                      child: Text(
                        file.fileType,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Title and metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.processedFileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file.toolUsed,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          file.fileSizeFormatted,
                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 6),
                        Text('•', style: TextStyle(color: AppColors.outline.withValues(alpha: 0.6))),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            file.processedAtFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) async {
                  if (value == 'open') {
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
                  } else if (value == 'download') {
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
                  } else if (value == 'favorite') {
                    viewModel.toggleFavorite(file.id);
                  } else if (value == 'delete') {
                    viewModel.deleteRecentFile(file.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed ${file.processedFileName}')),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Open'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Download / Export'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'favorite',
                    child: Row(
                      children: [
                        Icon(
                          file.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 18,
                          color: file.isFavorite ? Colors.amber : null,
                        ),
                        const SizedBox(width: 8),
                        Text(file.isFavorite ? 'Unfavorite' : 'Favorite'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
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

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Recent Files?'),
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

  Widget _buildEmptyPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'No processed files yet? Try Image to PDF or Merge',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => ScannerModal.show(context, viewModel: viewModel),
            child: const Text(
              'Scan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
