import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/user_account.dart';
import '../routing/routes.dart';
import '../state/auth_state.dart';

class ResponsiveNavItem {
  const ResponsiveNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.role,
    required this.selectedRoute,
    required this.items,
    required this.child,
  });

  const ResponsiveScaffold.placeholder({
    super.key,
    required this.title,
    required this.role,
    required this.selectedRoute,
    required this.items,
  })  :
        child = const _PlaceholderContent();

  final String title;
  final String role;
  final String selectedRoute;
  final List<ResponsiveNavItem> items;
  final Widget child;

  int get _selectedIndex {
    final index = items.indexWhere((item) => item.route == selectedRoute);
    return index < 0 ? 0 : index;
  }

  void _select(BuildContext context, ResponsiveNavItem item) {
    if (item.route == selectedRoute) return;
    Navigator.of(context).pushNamedAndRemoveUntil(item.route, (route) => false);
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthState>().logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.root, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AuthState>().account;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppSpacing.compactBreakpoint;
        final wide = constraints.maxWidth >= AppSpacing.desktopBreakpoint;
        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
            child: child,
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (compact && account != null)
                  Text(
                    '${account.fullName} · ${account.roleLabel}',
                    style: AppTextStyles.secondary,
                  ),
              ],
            ),
            actions: compact
                ? [
                    IconButton(
                      tooltip: AppStrings.logoutTooltip,
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_outlined),
                    ),
                  ]
                : null,
          ),
          body: Row(
            children: [
              if (wide) _Sidebar(
                items: items,
                selectedIndex: _selectedIndex,
                account: account,
                onSelect: (item) => _select(context, item),
                onLogout: () => _logout(context),
              ),
              if (!compact && !wide)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (index) => _select(context, items[index]),
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.icon, color: AppColors.primary),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: wide
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.large,
                        ),
                        child: content,
                      )
                    : content,
              ),
            ],
          ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => _select(context, items[index]),
                  destinations: [
                    for (final item in items)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.account,
    required this.onSelect,
    required this.onLogout,
  });

  final List<ResponsiveNavItem> items;
  final int selectedIndex;
  final UserAccount? account;
  final ValueChanged<ResponsiveNavItem> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.subtleSurface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.large),
            child: Text(AppStrings.appName, style: AppTextStyles.sectionTitle),
          ),
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  minTileHeight: AppSpacing.minimumTouchTarget,
                  selected: index == selectedIndex,
                  selectedColor: AppColors.primary,
                  selectedTileColor: AppColors.primaryTint,
                  leading: Icon(items[index].icon),
                  title: Text(items[index].label),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.cornerRadius),
                  ),
                  onTap: () => onSelect(items[index]),
                ),
              ),
            ),
          const Spacer(),
          if (account != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account!.fullName, style: AppTextStyles.cardTitle),
                  Text(account!.roleLabel, style: AppTextStyles.secondary),
                ],
              ),
            ),
          ListTile(
            minTileHeight: AppSpacing.minimumTouchTarget,
            leading: const Icon(Icons.logout_outlined),
            title: const Text(AppStrings.logout),
            onTap: onLogout,
          ),
          const SizedBox(height: AppSpacing.small),
        ],
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Text(
          AppStrings.thisSectionNextPhase,
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}
