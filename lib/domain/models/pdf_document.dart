class PdfDocument {
  final String id;
  final String title;
  final String sizeFormatted;
  final String lastOpenedFormatted;
  final int pageCount;
  final String category;
  final bool isFavorite;
  final DateTime updatedAt;

  const PdfDocument({
    required this.id,
    required this.title,
    required this.sizeFormatted,
    required this.lastOpenedFormatted,
    this.pageCount = 1,
    this.category = 'General',
    this.isFavorite = false,
    required this.updatedAt,
  });

  PdfDocument copyWith({
    String? id,
    String? title,
    String? sizeFormatted,
    String? lastOpenedFormatted,
    int? pageCount,
    String? category,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      sizeFormatted: sizeFormatted ?? this.sizeFormatted,
      lastOpenedFormatted: lastOpenedFormatted ?? this.lastOpenedFormatted,
      pageCount: pageCount ?? this.pageCount,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      sizeFormatted: json['size_formatted'] as String? ?? '1.0 MB',
      lastOpenedFormatted: json['last_opened_formatted'] as String? ?? 'Recently',
      pageCount: json['page_count'] as int? ?? 1,
      category: json['category'] as String? ?? 'General',
      isFavorite: json['is_favorite'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'size_formatted': sizeFormatted,
      'last_opened_formatted': lastOpenedFormatted,
      'page_count': pageCount,
      'category': category,
      'is_favorite': isFavorite,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
