import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../state/auth_state.dart';
import '../widgets/loading_screen.dart';
import 'routes.dart';

/// Wraps a screen with its client-side access rule.
///
///  - signed out                     -> /login
///  - signed in with the wrong role  -> that role's own home
///  - [guestOnly] (the login page)   -> signed-in users go to their home instead
///
/// Backend authorization is outside this UI-only demo.
class RouteGuard extends StatefulWidget {
  const RouteGuard({
    super.key,
    required this.child,
    this.requiredRole,
    this.guestOnly = false,
  });

  final Widget child;
  final String? requiredRole;
  final bool guestOnly;

  @override
  State<RouteGuard> createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  bool _redirecting = false;

  void _redirect(String routeName) {
    if (_redirecting) return;
    _redirecting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) return widget.child;

    final auth = context.watch<AuthState>();

    if (auth.restoring) return const LoadingScreen();

    if (widget.guestOnly) {
      if (auth.isAuthenticated) {
        _redirect(Routes.homeFor(auth.role!));
        return const LoadingScreen();
      }
      return widget.child;
    }

    if (!auth.isAuthenticated) {
      _redirect(Routes.login);
      return const LoadingScreen();
    }

    final required = widget.requiredRole;
    if (required != null && auth.role != required) {
      _redirect(Routes.homeFor(auth.role!));
      return const LoadingScreen();
    }
    return widget.child;
  }
}

/// The "/" route: sends signed-in users to their role home and shows the public landing page.
class RootRedirect extends StatefulWidget {
  const RootRedirect({super.key});

  @override
  State<RootRedirect> createState() => _RootRedirectState();
}

class _RootRedirectState extends State<RootRedirect> {
  bool _redirecting = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    if (!auth.restoring && !_redirecting) {
      if (auth.isAuthenticated) {
        _redirecting = true;
        final target = Routes.homeFor(auth.role!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(target, (route) => false);
        });
      } else {
        return const HomeScreen();
      }
    }
    return const LoadingScreen();
  }
}
