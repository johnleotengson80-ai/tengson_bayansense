import 'package:flutter/material.dart';

import '../routing/routes.dart';
import '../widgets/centered_content.dart';

/// Shown for any address the app does not recognise (Activity 6, Part C "Unknown Route").
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: CenteredContent(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("We couldn't find that page."),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.root, (route) => false),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
