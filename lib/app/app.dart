import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router.dart';

/// The root application widget.
class JustMoveItApp extends ConsumerWidget {
  const JustMoveItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Bookaind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter, // <-- GoRouter handles all navigation!
    );
  }
}

/// A temporary starter screen to visually verify your brand colors & fonts.
class StarterVerificationScreen extends StatelessWidget {
  const StarterVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookaind',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Discover Cultural Heritage',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Explore the living traditions, culinary arts, and breathtaking landscapes of Java Island.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Start Exploring'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
