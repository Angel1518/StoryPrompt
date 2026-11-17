class Persona {
  const Persona({
    required this.id,
    required this.name,
    this.relation = '',
    this.birthYear,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String relation;
  final int? birthYear;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'relation': relation,
        'birth_year': birthYear,
        'created_at': createdAt.toIso8601String(),
      };

  factory Persona.fromMap(Map<String, dynamic> map) => Persona(
        id: map['id'] as String,
        name: map['name'] as String,
        relation: map['relation'] as String? ?? '',
        birthYear: map['birth_year'] as int?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class Sesion {
  const Sesion({
    required this.id,
    required this.personId,
    required this.topic,
    required this.recordedAt,
  });

  final String id;
  final String personId;
  final String topic;
  final DateTime recordedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'person_id': personId,
        'topic': topic,
        'recorded_at': recordedAt.toIso8601String(),
      };

  factory Sesion.fromMap(Map<String, dynamic> map) => Sesion(
        id: map['id'] as String,
        personId: map['person_id'] as String,
        topic: map['topic'] as String,
        recordedAt: DateTime.parse(map['recorded_at'] as String),
      );
}

class Fragmento {
  const Fragmento({
    required this.id,
    required this.sessionId,
    required this.promptQuestion,
    required this.verbatimQuote,
    this.chapterTitle = 'Sin clasificar',
    this.isReviewed = true,
  });

  final String id;
  final String sessionId;
  final String promptQuestion;
  final String verbatimQuote;
  final String chapterTitle;
  final bool isReviewed;

  Fragmento copyWith({String? chapterTitle, bool? isReviewed}) => Fragmento(
        id: id,
        sessionId: sessionId,
        promptQuestion: promptQuestion,
        verbatimQuote: verbatimQuote,
        chapterTitle: chapterTitle ?? this.chapterTitle,
        isReviewed: isReviewed ?? this.isReviewed,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'prompt_question': promptQuestion,
        'verbatim_quote': verbatimQuote,
        'chapter_title': chapterTitle,
        'is_reviewed': isReviewed ? 1 : 0,
      };

  factory Fragmento.fromMap(Map<String, dynamic> map) => Fragmento(
        id: map['id'] as String,
        sessionId: map['session_id'] as String,
        promptQuestion: map['prompt_question'] as String? ?? '',
        verbatimQuote: map['verbatim_quote'] as String,
        chapterTitle: map['chapter_title'] as String? ?? 'Sin clasificar',
        isReviewed: (map['is_reviewed'] as int? ?? 1) == 1,
      );
}

