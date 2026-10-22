import 'dart:typed_data';

abstract class FileSaver {
  static Future<String?> saveAndDownload({
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'application/pdf',
  }) {
    throw UnsupportedError('Cannot save file without platform implementation');
  }
}
