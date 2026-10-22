import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < AppSpacing.compactBreakpoint;
            return Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.contentMaxWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile
                            ? AppSpacing.mobilePagePadding
                            : AppSpacing.pagePadding,
                      ),
                      child: _Header(
                        mobile: mobile,
                        onLogin: () => _open(context, Routes.login),
                        onRegister: () => _open(context, Routes.register),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppSpacing.contentMaxWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: mobile
                                    ? AppSpacing.mobilePagePadding
                                    : AppSpacing.pagePadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Hero(
                                    mobile: mobile,
                                    onReport: () =>
                                        _open(context, Routes.reportForm),
                                    onLogin: () => _open(context, Routes.login),
                                  ),
                                  if (kDebugMode) ...[
                                    const SizedBox(height: AppSpacing.large),
                                    const _RolePreview(),
                                  ],
                                  const SizedBox(height: AppSpacing.xxLarge),
                                  const _StepsSection(),
                                  const SizedBox(height: AppSpacing.xxLarge),
                                  _ProblemTypesSection(
                                      width: constraints.maxWidth),
                                  const SizedBox(height: AppSpacing.xxLarge),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _Footer(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.mobile,
    required this.onLogin,
    required this.onRegister,
  });

  final bool mobile;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.headerHeight,
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.small),
          const Text(AppStrings.appName, style: AppTextStyles.sectionTitle),
          const Spacer(),
          if (mobile)
            PopupMenuButton<String>(
              tooltip: AppStrings.publicHome,
              icon: const Icon(Icons.menu),
              onSelected: (value) =>
                  value == AppStrings.login ? onLogin() : onRegister(),
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: AppStrings.login, child: Text(AppStrings.login)),
                PopupMenuItem(
                  value: AppStrings.createAccount,
                  child: Text(AppStrings.createAccount),
                ),
              ],
            )
          else ...[
            TextButton(onPressed: onLogin, child: const Text(AppStrings.login)),
            const SizedBox(width: AppSpacing.small),
            FilledButton(
              onPressed: onRegister,
              child: const Text(AppStrings.createAccount),
            ),
          ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.mobile,
    required this.onReport,
    required this.onLogin,
  });

  final bool mobile;
  final VoidCallback onReport;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? AppSpacing.medium : AppSpacing.xxLarge,
        vertical: mobile ? AppSpacing.xLarge : AppSpacing.xxLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.subtleSurface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.cornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.appNameUpper, style: AppTextStyles.eyebrow),
          const SizedBox(height: AppSpacing.medium),
          Text(
            AppStrings.publicHeadline,
            style: mobile
                ? AppTextStyles.compactHeroTitle
                : AppTextStyles.heroTitle,
          ),
          const SizedBox(height: AppSpacing.medium),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.heroDescriptionMaxWidth,
            ),
            child: const Text(AppStrings.publicDescription,
                style: AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.large),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              FilledButton.icon(
                onPressed: onReport,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text(AppStrings.reportProblem),
              ),
              OutlinedButton(
                onPressed: onLogin,
                child: const Text(AppStrings.login),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RolePreview extends StatelessWidget {
  const _RolePreview();

  @override
  Widget build(BuildContext context) {
    const previews = <(String, IconData, String)>[
      (AppStrings.residentRole, Icons.person_outline, Routes.residentHome),
      (AppStrings.staffRole, Icons.groups_outlined, Routes.staffHome),
      (AppStrings.adminRole, Icons.admin_panel_settings_outlined, Routes.adminHome),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.previewDashboards,
            style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final preview in previews)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(preview.$3),
                icon: Icon(preview.$2),
                label: Text(preview.$1),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection();

  @override
  Widget build(BuildContext context) {
    const steps = <(String, IconData)>[
      (AppStrings.submitStep, Icons.edit_note_outlined),
      (AppStrings.routingStep, Icons.account_tree_outlined),
      (AppStrings.trackStep, Icons.track_changes_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.howItWorks, style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.medium),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < AppSpacing.compactBreakpoint ? 1 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: AppSpacing.howItWorksCardHeight,
                crossAxisSpacing: AppSpacing.medium,
                mainAxisSpacing: AppSpacing.medium,
              ),
              itemBuilder: (context, index) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Row(
                    children: [
                      Icon(steps[index].$2, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: Text(
                          '${index + 1}. ${steps[index].$1}',
                          style: AppTextStyles.cardTitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProblemTypesSection extends StatelessWidget {
  const _ProblemTypesSection({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final columns = width < AppSpacing.compactBreakpoint
        ? 1
        : width < AppSpacing.desktopBreakpoint
            ? 3
            : 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.whatWeHandle, style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.medium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: AppStrings.problemTypes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: AppSpacing.problemTypeCardHeight,
            crossAxisSpacing: AppSpacing.medium,
            mainAxisSpacing: AppSpacing.medium,
          ),
          itemBuilder: (context, index) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_damage_outlined,
                      color: AppColors.primary),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    AppStrings.problemTypes[index],
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: const Center(
        child: Text(AppStrings.footer, style: AppTextStyles.secondary),
      ),
    );
  }
}
