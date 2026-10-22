import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../view_models/home_view_model.dart';
import '../widgets/admob_banner.dart';
import '../widgets/all_tools_grid.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_documents_section.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = viewModel.isAuthenticated;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Greeting & Hero Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn
                        ? 'Hello, ${viewModel.currentUserName} 👋'
                        : 'All your documents, one place',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn
                        ? 'All conversion tools unlocked. Files auto-save to your account.'
                        : 'Read, convert, organize and manage PDFs from local device.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),


        // Quick Actions Grid (2x2 Prominent Bento Grid)
        QuickActionsGrid(viewModel: viewModel),
        const SizedBox(height: 24),

        // All Tools Section (3-column grid)
        AllToolsGrid(viewModel: viewModel),
        const SizedBox(height: 24),

        // Recent Documents Section
        RecentDocumentsSection(viewModel: viewModel),
        const SizedBox(height: 20),

        // AdMob Test Banner Area (320x50 Banner above BottomNavBar)
        const AdmobBanner(),
        const SizedBox(height: 24),
      ],
    );
  }
}
