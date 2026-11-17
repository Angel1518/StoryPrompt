import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/story/ui/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: StoryPromptApp()));
}

class StoryPromptApp extends ConsumerWidget {
  const StoryPromptApp({super.key});

  static const Color accentRose = Color(0xFFBE185D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'StoryPrompt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accentRose),
      darkTheme: AppTheme.dark(accent: accentRose),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
