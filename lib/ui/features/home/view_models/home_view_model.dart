import 'package:flutter/material.dart';
import '../../../../data/repositories/pdf_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../domain/models/app_user.dart';
import '../../../../domain/models/pdf_document.dart';
import '../../../../domain/models/pdf_tool.dart';
import '../../../../domain/models/recent_file.dart';

class HomeViewModel extends ChangeNotifier {
  final PdfRepository _repository;
  final AuthService _authService = AuthService();

  // ignore: prefer_initializing_formals
  HomeViewModel({required PdfRepository repository}) : _repository = repository {
    _authService.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    _repository.switchUser(_authService.currentUser?.id);
    notifyListeners();
  }

  // Auth getters
  bool get isAuthenticated => _authService.isAuthenticated;
  AppUser? get currentUser => _authService.currentUser;
  String get currentUserName => _authService.currentUser?.displayName ?? 'Guest';
  String get currentUserEmail => _authService.currentUser?.email ?? '';

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

  List<RecentFile> get recentFiles => _repository.getRecentFiles(limit: 5);

  List<RecentFile> get allRecentFiles =>
      _repository.getAllFiles(query: _searchQuery, filter: _fileFilter);

  // Backward compatibility
  List<PdfDocument> get recentDocuments => _repository.getRecentDocuments(limit: 4);
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

  void addRecentFile(RecentFile file) {
    _repository.addRecentFile(file);
    notifyListeners();
  }

  void deleteRecentFile(String id) {
    _repository.deleteRecentFile(id);
    notifyListeners();
  }

  void clearHistory() {
    _repository.clearHistory();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _repository.toggleFavorite(id);
    notifyListeners();
  }

  void addDocument(PdfDocument doc) {
    _repository.addDocument(doc);
    notifyListeners();
  }

  void deleteDocument(String id) {
    _repository.removeDocument(id);
    notifyListeners();
  }

  void addScannedDocument({required String title, int pages = 1}) {
    final newFile = RecentFile(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      originalFileName: 'Camera Scan ($pages pages)',
      processedFileName: title.endsWith('.pdf') ? title : '$title.pdf',
      toolUsed: 'Scan Doc',
      processedAt: DateTime.now(),
      fileType: 'PDF',
      fileSizeBytes: (pages * 450 * 1024 + 100 * 1024),
      fileSizeFormatted: '${(pages * 0.45 + 0.1).toStringAsFixed(1)} MB',
      userId: currentUser?.id ?? 'guest',
      pageCount: pages,
      isFavorite: false,
    );
    _repository.addRecentFile(newFile);
    notifyListeners();
  }

  void onUserAuthenticated() {
    _repository.switchUser(_authService.currentUser?.id);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _repository.switchUser(null);
    notifyListeners();
  }
}
