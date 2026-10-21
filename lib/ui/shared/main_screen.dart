import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../features/files/views/files_view.dart';
import '../features/home/view_models/home_view_model.dart';
import '../features/home/views/home_view.dart';
import '../features/home/widgets/top_app_bar.dart';
import '../features/scanner/views/scanner_modal.dart';
import '../features/settings/views/settings_view.dart';
import '../features/tools/views/tools_view.dart';
import 'status_bar.dart';

class MainScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const MainScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive container: on large screens center phone frame; on mobile full screen
            final isWideScreen = constraints.maxWidth > 500;

            final content = Container(
              color: AppColors.background,
              child: SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    // Simulated status bar on desktop/web
                    if (isWideScreen) const SimulatedStatusBar(),

                    // Top App Bar (shown when on Home tab)
                    if (viewModel.selectedNavIndex == 0)
                      HomeTopAppBar(viewModel: viewModel),

                    // Main Tab Body
                    Expanded(
                      child: IndexedStack(
                        index: viewModel.selectedNavIndex,
                        children: [
                          HomeView(viewModel: viewModel),
                          FilesView(viewModel: viewModel),
                          ToolsView(viewModel: viewModel),
                          SettingsView(viewModel: viewModel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            return Scaffold(
              backgroundColor: isWideScreen ? const Color(0xFFF1F5F9) : AppColors.background,
              body: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen ? 440 : double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: isWideScreen
                        ? Border.symmetric(
                            vertical: BorderSide(
                              color: AppColors.outlineVariant.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          )
                        : null,
                    boxShadow: isWideScreen
                        ? const [
                            BoxShadow(
                              color: Color.fromRGBO(15, 23, 42, 0.08),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      content,

                      // Extended FAB (visible on Home tab)
                      if (viewModel.selectedNavIndex == 0)
                        Positioned(
                          right: 16,
                          bottom: 96,
                          child: _buildExtendedFab(context),
                        ),

                      // Fixed Bottom Navigation Bar
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildBottomNavBar(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExtendedFab(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ScannerModal.show(context, viewModel: viewModel),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.fabShadow,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Scan Doc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            outlinedIcon: Icons.home_outlined,
            label: 'Home',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.folder_rounded,
            outlinedIcon: Icons.folder_outlined,
            label: 'Files',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.build_rounded,
            outlinedIcon: Icons.build_outlined,
            label: 'Tools',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.settings_rounded,
            outlinedIcon: Icons.settings_outlined,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData outlinedIcon,
    required String label,
  }) {
    final isSelected = viewModel.selectedNavIndex == index;

    return InkWell(
      onTap: () => viewModel.setNavIndex(index),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSelected ? icon : outlinedIcon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
