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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Greeting & Hero Section
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All your documents, one place',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.4,
                height: 1.25,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Read, convert, organize and manage PDFs.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

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
