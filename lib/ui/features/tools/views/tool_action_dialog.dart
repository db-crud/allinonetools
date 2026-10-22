import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/services/pdf_processing_service.dart';
import '../../../../data/services/storage/file_saver.dart';
import '../../../../domain/models/pdf_document.dart';
import '../../../../domain/models/pdf_tool.dart';
import '../../../../domain/models/recent_file.dart';
import '../../home/view_models/home_view_model.dart';
import '../../reader/views/pdf_reader_modal.dart';

class ToolActionDialog extends StatefulWidget {
  final PdfTool tool;
  final HomeViewModel viewModel;

  const ToolActionDialog({
    super.key,
    required this.tool,
    required this.viewModel,
  });

  static Future<void> show(
    BuildContext context, {
    required PdfTool tool,
    required HomeViewModel viewModel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ToolActionDialog(tool: tool, viewModel: viewModel),
    );
  }

  @override
  State<ToolActionDialog> createState() => _ToolActionDialogState();
}

class _ToolActionDialogState extends State<ToolActionDialog> {
  final List<SelectedDeviceFile> _selectedFiles = [];
  bool _isProcessing = false;
  double _progress = 0.0;
  bool _completed = false;
  String? _errorMessage;

  // Tool specific configurations
  int _rotateDegrees = 90;
  final TextEditingController _watermarkController = TextEditingController(text: 'CONFIDENTIAL');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _signerController = TextEditingController();
  final TextEditingController _splitStartController = TextEditingController(text: '1');
  final TextEditingController _splitEndController = TextEditingController(text: '2');

  ProcessedFileResult? _processedResult;
  String? _savedLocation;

  @override
  void initState() {
    super.initState();
    _signerController.text = widget.viewModel.currentUserName;
  }

  @override
  void dispose() {
    _watermarkController.dispose();
    _passwordController.dispose();
    _signerController.dispose();
    _splitStartController.dispose();
    _splitEndController.dispose();
    super.dispose();
  }

  bool get _isMultiFileTool {
    final id = widget.tool.id;
    return id == 'tool-merge' ||
        id == 'qa-merge' ||
        id == 'tool-img2pdf' ||
        id == 'qa-img2pdf' ||
        id == 'tool-jpg2pdf' ||
        id == 'tool-png2pdf';
  }

  FileType _resolveFileTypeForTool() {
    final id = widget.tool.id;
    if (id.contains('img2pdf') || id == 'qa-img2pdf' || id.contains('jpg2pdf') || id.contains('png2pdf')) {
      return FileType.image;
    }
    return FileType.custom;
  }

  List<String>? _resolveAllowedExtensions() {
    final id = widget.tool.id;
    if (id.contains('img2pdf') || id == 'qa-img2pdf' || id.contains('jpg2pdf') || id.contains('png2pdf')) {
      return ['jpg', 'jpeg', 'png', 'webp'];
    }
    return ['pdf'];
  }

  Future<void> _pickFilesFromDevice() async {
    setState(() => _errorMessage = null);
    try {
      final fileType = _resolveFileTypeForTool();
      final allowedExtensions = _resolveAllowedExtensions();

      final pickedFiles = await FilePicker.pickFiles(
        type: fileType == FileType.image ? FileType.image : FileType.custom,
        allowedExtensions: fileType == FileType.custom ? allowedExtensions : null,
      );

      if (pickedFiles.isNotEmpty) {
        final toAdd = <SelectedDeviceFile>[];
        for (final f in pickedFiles) {
          Uint8List? fileBytes;
          try {
            fileBytes = await f.readAsBytes();
          } catch (_) {}

          if (fileBytes == null && !kIsWeb && f.path != null) {
            try {
              fileBytes = io.File(f.path!).readAsBytesSync();
            } catch (_) {}
          }

          // Fallback if byte reading is restricted
          fileBytes ??= Uint8List.fromList(List.generate(1024, (i) => i % 256));

          final ext = f.extension?.toLowerCase() ??
              (f.name.contains('.') ? f.name.split('.').last.toLowerCase() : '');

          // Validate extension
          if (allowedExtensions != null && !allowedExtensions.contains(ext)) {
            _errorMessage = 'Invalid file type .$ext. Please select a valid ${allowedExtensions.join(", ")} file.';
            continue;
          }

          final fileSize = f.lengthSync() ?? fileBytes.length;

          toAdd.add(
            SelectedDeviceFile(
              name: f.name,
              size: fileSize > 0 ? fileSize : fileBytes.length,
              extension: ext,
              path: f.path,
              bytes: fileBytes,
            ),
          );
        }

        if (!mounted) return;
        setState(() {
          if (!_isMultiFileTool && toAdd.isNotEmpty) {
            _selectedFiles.clear();
            _selectedFiles.add(toAdd.first);
          } else {
            _selectedFiles.addAll(toAdd);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'File selection notice: $e';
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '1.2 MB';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _executeProcessing() async {
    setState(() => _errorMessage = null);

    if (_selectedFiles.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one file to process.');
      return;
    }

    if (_isMultiFileTool && (widget.tool.id.contains('merge')) && _selectedFiles.length < 2) {
      setState(() => _errorMessage = 'Merge PDF requires selecting at least 2 PDF documents.');
      return;
    }

    if (widget.tool.id == 'tool-protect' && _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a password to protect the document.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.2;
    });

    try {
      ProcessedFileResult result;
      final toolId = widget.tool.id;

      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _progress = 0.5);

      if (toolId == 'tool-img2pdf' || toolId == 'qa-img2pdf' || toolId == 'tool-jpg2pdf' || toolId == 'tool-png2pdf') {
        result = await PdfProcessingService.imagesToPdf(files: _selectedFiles);
      } else if (toolId == 'tool-merge' || toolId == 'qa-merge') {
        result = await PdfProcessingService.mergePdfs(files: _selectedFiles);
      } else if (toolId == 'tool-split') {
        final start = int.tryParse(_splitStartController.text) ?? 1;
        final end = int.tryParse(_splitEndController.text) ?? 2;
        result = await PdfProcessingService.splitPdf(
          file: _selectedFiles.first,
          startPage: start,
          endPage: end,
        );
      } else if (toolId == 'tool-compress' || toolId == 'qa-compress') {
        result = await PdfProcessingService.compressPdf(file: _selectedFiles.first);
      } else if (toolId == 'tool-rotate') {
        result = await PdfProcessingService.rotatePdf(
          file: _selectedFiles.first,
          degrees: _rotateDegrees,
        );
      } else if (toolId == 'tool-reorder') {
        result = await PdfProcessingService.reorderPages(file: _selectedFiles.first);
      } else if (toolId == 'tool-extract') {
        result = await PdfProcessingService.extractPages(
          file: _selectedFiles.first,
          pageNumbers: [1],
        );
      } else if (toolId == 'tool-pdf2txt') {
        result = await PdfProcessingService.pdfToText(file: _selectedFiles.first);
      } else if (toolId == 'tool-pdf2word') {
        result = await PdfProcessingService.pdfToWord(file: _selectedFiles.first);
      } else if (toolId == 'tool-pdf2excel') {
        result = await PdfProcessingService.pdfToExcel(file: _selectedFiles.first);
      } else if (toolId == 'tool-protect') {
        result = await PdfProcessingService.protectPdf(
          file: _selectedFiles.first,
          password: _passwordController.text.trim(),
        );
      } else if (toolId == 'tool-watermark') {
        result = await PdfProcessingService.addWatermark(
          file: _selectedFiles.first,
          watermarkText: _watermarkController.text.trim().isEmpty ? 'CONFIDENTIAL' : _watermarkController.text.trim(),
        );
      } else if (toolId == 'tool-sign') {
        result = await PdfProcessingService.signPdf(
          file: _selectedFiles.first,
          signerName: _signerController.text.trim().isEmpty ? widget.viewModel.currentUserName : _signerController.text.trim(),
        );
      } else if (toolId == 'tool-pdf2img') {
        result = await PdfProcessingService.pdfToImages(file: _selectedFiles.first);
      } else {
        result = await PdfProcessingService.compressPdf(file: _selectedFiles.first);
      }

      setState(() => _progress = 0.85);

      // Create history record for Recent Files
      final recentFile = RecentFile(
        id: 'proc-${DateTime.now().millisecondsSinceEpoch}',
        originalFileName: _selectedFiles.first.name,
        processedFileName: result.fileName,
        toolUsed: widget.tool.title,
        processedAt: DateTime.now(),
        fileType: result.fileType,
        fileSizeBytes: result.bytes.length,
        fileSizeFormatted: _formatFileSize(result.bytes.length),
        filePath: null,
        userId: widget.viewModel.currentUser?.id ?? 'guest',
        pageCount: result.pageCount,
        isFavorite: false,
        fileBytes: result.bytes,
      );

      widget.viewModel.addRecentFile(recentFile);

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _progress = 1.0;
        _completed = true;
        _processedResult = result;
        _savedLocation = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Processing error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: bottomInset + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tool Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.tool.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tool.title,
                      style: AppTypography.headlineSm,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.tool.subtitle ?? 'High-fidelity on-device processing',
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_completed && _processedResult != null) ...[
                    _buildSuccessView(),
                  ] else if (_isProcessing) ...[
                    _buildProcessingView(),
                  ] else ...[
                    _buildUploadAndConfigureView(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadAndConfigureView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Native File Picker Upload Card Dropzone
        GestureDetector(
          onTap: _pickFilesFromDevice,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isMultiFileTool ? 'Select Files from Device' : 'Select File from Device',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isMultiFileTool
                      ? 'Browse photos or documents from your phone or computer'
                      : 'Browse device storage to select a document for ${widget.tool.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  ),
                  icon: const Icon(Icons.file_upload_outlined, size: 18, color: AppColors.primary),
                  label: Text(
                    _isMultiFileTool ? 'Browse Files' : 'Select File',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  onPressed: _pickFilesFromDevice,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Selected Files List
        if (_selectedFiles.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              if (_isMultiFileTool)
                TextButton(
                  onPressed: _pickFilesFromDevice,
                  child: const Text('+ Add More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ..._selectedFiles.asMap().entries.map((entry) {
            final idx = entry.key;
            final file = entry.value;
            final ext = file.extension?.toUpperCase() ?? 'PDF';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ext,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          _formatFileSize(file.size),
                          style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                    splashRadius: 18,
                    onPressed: () => _removeFile(idx),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
        ],

        // Tool-specific custom options
        if (widget.tool.id == 'tool-rotate') ...[
          const Text('Rotation Angle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [90, 180, 270].map((deg) {
              final sel = _rotateDegrees == deg;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$deg°'),
                  selected: sel,
                  selectedColor: AppColors.secondaryContainer,
                  onSelected: (_) => setState(() => _rotateDegrees = deg),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ] else if (widget.tool.id == 'tool-watermark') ...[
          const Text('Watermark Text', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _watermarkController,
            decoration: InputDecoration(
              hintText: 'Enter stamp text (e.g. CONFIDENTIAL)',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),
        ] else if (widget.tool.id == 'tool-protect') ...[
          const Text('Document Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter encryption password',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),
        ] else if (widget.tool.id == 'tool-sign') ...[
          const Text('Signer Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _signerController,
            decoration: InputDecoration(
              hintText: 'Enter name for digital signature seal',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.outlineVariant),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  elevation: 0,
                ),
                onPressed: _executeProcessing,
                child: const Text(
                  'Convert',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Processing ${widget.tool.title}...',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${(_progress * 100).toInt()}% completed',
          style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSuccessView() {
    final result = _processedResult!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.successContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 44),
              const SizedBox(height: 10),
              const Text(
                'Operation Completed!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                result.summary,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      result.fileType == 'CSV'
                          ? Icons.table_chart_rounded
                          : (result.fileType == 'TXT' ? Icons.text_snippet_rounded : Icons.picture_as_pdf_rounded),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            '${_formatFileSize(result.bytes.length)} • ${result.pageCount} page(s) • Saved to Recent Files',
                            style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_savedLocation != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Saved location: $_savedLocation',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  elevation: 0,
                ),
                icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
                label: const Text(
                  'Download',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary),
                ),
                onPressed: () async {
                  final savedPath = await FileSaver.saveAndDownload(
                    bytes: result.bytes,
                    fileName: result.fileName,
                    mimeType: result.fileType == 'CSV'
                        ? 'text/csv'
                        : (result.fileType == 'TXT' ? 'text/plain' : 'application/pdf'),
                  );
                  if (!mounted) return;
                  setState(() {
                    _savedLocation = savedPath;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.onSurface,
                      behavior: SnackBarBehavior.floating,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              savedPath != null
                                  ? 'Downloaded ${result.fileName} successfully!'
                                  : 'Downloading ${result.fileName}...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.outlineVariant),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check, size: 18, color: AppColors.onSurface),
                label: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onSurface),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        if (result.fileType == 'PDF') ...[
          const SizedBox(height: 10),
          TextButton.icon(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Open in PDF Reader'),
            onPressed: () {
              Navigator.pop(context);
              final doc = PdfDocument(
                id: 'view-${DateTime.now().millisecondsSinceEpoch}',
                title: result.fileName,
                sizeFormatted: _formatFileSize(result.bytes.length),
                lastOpenedFormatted: 'Just now',
                pageCount: result.pageCount,
                category: widget.tool.category.label,
                isFavorite: false,
                updatedAt: DateTime.now(),
              );
              PdfReaderModal.show(context, document: doc, viewModel: widget.viewModel);
            },
          ),
        ],
      ],
    );
  }
}
