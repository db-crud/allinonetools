import 'dart:typed_data';

class RecentFile {
  final String id;
  final String originalFileName;
  final String processedFileName;
  final String toolUsed;
  final DateTime processedAt;
  final String fileType;
  final int fileSizeBytes;
  final String fileSizeFormatted;
  final String? filePath;
  final String userId;
  final int pageCount;
  final bool isFavorite;
  final Uint8List? fileBytes;

  const RecentFile({
    required this.id,
    required this.originalFileName,
    required this.processedFileName,
    required this.toolUsed,
    required this.processedAt,
    required this.fileType,
    required this.fileSizeBytes,
    required this.fileSizeFormatted,
    this.filePath,
    required this.userId,
    this.pageCount = 1,
    this.isFavorite = false,
    this.fileBytes,
  });

  String get processedAtFormatted {
    final now = DateTime.now();
    final diff = now.difference(processedAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${processedAt.day}/${processedAt.month}/${processedAt.year}';
    }
  }

  RecentFile copyWith({
    String? id,
    String? originalFileName,
    String? processedFileName,
    String? toolUsed,
    DateTime? processedAt,
    String? fileType,
    int? fileSizeBytes,
    String? fileSizeFormatted,
    String? filePath,
    String? userId,
    int? pageCount,
    bool? isFavorite,
    Uint8List? fileBytes,
  }) {
    return RecentFile(
      id: id ?? this.id,
      originalFileName: originalFileName ?? this.originalFileName,
      processedFileName: processedFileName ?? this.processedFileName,
      toolUsed: toolUsed ?? this.toolUsed,
      processedAt: processedAt ?? this.processedAt,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileSizeFormatted: fileSizeFormatted ?? this.fileSizeFormatted,
      filePath: filePath ?? this.filePath,
      userId: userId ?? this.userId,
      pageCount: pageCount ?? this.pageCount,
      isFavorite: isFavorite ?? this.isFavorite,
      fileBytes: fileBytes ?? this.fileBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_file_name': originalFileName,
      'processed_file_name': processedFileName,
      'tool_used': toolUsed,
      'processed_at': processedAt.toIso8601String(),
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'file_size_formatted': fileSizeFormatted,
      'file_path': filePath,
      'user_id': userId,
      'page_count': pageCount,
      'is_favorite': isFavorite,
    };
  }

  factory RecentFile.fromJson(Map<String, dynamic> json, {Uint8List? bytes}) {
    return RecentFile(
      id: json['id'] as String? ?? 'file-${DateTime.now().millisecondsSinceEpoch}',
      originalFileName: json['original_file_name'] as String? ?? 'document.pdf',
      processedFileName: json['processed_file_name'] as String? ?? 'processed.pdf',
      toolUsed: json['tool_used'] as String? ?? 'PDF Tool',
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      fileType: json['file_type'] as String? ?? 'PDF',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 1024 * 1024,
      fileSizeFormatted: json['file_size_formatted'] as String? ?? '1.0 MB',
      filePath: json['file_path'] as String?,
      userId: json['user_id'] as String? ?? 'guest',
      pageCount: json['page_count'] as int? ?? 1,
      isFavorite: json['is_favorite'] as bool? ?? false,
      fileBytes: bytes,
    );
  }
}
