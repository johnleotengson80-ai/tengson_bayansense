import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < AppSpacing.compactBreakpoint
              ? AppSpacing.small
              : AppSpacing.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: AppColors.primary, size: AppSpacing.statIconSize),
              const SizedBox(height: AppSpacing.small),
            ],
            Text(value, style: AppTextStyles.pageTitle),
            const SizedBox(height: AppSpacing.xSmall),
            Text(label, style: AppTextStyles.secondary),
          ],
        ),
      ),
    );
  }
}
