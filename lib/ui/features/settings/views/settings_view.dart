import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/brand_logo.dart';

class SettingsView extends StatefulWidget {
  final HomeViewModel viewModel;

  const SettingsView({super.key, required this.viewModel});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _autoEnhance = true;
  bool _hardwareOcr = true;
  String _cacheSize = '11.4 MB';
  bool _isPro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: const Row(
          children: [
            BrandLogo(size: 30),
            SizedBox(width: 10),
            Text('Settings', style: AppTypography.headlineSm),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Enhanced, Clean & Simple Subscription Card
          _buildSubscriptionCard(context),
          const SizedBox(height: 16),

          // Supabase Authentication & Cloud Sync Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3ECF8E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.viewModel.isAuthenticated
                            ? 'Supabase Auth: Signed in as ${widget.viewModel.currentUserName}'
                            : 'Supabase Cloud Authentication Ready',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.viewModel.isAuthenticated
                            ? widget.viewModel.currentUserEmail
                            : 'Project: db-pdf-tools • Email OTP & Google OAuth',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.viewModel.isAuthenticated ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Processing & Scanner preferences
          const Text('Scan & OCR Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Material(
            color: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-Enhance Scans', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Sharpen text & auto-align document borders', style: TextStyle(fontSize: 12)),
                  value: _autoEnhance,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _autoEnhance = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('On-Device Fast OCR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Extract text without internet connection', style: TextStyle(fontSize: 12)),
                  value: _hardwareOcr,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _hardwareOcr = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Storage & Cache
          const Text('Storage & Cache', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cache & Temporary Files', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Currently used: $_cacheSize', style: AppTypography.bodySm),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() => _cacheSize = '0 KB');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache successfully cleared')),
                    );
                  },
                  child: const Text('Clear', style: TextStyle(color: AppColors.onSurface, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About App
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Material(
            color: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('App Version', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: Text('1.0.0 (Build 2026)', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                  title: const Text('Privacy Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded, color: AppColors.primary),
                  title: const Text('Rate DB PDF Tools', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Author & Copyright Footer
          _buildFooterSection(),
          const SizedBox(height: 80), // Clearance for bottom navigation bar
        ],
      ),
    );
  }

  /// Modern, Simple & Beautiful Subscription Card
  Widget _buildSubscriptionCard(BuildContext context) {
    if (_isPro) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.successContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DB PDF Tools PRO Active',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.onSurface),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'All premium features & unlimited OCR unlocked.',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(37, 99, 235, 0.08),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle top-right gradient accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header row: Crown badge + Plan price
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF004AC6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DB PDF Tools PRO',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'Unlock ultimate productivity',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '\$2.99/mo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Features Checklist
                _buildFeatureItem('Unlimited On-Device Fast OCR & Document Scan'),
                const SizedBox(height: 6),
                _buildFeatureItem('Batch Merge, Compress, Split & E-Signatures'),
                const SizedBox(height: 6),
                _buildFeatureItem('100% Ad-Free Experience with Priority Updates'),
                const SizedBox(height: 16),

                // Upgrade Button & Restore Purchases
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() => _isPro = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.onSurface,
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                                  SizedBox(width: 8),
                                  Text('Congratulations! PRO activated.'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Upgrade Now',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checking previous purchases...')),
                        );
                      },
                      child: const Text(
                        'Restore',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.successContainer.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: AppColors.tertiary, size: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Copyright Footer
  Widget _buildFooterSection() {
    return const Center(
      child: Text(
        '© 2026 DB PDF Tools. All rights reserved.',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
