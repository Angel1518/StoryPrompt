import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/story_controller.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  Future<void> _addPersonDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva persona'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 10),
            TextField(
                controller: relCtrl,
                decoration: const InputDecoration(
                    labelText: 'Relación (ej. Abuela, Padre)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Crear')),
        ],
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      final p = await ref
          .read(storyControllerProvider.notifier)
          .addPerson(name: nameCtrl.text, relation: relCtrl.text);
      if (context.mounted) context.push('/people/${p.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(storyControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('StoryPrompt')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPersonDialog(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Persona'),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Conserva su voz, sus palabras y su historia',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            if (data.people.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_outlined,
                            size: 52, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        Text('Empieza una historia familiar',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Añade a un familiar, usa las preguntas guía y conserva sus citas literales en un libro PDF/Markdown.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                sliver: SliverList.separated(
                  itemCount: data.people.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final person = data.people[i];
                    final sessions = data.sessions
                        .where((s) => s.personId == person.id)
                        .length;
                    return TweenAnimationBuilder<double>(
                      duration: AppMotion.duration(
                          context, Duration(milliseconds: 180 + (i.clamp(0, 6) * 35))),
                      curve: AppMotion.curve(context),
                      tween: Tween(begin: 0, end: 1),
                      builder: (ctx, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - t)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            child: Icon(Icons.record_voice_over_outlined,
                                color: theme.colorScheme.primary),
                          ),
                          title: Text(person.name,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              '${person.relation.isEmpty ? 'Familia' : person.relation} · $sessions relatos'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/people/${person.id}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

