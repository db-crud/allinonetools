import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../view_models/home_view_model.dart';
import 'brand_logo.dart';

class HomeTopAppBar extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeTopAppBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: viewModel.isSearching
          ? _buildSearchBar(context)
          : _buildDefaultHeader(context),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    return Row(
      children: [
        const BrandLogo(size: 34),
        const SizedBox(width: 12),
        const Text(
          'DB PDF Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.onSurface,
          ),
        ),
        const Spacer(),
        // Search icon button
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            size: 22,
            color: AppColors.onSurfaceVariant,
          ),
          splashRadius: 20,
          tooltip: 'Search tools & documents',
          onPressed: viewModel.toggleSearching,
        ),
        // Notifications icon button with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                size: 22,
                color: AppColors.onSurfaceVariant,
              ),
              splashRadius: 20,
              tooltip: 'Notifications',
              onPressed: () => _showNotificationsDialog(context),
            ),
            if (viewModel.unreadNotifications > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            autofocus: true,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: const InputDecoration(
              hintText: 'Search tools or documents...',
              hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: viewModel.setSearchQuery,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.onSurfaceVariant),
          splashRadius: 18,
          onPressed: viewModel.toggleSearching,
        ),
      ],
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    viewModel.clearNotifications();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Notifications', style: AppTypography.headlineSm),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt, color: AppColors.primary, size: 20),
              ),
              title: const Text('Fast OCR Engine Ready', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('High accuracy scanner is now activated for all documents.', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
