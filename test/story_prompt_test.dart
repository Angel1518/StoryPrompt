import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:story_prompt/core/theme/app_theme.dart';
import 'package:story_prompt/features/story/controllers/story_controller.dart';
import 'package:story_prompt/features/story/data/story_repository.dart';
import 'package:story_prompt/features/story/models/story_models.dart';
import 'package:story_prompt/features/story/services/story_exporter.dart';
import 'package:story_prompt/features/story/ui/people_screen.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  test('StoryExporter preserves verbatim quotes in Markdown and PDF', () async {
    final person = Persona(
      id: 'p1',
      name: 'Abuela Carmen',
      relation: 'Abuela materna',
      createdAt: DateTime(2026, 11, 17),
    );
    const frags = [
      Fragmento(
        id: 'f1',
        sessionId: 's1',
        promptQuestion: '¿Cómo era tu casa?',
        verbatimQuote: 'Tenía un patio con limoneros.',
        chapterTitle: 'Infancia',
      ),
    ];

    final md = StoryExporter.buildMarkdown(person: person, fragments: frags);
    expect(md, contains('«Tenía un patio con limoneros.»'));
    final pdf = await StoryExporter.buildPdf(person: person, fragments: frags);
    expect(pdf.length, greaterThan(400));
  });

  testWidgets('PeopleScreen renders without overflow at 320px and 200% TextScaler', (tester) async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: StoryRepository.createSchema,
    );
    final repo = StoryRepository(testDb: db);
    await repo.upsertPerson(
      Persona(
        id: 'p_long',
        name: 'Familiar_${'S' * 100}',
        createdAt: DateTime(2026, 11, 17),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storyRepositoryProvider.overrideWithValue(repo)],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            theme: AppTheme.light(accent: const Color(0xFFBE185D)),
            home: const PeopleScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
    await db.close();
  });
}

