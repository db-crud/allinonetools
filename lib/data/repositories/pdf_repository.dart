import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/pdf_document.dart';
import '../../domain/models/pdf_tool.dart';
import '../../domain/models/recent_file.dart';

class PdfRepository {
  final List<RecentFile> _recentFiles = [];
  String? _currentUserId;

  PdfRepository() {
    _loadInitialDefaultHistory();
    _loadGuestHistory();
  }

  Future<void> _loadGuestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'db_pdf_tools_user_history_guest';
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
        if (list.isNotEmpty) {
          _recentFiles.clear();
          for (final item in list) {
            _recentFiles.add(RecentFile.fromJson(item as Map<String, dynamic>));
          }
          _sortHistory();
        }
      }
    } catch (_) {}
  }

  void _loadInitialDefaultHistory() {
    _recentFiles.clear();
    _recentFiles.addAll([
      RecentFile(
        id: 'file-init-1',
        originalFileName: 'Quarterly_Financial_Report.pdf',
        processedFileName: 'Quarterly_Financial_Report_Compressed.pdf',
        toolUsed: 'Compress PDF',
        processedAt: DateTime.now().subtract(const Duration(hours: 2)),
        fileType: 'PDF',
        fileSizeBytes: 1024 * 1024 * 2 + 100000,
        fileSizeFormatted: '2.1 MB',
        userId: 'guest',
        pageCount: 14,
        isFavorite: true,
      ),
      RecentFile(
        id: 'file-init-2',
        originalFileName: 'Signed_Lease_Agreement.pdf',
        processedFileName: 'Signed_Lease_Agreement_Protected.pdf',
        toolUsed: 'Protect PDF',
        processedAt: DateTime.now().subtract(const Duration(days: 1)),
        fileType: 'PDF',
        fileSizeBytes: 1024 * 900,
        fileSizeFormatted: '900 KB',
        userId: 'guest',
        pageCount: 6,
        isFavorite: false,
      ),
      RecentFile(
        id: 'file-init-3',
        originalFileName: 'Travel_Receipts_Photo.jpg',
        processedFileName: 'Travel_Receipts_Converted.pdf',
        toolUsed: 'Images to PDF',
        processedAt: DateTime.now().subtract(const Duration(days: 3)),
        fileType: 'PDF',
        fileSizeBytes: 1024 * 650,
        fileSizeFormatted: '650 KB',
        userId: 'guest',
        pageCount: 3,
        isFavorite: false,
      ),
    ]);
  }

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
      subtitle: 'View & inspect',
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
      subtitle: 'Photos to clean PDF',
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
      id: 'tool-pdf2word',
      title: 'PDF to Word',
      subtitle: 'Export to Word (.doc)',
      icon: Icons.description_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-pdf2excel',
      title: 'PDF to Excel',
      subtitle: 'Extract tables to CSV',
      icon: Icons.table_chart_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-pdf2txt',
      title: 'PDF to Text',
      subtitle: 'Extract plain text',
      icon: Icons.text_snippet_outlined,
      category: ToolCategory.convert,
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
      id: 'tool-jpg2pdf',
      title: 'JPG to PDF',
      subtitle: 'Convert JPG photos',
      icon: Icons.photo_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-png2pdf',
      title: 'PNG to PDF',
      subtitle: 'Convert PNG graphics',
      icon: Icons.image_search_outlined,
      category: ToolCategory.convert,
    ),
    PdfTool(
      id: 'tool-sign',
      title: 'Sign PDF',
      subtitle: 'Add verified signature',
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
      subtitle: 'Stamp text watermark',
      icon: Icons.branding_watermark_outlined,
      category: ToolCategory.edit,
    ),
  ];

  /// Switches active user and loads their persisted recent files history
  Future<void> switchUser(String? userId) async {
    _currentUserId = userId;
    final effectiveKey = 'db_pdf_tools_user_history_${userId ?? 'guest'}';

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(effectiveKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
        if (list.isNotEmpty) {
          _recentFiles.clear();
          for (final item in list) {
            _recentFiles.add(RecentFile.fromJson(item as Map<String, dynamic>));
          }
          _sortHistory();
          if (userId != null) {
            _fetchFromSupabase(userId);
          }
          return;
        }
      }
    } catch (_) {}

    if (userId == null) {
      _loadInitialDefaultHistory();
    } else {
      _recentFiles.clear();
      _fetchFromSupabase(userId);
    }
  }

  Future<void> _fetchFromSupabase(String userId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('documents')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      if (response.isNotEmpty) {
        bool changed = false;
        for (final row in response) {
          final docId = row['id']?.toString() ?? '';
          if (docId.isNotEmpty && !_recentFiles.any((f) => f.id == docId)) {
            _recentFiles.add(RecentFile(
              id: docId,
              originalFileName: row['title'] as String? ?? 'Document.pdf',
              processedFileName: row['title'] as String? ?? 'Document.pdf',
              toolUsed: row['category'] as String? ?? 'PDF Tool',
              processedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ?? DateTime.now(),
              fileType: 'PDF',
              fileSizeBytes: 1024 * 1024,
              fileSizeFormatted: row['size_formatted'] as String? ?? '1.0 MB',
              userId: userId,
              pageCount: (row['page_count'] as num?)?.toInt() ?? 1,
              isFavorite: row['is_favorite'] as bool? ?? false,
            ));
            changed = true;
          }
        }
        if (changed) {
          _sortHistory();
          await _persistHistory();
        }
      }
    } catch (_) {}
  }

  void _sortHistory() {
    _recentFiles.sort((a, b) => b.processedAt.compareTo(a.processedAt));
  }

  Future<void> _persistHistory() async {
    final userId = _currentUserId ?? 'guest';
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'db_pdf_tools_user_history_$userId';
      final jsonList = _recentFiles.map((f) => f.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<RecentFile> getRecentFiles({int limit = 5}) {
    _sortHistory();
    return List.unmodifiable(_recentFiles.take(limit));
  }

  List<RecentFile> getAllFiles({String query = '', String filter = 'All'}) {
    _sortHistory();
    return _recentFiles.where((doc) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          doc.processedFileName.toLowerCase().contains(q) ||
          doc.originalFileName.toLowerCase().contains(q) ||
          doc.toolUsed.toLowerCase().contains(q);
      if (!matchesQuery) return false;

      if (filter == 'Favorites') return doc.isFavorite;
      if (filter != 'All' && doc.fileType.toLowerCase() != filter.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  void addRecentFile(RecentFile file) {
    _recentFiles.insert(0, file);
    _sortHistory();
    _persistHistory();

    // Sync to Supabase documents if user is authenticated
    if (_currentUserId != null && _currentUserId != 'guest') {
      try {
        final client = Supabase.instance.client;
        client.from('documents').upsert({
          'id': file.id,
          'title': file.processedFileName,
          'size_formatted': file.fileSizeFormatted,
          'last_opened_formatted': 'Just now',
          'page_count': file.pageCount,
          'category': file.toolUsed,
          'is_favorite': file.isFavorite,
          'user_id': _currentUserId,
          'updated_at': file.processedAt.toIso8601String(),
        }).catchError((_) {});
      } catch (_) {}
    }
  }

  void deleteRecentFile(String id) {
    _recentFiles.removeWhere((f) => f.id == id);
    _persistHistory();

    if (_currentUserId != null && _currentUserId != 'guest') {
      try {
        final client = Supabase.instance.client;
        client.from('documents').delete().eq('id', id).eq('user_id', _currentUserId!).catchError((_) {});
      } catch (_) {}
    }
  }

  void clearHistory() {
    _recentFiles.clear();
    _persistHistory();
  }

  void toggleFavorite(String id) {
    final idx = _recentFiles.indexWhere((f) => f.id == id);
    if (idx != -1) {
      _recentFiles[idx] = _recentFiles[idx].copyWith(
        isFavorite: !_recentFiles[idx].isFavorite,
      );
      _persistHistory();
    }
  }

  // Backwards compatibility with PdfDocument
  List<PdfDocument> getRecentDocuments({int limit = 5}) {
    return getRecentFiles(limit: limit).map((rf) => PdfDocument(
      id: rf.id,
      title: rf.processedFileName,
      sizeFormatted: rf.fileSizeFormatted,
      lastOpenedFormatted: rf.processedAtFormatted,
      pageCount: rf.pageCount,
      category: rf.toolUsed,
      isFavorite: rf.isFavorite,
      updatedAt: rf.processedAt,
    )).toList();
  }

  List<PdfDocument> getAllDocuments({String query = '', String filter = 'All'}) {
    return getAllFiles(query: query, filter: filter).map((rf) => PdfDocument(
      id: rf.id,
      title: rf.processedFileName,
      sizeFormatted: rf.fileSizeFormatted,
      lastOpenedFormatted: rf.processedAtFormatted,
      pageCount: rf.pageCount,
      category: rf.toolUsed,
      isFavorite: rf.isFavorite,
      updatedAt: rf.processedAt,
    )).toList();
  }

  void addDocument(PdfDocument doc) {
    addRecentFile(RecentFile(
      id: doc.id,
      originalFileName: doc.title,
      processedFileName: doc.title,
      toolUsed: doc.category,
      processedAt: doc.updatedAt,
      fileType: 'PDF',
      fileSizeBytes: 1024 * 1024,
      fileSizeFormatted: doc.sizeFormatted,
      userId: _currentUserId ?? 'guest',
      pageCount: doc.pageCount,
      isFavorite: doc.isFavorite,
    ));
  }

  void removeDocument(String id) {
    deleteRecentFile(id);
  }
}
