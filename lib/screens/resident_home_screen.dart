import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routing/routes.dart';
import '../state/auth_state.dart';
import '../widgets/centered_content.dart';

/// S02 - Resident Home: the two things a resident can do, and what BayanSense is (and is not) for.
class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BayanSense'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthState>().logout(),
          ),
        ],
      ),
      body: CenteredContent(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('What would you like to do?', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.edit_note,
              title: 'Submit a report',
              subtitle: 'Tell us about a flooding, drainage, sewer, or water problem.',
              onTap: () => Navigator.of(context).pushNamed(Routes.submitReport),
            ),
            _ActionCard(
              icon: Icons.list_alt,
              title: 'My reports',
              subtitle: 'See the status of the reports you submitted.',
              onTap: () => Navigator.of(context).pushNamed(Routes.myReports),
            ),
            const SizedBox(height: 16),
            Text(
              'BayanSense is for flooding, water waste, drainage, sewer, and clogged or damaged '
              'drainage problems in our barangay. It is not for emergencies, health concerns, '
              'permits, or police matters. In an emergency, contact your local emergency hotline.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
