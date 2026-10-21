import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home/view_models/home_view_model.dart';

class ScannerModal extends StatefulWidget {
  final HomeViewModel viewModel;

  const ScannerModal({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, {required HomeViewModel viewModel}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.black,
      builder: (ctx) => ScannerModal(viewModel: viewModel),
    );
  }

  @override
  State<ScannerModal> createState() => _ScannerModalState();
}

class _ScannerModalState extends State<ScannerModal> {
  bool _flashOn = false;
  bool _ocrEnabled = true;
  int _capturedPages = 0;
  final TextEditingController _nameController = TextEditingController(
    text: 'Scanned_Doc_${DateTime.now().hour}${DateTime.now().minute}',
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _capturePage() {
    setState(() {
      _capturedPages++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Page $_capturedPages captured & enhanced with OCR'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _finishAndSave() {
    final title = _nameController.text.trim().isEmpty
        ? 'Scanned_Document'
        : _nameController.text.trim();
    widget.viewModel.addScannedDocument(
      title: title,
      pages: _capturedPages == 0 ? 1 : _capturedPages,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.onSurface,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text('$title.pdf saved to Documents'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Document Scanner',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Flash toggle
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: _flashOn ? Colors.amber : Colors.white70,
            ),
            onPressed: () => setState(() => _flashOn = !_flashOn),
          ),
          // Fast OCR Chip
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: FilterChip(
              selected: _ocrEnabled,
              label: const Text('Fast OCR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              labelStyle: TextStyle(color: _ocrEnabled ? AppColors.primary : Colors.white70),
              backgroundColor: Colors.white12,
              selectedColor: AppColors.secondaryContainer,
              checkmarkColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (val) => setState(() => _ocrEnabled = val),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Viewfinder simulation
          Expanded(
            child: Stack(
              children: [
                // Simulated camera preview background
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_rounded,
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Align document within frame',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Auto-capture with perspective correction',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Corner targeting guides
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: CustomPaint(
                      painter: _ViewfinderOverlayPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom capture controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Photo library
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
                  onPressed: () => _capturePage(),
                ),

                // Shutter button
                GestureDetector(
                  onTap: _capturePage,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                    ),
                  ),
                ),

                // Save button
                GestureDetector(
                  onTap: _finishAndSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _capturedPages > 0 ? AppColors.primary : Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _capturedPages > 0 ? 'Save ($_capturedPages)' : 'Done',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.check, color: Colors.white, size: 16),
                      ],
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

class _ViewfinderOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 28.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
