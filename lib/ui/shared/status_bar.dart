import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SimulatedStatusBar extends StatelessWidget {
  const SimulatedStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.background,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '09:41',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.onSurface,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi, size: 16, color: AppColors.onSurface),
              SizedBox(width: 6),
              Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.onSurface),
              SizedBox(width: 6),
              Icon(Icons.battery_full, size: 18, color: AppColors.onSurface),
            ],
          ),
        ],
      ),
    );
  }
}
