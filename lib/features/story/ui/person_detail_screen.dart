import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/story_controller.dart';
import '../models/story_models.dart';
import '../services/story_exporter.dart';

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.personId});
  final String personId;

  Future<void> _recordDialog(BuildContext context, WidgetRef ref) async {
    String selectedPrompt = StoryController.starterPrompts.first;
    final quoteCtrl = TextEditingController();
    final chapterCtrl = TextEditingController(text: 'Infancia y recuerdos');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Registrar relato literal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedPrompt,
                  isExpanded: true,
                  items: StoryController.starterPrompts
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(q, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setLocal(() => selectedPrompt = v);
                  },
                  decoration: const InputDecoration(labelText: 'Pregunta guía'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: chapterCtrl,
                  decoration: const InputDecoration(labelText: 'Capítulo'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quoteCtrl,
                  maxLines: 5,
                  minLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Sus palabras literales',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (ok == true && quoteCtrl.text.trim().isNotEmpty) {
      await ref.read(storyControllerProvider.notifier).recordAnswer(
            personId: personId,
            promptQuestion: selectedPrompt,
            verbatimQuote: quoteCtrl.text,
            chapterTitle: chapterCtrl.text,
          );
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    Persona person,
    List<Fragmento> fragments,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'historia_${person.id}.pdf'));
      await file.writeAsBytes(
          await StoryExporter.buildPdf(person: person, fragments: fragments));
      await Share.shareXFiles([XFile(file.path)],
          subject: 'Historia de ${person.name}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(storyControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatos y capítulos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _recordDialog(context, ref),
        icon: const Icon(Icons.mic_none),
        label: const Text('Añadir relato'),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final person =
              data.people.where((p) => p.id == personId).firstOrNull;
          if (person == null) {
            return const Center(child: Text('Persona no encontrada.'));
          }
          final sessionIds = data.sessions
              .where((s) => s.personId == person.id)
              .map((s) => s.id)
              .toSet();
          final frags = data.fragments
              .where((f) => sessionIds.contains(f.sessionId))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
            children: [
              Text(person.name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _exportPdf(context, person, frags),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Exportar libro PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (frags.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aún no hay relatos guardados.'),
                  ),
                )
              else
                ...frags.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(label: Text(f.chapterTitle)),
                              if (f.promptQuestion.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(f.promptQuestion,
                                    style: theme.textTheme.titleSmall),
                              ],
                              const SizedBox(height: 6),
                              Text('«${f.verbatimQuote}»',
                                  style: theme.textTheme.bodyLarge),
                            ],
                          ),
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}

