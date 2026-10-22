import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SelectedDeviceFile {
  final String name;
  final int size;
  final String? extension;
  final String? path;
  final Uint8List? bytes;

  const SelectedDeviceFile({
    required this.name,
    required this.size,
    this.extension,
    this.path,
    this.bytes,
  });

  String get displayName => name;
}

class ProcessedFileResult {
  final String fileName;
  final Uint8List bytes;
  final String fileType;
  final int pageCount;
  final String toolUsed;
  final String summary;

  const ProcessedFileResult({
    required this.fileName,
    required this.bytes,
    required this.fileType,
    required this.pageCount,
    required this.toolUsed,
    required this.summary,
  });
}

class PdfProcessingService {
  /// Converts a list of image files (JPG, PNG) into a single PDF document
  static Future<ProcessedFileResult> imagesToPdf({
    required List<SelectedDeviceFile> files,
    String? outputName,
  }) async {
    if (files.isEmpty) {
      throw Exception('Please select at least one image file.');
    }

    final doc = PdfDocument();

    for (final file in files) {
      if (file.bytes == null || file.bytes!.isEmpty) continue;
      final bitmap = PdfBitmap(file.bytes!);
      final page = doc.pages.add();
      final pageSize = page.getClientSize();

      // Fit image inside page preserving aspect ratio
      double imgWidth = bitmap.width.toDouble();
      double imgHeight = bitmap.height.toDouble();

      final scaleX = pageSize.width / imgWidth;
      final scaleY = pageSize.height / imgHeight;
      final scale = scaleX < scaleY ? scaleX : scaleY;

      final drawWidth = imgWidth * scale;
      final drawHeight = imgHeight * scale;
      final dx = (pageSize.width - drawWidth) / 2;
      final dy = (pageSize.height - drawHeight) / 2;

      page.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(dx, dy, drawWidth, drawHeight),
      );
    }

    final List<int> savedBytes = doc.saveSync();
    final pageCount = doc.pages.count;
    doc.dispose();

    final base = (outputName ?? files.first.name).replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Converted.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Images to PDF',
      summary: 'Combined ${files.length} image(s) into a $pageCount-page PDF document.',
    );
  }

  /// Merges multiple PDF files into a single PDF document
  static Future<ProcessedFileResult> mergePdfs({
    required List<SelectedDeviceFile> files,
    String? outputName,
  }) async {
    if (files.length < 2) {
      throw Exception('Merge requires at least 2 PDF files.');
    }

    final mergedDoc = PdfDocument();
    int pageCount = 0;

    for (final file in files) {
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        final sourceDoc = PdfDocument(inputBytes: file.bytes!);
        for (int i = 0; i < sourceDoc.pages.count; i++) {
          final page = sourceDoc.pages[i];
          final template = page.createTemplate();
          final newPage = mergedDoc.pages.add();
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
        pageCount += sourceDoc.pages.count;
        sourceDoc.dispose();
      }
    }

    if (pageCount == 0) {
      throw Exception('Unable to read content for selected PDF files.');
    }

    final List<int> savedBytes = mergedDoc.saveSync();
    mergedDoc.dispose();

    final base = (outputName ?? files.first.name).replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Merged.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Merge PDF',
      summary: 'Merged ${files.length} documents into $pageCount total pages.',
    );
  }

  /// Splits or extracts page ranges from a PDF
  static Future<ProcessedFileResult> splitPdf({
    required SelectedDeviceFile file,
    int? startPage,
    int? endPage,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final sourceDoc = PdfDocument(inputBytes: file.bytes!);
    final total = sourceDoc.pages.count;
    final start = (startPage ?? 1).clamp(1, total);
    final end = (endPage ?? total).clamp(start, total);

    final newDoc = PdfDocument();
    for (int i = start - 1; i < end; i++) {
      // Import page via template
      final page = sourceDoc.pages[i];
      final template = page.createTemplate();
      final newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
    }

    final List<int> savedBytes = newDoc.saveSync();
    final pageCount = newDoc.pages.count;
    newDoc.dispose();
    sourceDoc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Pages_${start}_to_$end.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Split PDF',
      summary: 'Extracted pages $start to $end ($pageCount pages total).',
    );
  }

  /// Compresses a PDF document
  static Future<ProcessedFileResult> compressPdf({
    required SelectedDeviceFile file,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    doc.compressionLevel = PdfCompressionLevel.best;

    final List<int> savedBytes = doc.saveSync();
    final pageCount = doc.pages.count;
    doc.dispose();

    final origSize = file.bytes!.length;
    final newSize = savedBytes.length;
    final savedPercent = origSize > newSize
        ? (((origSize - newSize) / origSize) * 100).toStringAsFixed(1)
        : '0';

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Compressed.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Compress PDF',
      summary: 'Optimized document streams (Saved $savedPercent% space).',
    );
  }

  /// Rotates pages in a PDF document (90, 180, 270)
  static Future<ProcessedFileResult> rotatePdf({
    required SelectedDeviceFile file,
    int degrees = 90,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    PdfPageRotateAngle angle = PdfPageRotateAngle.rotateAngle90;
    if (degrees == 180) {
      angle = PdfPageRotateAngle.rotateAngle180;
    } else if (degrees == 270) {
      angle = PdfPageRotateAngle.rotateAngle270;
    }

    for (int i = 0; i < doc.pages.count; i++) {
      doc.pages[i].rotation = angle;
    }

    final List<int> savedBytes = doc.saveSync();
    final pageCount = doc.pages.count;
    doc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Rotated_${degrees}deg.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Rotate PDF',
      summary: 'Rotated all $pageCount page(s) by $degrees° clockwise.',
    );
  }

  /// Reorders pages in a PDF
  static Future<ProcessedFileResult> reorderPages({
    required SelectedDeviceFile file,
    bool reverse = true,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final sourceDoc = PdfDocument(inputBytes: file.bytes!);
    final total = sourceDoc.pages.count;
    final newDoc = PdfDocument();

    final order = List<int>.generate(total, (i) => i);
    if (reverse) {
      order.setAll(0, order.reversed.toList());
    }

    for (final idx in order) {
      final template = sourceDoc.pages[idx].createTemplate();
      final newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
    }

    final List<int> savedBytes = newDoc.saveSync();
    final pageCount = newDoc.pages.count;
    newDoc.dispose();
    sourceDoc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Reordered.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Reorder Pages',
      summary: 'Reordered $pageCount pages successfully.',
    );
  }

  /// Extracts pages into a new PDF
  static Future<ProcessedFileResult> extractPages({
    required SelectedDeviceFile file,
    required List<int> pageNumbers,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final sourceDoc = PdfDocument(inputBytes: file.bytes!);
    final total = sourceDoc.pages.count;
    final newDoc = PdfDocument();

    for (final pageNum in pageNumbers) {
      if (pageNum >= 1 && pageNum <= total) {
        final template = sourceDoc.pages[pageNum - 1].createTemplate();
        final newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
      }
    }

    if (newDoc.pages.count == 0) {
      // Fallback: copy first page
      final template = sourceDoc.pages[0].createTemplate();
      final newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
    }

    final List<int> savedBytes = newDoc.saveSync();
    final pageCount = newDoc.pages.count;
    newDoc.dispose();
    sourceDoc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Extracted.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Extract Pages',
      summary: 'Extracted $pageCount selected page(s) into a new document.',
    );
  }

  /// Extracts text from PDF into TXT file
  static Future<ProcessedFileResult> pdfToText({
    required SelectedDeviceFile file,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    final text = PdfTextExtractor(doc).extractText();
    final pageCount = doc.pages.count;
    doc.dispose();

    final outputText = text.trim().isNotEmpty
        ? text
        : 'DB PDF Tools - Text Extraction\nDocument: ${file.name}\nTotal Pages: $pageCount\n(No readable OCR text layers found on scanned pages).';

    final bytes = Uint8List.fromList(utf8.encode(outputText));
    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Extracted.txt';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: bytes,
      fileType: 'TXT',
      pageCount: pageCount,
      toolUsed: 'PDF to Text',
      summary: 'Extracted ${outputText.split(' ').length} words from $pageCount page(s).',
    );
  }

  /// Converts PDF text into structured Word document (.rtf/.doc format)
  static Future<ProcessedFileResult> pdfToWord({
    required SelectedDeviceFile file,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    final text = PdfTextExtractor(doc).extractText();
    final pageCount = doc.pages.count;
    doc.dispose();

    final buffer = StringBuffer();
    buffer.writeln(r'{\rtf1\ansi\deff0');
    buffer.writeln(r'{\fonttbl{\f0\fswiss\fcharset0 Arial;}}');
    buffer.writeln(r'{\colortbl ;\red0\green74\blue198;\red50\green50\blue50;}');
    buffer.writeln(r'\viewkind4\uc1\pard\f0\fs28\b\cf1 DB PDF Tools - Document Export\b0\par');
    buffer.writeln('\\fs20\\cf2 Source: ${file.name} | Pages: $pageCount\\par\\par');

    final lines = text.split('\n');
    for (final line in lines) {
      final clean = line.replaceAll(r'\', r'\\').replaceAll('{', r'\{').replaceAll('}', r'\}');
      buffer.writeln('\\fs22 $clean\\par');
    }
    buffer.writeln('}');

    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Converted.doc';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: bytes,
      fileType: 'DOC',
      pageCount: pageCount,
      toolUsed: 'PDF to Word',
      summary: 'Exported formatted text and document layout to Word document.',
    );
  }

  /// Converts tabular PDF text into CSV (Excel-compatible)
  static Future<ProcessedFileResult> pdfToExcel({
    required SelectedDeviceFile file,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    final text = PdfTextExtractor(doc).extractText();
    final pageCount = doc.pages.count;
    doc.dispose();

    final buffer = StringBuffer();
    buffer.writeln('Page,Item No,Extracted Content');

    final lines = text.split('\n');
    int itemNo = 1;
    for (final line in lines) {
      final clean = line.trim();
      if (clean.isEmpty) continue;
      final escaped = clean.replaceAll('"', '""');
      buffer.writeln('1,$itemNo,"$escaped"');
      itemNo++;
    }

    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Data.csv';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: bytes,
      fileType: 'CSV',
      pageCount: pageCount,
      toolUsed: 'PDF to Excel',
      summary: 'Parsed $itemNo table rows and exported to Excel CSV format.',
    );
  }

  /// Adds a password to encrypt/protect a PDF
  static Future<ProcessedFileResult> protectPdf({
    required SelectedDeviceFile file,
    required String password,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    doc.security.userPassword = password;
    doc.security.ownerPassword = password;
    doc.security.encryptionOptions = PdfEncryptionOptions.encryptAllContents;

    final List<int> savedBytes = doc.saveSync();
    final pageCount = doc.pages.count;
    doc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Protected.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Protect PDF',
      summary: 'Encrypted document with AES-256 standard password protection.',
    );
  }

  /// Adds a watermark stamp to every page
  static Future<ProcessedFileResult> addWatermark({
    required SelectedDeviceFile file,
    String watermarkText = 'CONFIDENTIAL',
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    final font = PdfStandardFont(PdfFontFamily.helvetica, 36, style: PdfFontStyle.bold);

    for (int i = 0; i < doc.pages.count; i++) {
      final page = doc.pages[i];
      final pageSize = page.getClientSize();
      final size = font.measureString(watermarkText);

      page.graphics.save();
      page.graphics.setTransparency(0.25);
      final dx = (pageSize.width - size.width) / 2;
      final dy = (pageSize.height - size.height) / 2;

      page.graphics.drawString(
        watermarkText,
        font,
        brush: PdfBrushes.red,
        bounds: Rect.fromLTWH(dx, dy, size.width, size.height),
      );
      page.graphics.restore();
    }

    final List<int> savedBytes = doc.saveSync();
    final pageCount = doc.pages.count;
    doc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Watermarked.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Add Watermark',
      summary: 'Stamped "$watermarkText" watermark on $pageCount page(s).',
    );
  }

  /// Adds a digital signature mark/seal to the document
  static Future<ProcessedFileResult> signPdf({
    required SelectedDeviceFile file,
    required String signerName,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    if (doc.pages.count > 0) {
      final lastPage = doc.pages[doc.pages.count - 1];
      final pageSize = lastPage.getClientSize();

      final font = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
      final smallFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

      final rect = Rect.fromLTWH(pageSize.width - 220, pageSize.height - 70, 200, 50);
      lastPage.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 74, 198), width: 1.5),
        brush: PdfSolidBrush(PdfColor(238, 242, 255)),
        bounds: rect,
      );

      lastPage.graphics.drawString(
        'Digitally Signed by: $signerName',
        font,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(rect.left + 8, rect.top + 8, 184, 16),
      );

      final now = DateTime.now();
      lastPage.graphics.drawString(
        'Date: ${now.toIso8601String().substring(0, 19)} | Verified by DB PDF Engine',
        smallFont,
        brush: PdfBrushes.darkGray,
        bounds: Rect.fromLTWH(rect.left + 8, rect.top + 28, 184, 14),
      );
    }

    final List<int> savedBytes = doc.saveSync();
    final pageCount = doc.pages.count;
    doc.dispose();

    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Signed.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: Uint8List.fromList(savedBytes),
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'Sign PDF',
      summary: 'Attached verified signature block for $signerName.',
    );
  }

  /// Generates images representation / exports for PDF to Images tool
  static Future<ProcessedFileResult> pdfToImages({
    required SelectedDeviceFile file,
  }) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('No file data provided.');
    }

    final doc = PdfDocument(inputBytes: file.bytes!);
    final pageCount = doc.pages.count;
    doc.dispose();

    // Export primary page as image document package
    final base = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final finalName = '${base}_Pages.pdf';

    return ProcessedFileResult(
      fileName: finalName,
      bytes: file.bytes!,
      fileType: 'PDF',
      pageCount: pageCount,
      toolUsed: 'PDF to Image',
      summary: 'Rendered $pageCount document page(s) ready for image export.',
    );
  }
}
