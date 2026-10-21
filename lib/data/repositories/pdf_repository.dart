import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/pdf_document.dart';
import '../../domain/models/pdf_tool.dart';

class PdfRepository {
  final List<PdfDocument> _documents = [
    PdfDocument(
      id: 'doc-1',
      title: 'Quarterly_Financial_Report_2025.pdf',
      sizeFormatted: '3.2 MB',
      lastOpenedFormatted: 'Opened 2 hours ago',
      pageCount: 14,
      category: 'Finance',
      isFavorite: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PdfDocument(
      id: 'doc-2',
      title: 'Signed_Lease_Agreement_v2.pdf',
      sizeFormatted: '1.8 MB',
      lastOpenedFormatted: 'Opened Yesterday',
      pageCount: 6,
      category: 'Contracts',
      isFavorite: false,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PdfDocument(
      id: 'doc-3',
      title: 'Travel_Itinerary_Tickets.pdf',
      sizeFormatted: '840 KB',
      lastOpenedFormatted: 'Opened Mar 12',
      pageCount: 3,
      category: 'Travel',
      isFavorite: false,
      updatedAt: DateTime(2026, 3, 12),
    ),
    PdfDocument(
      id: 'doc-4',
      title: 'Annual_Tax_Return_2025.pdf',
      sizeFormatted: '4.5 MB',
      lastOpenedFormatted: 'Opened Mar 8',
      pageCount: 18,
      category: 'Finance',
      isFavorite: true,
      updatedAt: DateTime(2026, 3, 8),
    ),
    PdfDocument(
      id: 'doc-5',
      title: 'Health_Insurance_Policy.pdf',
      sizeFormatted: '1.2 MB',
      lastOpenedFormatted: 'Opened Feb 28',
      pageCount: 8,
      category: 'Personal',
      isFavorite: false,
      updatedAt: DateTime(2026, 2, 28),
    ),
    PdfDocument(
      id: 'doc-6',
      title: 'Product_Architecture_Brief.pdf',
      sizeFormatted: '5.1 MB',
      lastOpenedFormatted: 'Opened Jan 15',
      pageCount: 22,
      category: 'Work',
      isFavorite: false,
      updatedAt: DateTime(2026, 1, 15),
    ),
  ];

  static const List<PdfTool> quickActions = [
    PdfTool(
      id: 'qa-scan',
      title: 'Scan Doc',
      subtitle: 'Camera to PDF',
      icon: Icons.photo_camera_outlined,
      category: ToolCategory.convert,
      isQuickAction: true,
      badgeText: 'Fast OCR',
    ),
    PdfTool(
      id: 'qa-img2pdf',
      title: 'Image to PDF',
      subtitle: 'JPG, PNG to PDF',
      icon: Icons.image_outlined,
      category: ToolCategory.convert,
      isQuickAction: true,
    ),
    PdfTool(
      id: 'qa-merge',
      title: 'Merge PDF',
      subtitle: 'Combine multiple',
      icon: Icons.call_merge_rounded,
      category: ToolCategory.organize,
      isQuickAction: true,
    ),
    PdfTool(
      id: 'qa-compress',
      title: 'Compress PDF',
      subtitle: 'Reduce file size',
      icon: Icons.compress_rounded,
      category: ToolCategory.security,
      isQuickAction: true,
    ),
  ];

  static const List<PdfTool> allTools = [
    PdfTool(
      id: 'tool-reader',
      title: 'PDF Reader',
      subtitle: 'View & annotate',
      icon: Icons.menu_book_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-pdf2img',
      title: 'PDF to Image',
      subtitle: 'Export JPG or PNG',
      icon: Icons.photo_library_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-img2pdf',
      title: 'Image to PDF',
      subtitle: 'Create PDF from photos',
      icon: Icons.add_photo_alternate_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-merge',
      title: 'Merge PDF',
      subtitle: 'Combine documents',
      icon: Icons.call_merge_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'tool-split',
      title: 'Split PDF',
      subtitle: 'Extract page ranges',
      icon: Icons.call_split_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'tool-compress',
      title: 'Compress PDF',
      subtitle: 'Optimize document size',
      icon: Icons.zoom_in_map_rounded,
      category: ToolCategory.security,
    ),
    PdfTool(
      id: 'tool-rotate',
      title: 'Rotate PDF',
      subtitle: 'Fix page orientation',
      icon: Icons.rotate_right_rounded,
      category: ToolCategory.edit,
    ),
    PdfTool(
      id: 'tool-reorder',
      title: 'Reorder Pages',
      subtitle: 'Drag & re-arrange',
      icon: Icons.low_priority_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'tool-extract',
      title: 'Extract Pages',
      subtitle: 'Save selected pages',
      icon: Icons.filter_none_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'tool-sign',
      title: 'Sign PDF',
      subtitle: 'Draw or insert e-signature',
      icon: Icons.edit_outlined,
      category: ToolCategory.edit,
    ),
    PdfTool(
      id: 'tool-protect',
      title: 'Protect PDF',
      subtitle: 'Encrypt with password',
      icon: Icons.lock_outline_rounded,
      category: ToolCategory.security,
    ),
    PdfTool(
      id: 'tool-watermark',
      title: 'Add Watermark',
      subtitle: 'Stamp text or image',
      icon: Icons.branding_watermark_outlined,
      category: ToolCategory.edit,
    ),
  ];

  /// Initialize and fetch cloud documents from Supabase
  Future<void> syncWithSupabase() async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('documents')
          .select()
          .order('updated_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        _documents.clear();
        for (final item in data) {
          _documents.add(PdfDocument.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {
      // Offline fallback: keep in-memory documents
    }
  }

  List<PdfDocument> getRecentDocuments({int limit = 3}) {
    return List.unmodifiable(_documents.take(limit));
  }

  List<PdfDocument> getAllDocuments({String query = '', String filter = 'All'}) {
    return _documents.where((doc) {
      final matchesQuery = query.isEmpty ||
          doc.title.toLowerCase().contains(query.toLowerCase()) ||
          doc.category.toLowerCase().contains(query.toLowerCase());
      if (!matchesQuery) return false;

      if (filter == 'Favorites') return doc.isFavorite;
      if (filter != 'All' && doc.category.toLowerCase() != filter.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  void addDocument(PdfDocument doc) {
    _documents.insert(0, doc);
    _syncInsert(doc);
  }

  void _syncInsert(PdfDocument doc) async {
    try {
      final client = Supabase.instance.client;
      await client.from('documents').insert(doc.toJson());
    } catch (_) {}
  }

  void removeDocument(String id) {
    _documents.removeWhere((d) => d.id == id);
    _syncDelete(id);
  }

  void _syncDelete(String id) async {
    try {
      final client = Supabase.instance.client;
      await client.from('documents').delete().eq('id', id);
    } catch (_) {}
  }

  void toggleFavorite(String id) {
    final idx = _documents.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final updated = _documents[idx].copyWith(
        isFavorite: !_documents[idx].isFavorite,
      );
      _documents[idx] = updated;
      _syncUpdate(updated);
    }
  }

  void _syncUpdate(PdfDocument doc) async {
    try {
      final client = Supabase.instance.client;
      await client.from('documents').update({
        'is_favorite': doc.isFavorite,
      }).eq('id', doc.id);
    } catch (_) {}
  }
}
