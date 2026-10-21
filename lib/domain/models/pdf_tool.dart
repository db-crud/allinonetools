import 'package:flutter/material.dart';

enum ToolCategory {
  all('All'),
  convert('Convert'),
  organize('Organize'),
  edit('Edit'),
  security('Security & Optimize');

  final String label;
  const ToolCategory(this.label);
}

class PdfTool {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final ToolCategory category;
  final bool isQuickAction;
  final String? badgeText;

  const PdfTool({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.category,
    this.isQuickAction = false,
    this.badgeText,
  });
}
