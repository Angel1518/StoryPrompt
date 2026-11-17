import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ai/ai_settings_screen.dart';
import '../features/story/ui/people_screen.dart';
import '../features/story/ui/person_detail_screen.dart';
import '../features/story/ui/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/people',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _StoryShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/people',
              builder: (context, state) => const PeopleScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => PersonDetailScreen(
                    personId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'ai',
                  builder: (context, state) => const AiSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _StoryShell extends StatelessWidget {
  const _StoryShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Historias',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

