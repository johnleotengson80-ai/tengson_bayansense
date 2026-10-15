import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isReceived = label == AppStrings.received;
    final isInProgress = label == AppStrings.inProgress;
    final isResolved = label == AppStrings.resolved;
    final background = isInProgress
        ? AppColors.primaryTint
        : isResolved
            ? AppColors.primary
            : AppColors.white;
    final foreground = isResolved ? AppColors.white : AppColors.primary;
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.badgeHorizontalPadding,
        vertical: AppSpacing.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.cornerRadius),
        border: Border.all(
          color: isReceived ? AppColors.primary : background,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: foreground),
      ),
    );
  }
}
