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
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
        // App Logo
        const BrandLogo(size: 30),
        const SizedBox(width: 10),

        // App Title
        const Text(
          'DB PDF Tools',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
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
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Search tools & documents',
          onPressed: viewModel.toggleSearching,
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
}
