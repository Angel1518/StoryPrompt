import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_controller.dart';
import '../../../core/ai/ai_models.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final aiState = ref.watch(aiSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Apariencia', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Sistema'),
                      icon: Icon(Icons.brightness_auto_outlined)),
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Claro'),
                      icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Oscuro'),
                      icon: Icon(Icons.dark_mode_outlined)),
                ],
                selected: {themeMode},
                onSelectionChanged: (val) =>
                    ref.read(themeModeProvider.notifier).state = val.first,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading:
                  Icon(Icons.key_outlined, color: theme.colorScheme.primary),
              title: const Text('IA opcional (BYOK gratuito)'),
              subtitle: Text(aiState.enabled
                  ? 'Activa · ${aiState.selectedProvider.displayName}'
                  : 'Desactivada · 100 % offline'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/ai'),
            ),
          ),
        ],
      ),
    );
  }
}

