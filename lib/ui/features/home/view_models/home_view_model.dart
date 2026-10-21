import 'package:flutter/material.dart';
import 'package:db_pdf_tools/data/repositories/pdf_repository.dart';
import 'package:db_pdf_tools/domain/models/pdf_document.dart';
import 'package:db_pdf_tools/domain/models/pdf_tool.dart';

class HomeViewModel extends ChangeNotifier {
  final PdfRepository _repository;

  HomeViewModel({required this._repository});

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ToolCategory _selectedCategory = ToolCategory.all;
  ToolCategory get selectedCategory => _selectedCategory;

  String _fileFilter = 'All';
  String get fileFilter => _fileFilter;

  int _unreadNotifications = 1;
  int get unreadNotifications => _unreadNotifications;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<PdfDocument> get recentDocuments => _repository.getRecentDocuments(limit: 3);

  List<PdfDocument> get allFiles =>
      _repository.getAllDocuments(query: _searchQuery, filter: _fileFilter);

  List<PdfTool> get quickActions => PdfRepository.quickActions;

  List<PdfTool> get allTools {
    if (_selectedCategory == ToolCategory.all) {
      return PdfRepository.allTools;
    }
    return PdfRepository.allTools
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  void setNavIndex(int index) {
    if (_selectedNavIndex == index) return;
    _selectedNavIndex = index;
    notifyListeners();
  }

  void toggleSearching() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(ToolCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setFileFilter(String filter) {
    _fileFilter = filter;
    notifyListeners();
  }

  void clearNotifications() {
    _unreadNotifications = 0;
    notifyListeners();
  }

  void deleteDocument(String id) {
    _repository.removeDocument(id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _repository.toggleFavorite(id);
    notifyListeners();
  }

  void addScannedDocument({required String title, int pages = 1}) {
    final newDoc = PdfDocument(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      title: title.endsWith('.pdf') ? title : '$title.pdf',
      sizeFormatted: '${(pages * 0.45 + 0.3).toStringAsFixed(1)} MB',
      lastOpenedFormatted: 'Just now',
      pageCount: pages,
      category: 'Scanned',
      isFavorite: false,
      updatedAt: DateTime.now(),
    );
    _repository.addDocument(newDoc);
    notifyListeners();
  }
}
