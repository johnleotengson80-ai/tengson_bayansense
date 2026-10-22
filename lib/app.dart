import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_strings.dart';
import 'routing/app_router.dart';
import 'services/bayan_sense_service.dart';
import 'services/token_store.dart';
import 'state/auth_state.dart';
import 'state/reports_state.dart';
import 'theme.dart';

class BayanSenseApp extends StatefulWidget {
  const BayanSenseApp({
    super.key,
    required this.service,
    required this.tokenStore,
  });

  final BayanSenseService service;
  final TokenStore tokenStore;

  @override
  State<BayanSenseApp> createState() => _BayanSenseAppState();
}

class _BayanSenseAppState extends State<BayanSenseApp> {
  late final AuthState _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthState(service: widget.service, store: widget.tokenStore);
    _auth.restore();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: _auth),
        Provider<BayanSenseService>.value(value: widget.service),
        ChangeNotifierProvider<ReportsState>(
          create: (_) => ReportsState(widget.service),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        onGenerateRoute: AppRouter.generate,
      ),
    );
  }
}
