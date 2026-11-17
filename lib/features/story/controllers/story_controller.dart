import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/story_repository.dart';
import '../models/story_models.dart';

final storyRepositoryProvider = Provider<StoryRepository>(
  (ref) => StoryRepository(),
);

class StoryState {
  const StoryState({
    this.people = const [],
    this.sessions = const [],
    this.fragments = const [],
  });

  final List<Persona> people;
  final List<Sesion> sessions;
  final List<Fragmento> fragments;
}

class StoryController extends AsyncNotifier<StoryState> {
  static const List<String> starterPrompts = [
    '¿Cómo era la casa donde creciste y qué olor recuerdas de ella?',
    '¿Cuál fue tu primer trabajo o aprendizaje importante?',
    '¿Qué consejo te dieron tus padres que todavía recuerdas?',
    '¿Cuál fue el día más inesperado o feliz que viviste en familia?',
  ];

  @override
  Future<StoryState> build() async => _loadAll();

  StoryRepository get _repo => ref.read(storyRepositoryProvider);

  Future<StoryState> _loadAll() async => StoryState(
        people: await _repo.listPeople(),
        sessions: await _repo.listSessions(),
        fragments: await _repo.listFragments(),
      );

  Future<Persona> addPerson({
    required String name,
    String relation = '',
  }) async {
    final p = Persona(
      id: 'per_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      relation: relation.trim(),
      createdAt: DateTime.now(),
    );
    await _repo.upsertPerson(p);
    state = AsyncData(await _loadAll());
    return p;
  }

  Future<void> recordAnswer({
    required String personId,
    required String promptQuestion,
    required String verbatimQuote,
    String chapterTitle = 'Infancia y recuerdos',
  }) async {
    final now = DateTime.now();
    final sessionId = 'ses_${now.microsecondsSinceEpoch}';
    final session = Sesion(
      id: sessionId,
      personId: personId,
      topic: chapterTitle,
      recordedAt: now,
    );
    final frag = Fragmento(
      id: 'frag_${now.microsecondsSinceEpoch}',
      sessionId: sessionId,
      promptQuestion: promptQuestion.trim(),
      verbatimQuote: verbatimQuote.trim(),
      chapterTitle: chapterTitle.trim().isEmpty ? 'General' : chapterTitle.trim(),
    );
    await _repo.saveSessionWithFragment(session: session, fragment: frag);
    state = AsyncData(await _loadAll());
  }
}

final storyControllerProvider =
    AsyncNotifierProvider<StoryController, StoryState>(StoryController.new);

