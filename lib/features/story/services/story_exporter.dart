import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../models/story_models.dart';

class StoryExporter {
  static String buildMarkdown({
    required Persona person,
    required List<Fragmento> fragments,
  }) {
    final buf = StringBuffer()
      ..writeln('# Historia de ${person.name}')
      ..writeln(
          person.relation.isEmpty ? '' : '_${person.relation}_\n');

    final chapters = fragments.map((f) => f.chapterTitle).toSet();
    for (final ch in chapters) {
      buf.writeln('## $ch\n');
      for (final frag in fragments.where((f) => f.chapterTitle == ch)) {
        if (frag.promptQuestion.isNotEmpty) {
          buf.writeln('**Pregunta:** ${frag.promptQuestion}\n');
        }
        buf.writeln('> «${frag.verbatimQuote}»\n');
      }
    }
    return buf.toString();
  }

  static Future<Uint8List> buildPdf({
    required Persona person,
    required List<Fragmento> fragments,
  }) async {
    final doc = pw.Document();
    final chapters = fragments.map((f) => f.chapterTitle).toSet().toList();

    doc.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Historia familiar: ${person.name}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (person.relation.isNotEmpty)
            pw.Paragraph(text: 'Relación: ${person.relation}'),
          ...chapters.expand((ch) {
            final chFrags = fragments.where((f) => f.chapterTitle == ch);
            return [
              pw.Header(level: 1, child: pw.Text(ch)),
              ...chFrags.map(
                (f) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (f.promptQuestion.isNotEmpty)
                        pw.Text(
                          f.promptQuestion,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      pw.Text('«${f.verbatimQuote}»'),
                    ],
                  ),
                ),
              ),
            ];
          }),
        ],
      ),
    );
    return doc.save();
  }
}

