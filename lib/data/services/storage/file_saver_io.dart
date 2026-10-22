import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileSaver {
  static Future<String?> saveAndDownload({
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'application/pdf',
  }) async {
    try {
      Directory? baseDir;
      if (Platform.isAndroid) {
        // Try to save to Downloads or external storage directory if available
        baseDir =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      final outDir = Directory('${baseDir.path}/DB_PDF_Tools');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }

      final file = File('${outDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        return file.path;
      } catch (_) {
        return null;
      }
    }
  }
}
