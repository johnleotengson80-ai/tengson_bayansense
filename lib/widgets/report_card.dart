import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../format.dart';
import '../models/report.dart';
import 'status_badge.dart';

/// One report in a list. Reused by My Reports now and the staff dashboard later (Activity 6, Part E).
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.showReviewFlag = false,
  });

  final Report report;
  final VoidCallback onTap;

  /// Staff see a "Needs Review" chip on low-confidence reports; residents do not.
  final bool showReviewFlag;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(report.referenceNumber, style: AppTextStyles.cardTitle),
                  const Spacer(),
                  Text(formatDate(report.createdAt), style: AppTextStyles.secondary),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.medium),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge(label: report.status),
                  if (showReviewFlag && report.needsManualReview)
                    const StatusBadge(label: AppStrings.needsReview),
                  Text(
                    report.predictedCategory ?? AppStrings.categoryPending,
                    style: AppTextStyles.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
