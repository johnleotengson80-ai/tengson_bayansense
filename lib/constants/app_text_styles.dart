import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle eyebrow = TextStyle(
    color: AppColors.primary,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
  );
  static const TextStyle pageTitle = TextStyle(
    color: AppColors.text,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle heroTitle = TextStyle(
    color: AppColors.text,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.12,
  );
  static const TextStyle compactHeroTitle = TextStyle(
    color: AppColors.text,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.12,
  );
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.text,
    fontSize: 21,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    height: 1.5,
  );
  static const TextStyle secondary = TextStyle(
    color: AppColors.secondaryText,
    fontSize: 13,
    height: 1.45,
  );
  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
