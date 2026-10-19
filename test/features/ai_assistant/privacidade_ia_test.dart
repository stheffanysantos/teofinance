import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Garante, lendo o código-fonte, a fronteira de privacidade da IA local:
/// `features/ai_assistant/` nunca importa rede, Firebase nem leitura de arquivo
/// de extrato (ver `.claude/rules/architecture.md` e decisão 0004).
void main() {
  final proibidos = <String, String>{
    'package:http/': 'cliente HTTP',
    'package:dio/': 'cliente HTTP',
    'package:cloud_firestore/': 'Firestore',
    'package:firebase_storage/': 'Firebase Storage',
    'package:firebase_core/': 'Firebase',
    'package:file_picker/': 'leitura de arquivo de extrato',
    'package:csv/': 'parser de extrato',
    'dart:io': 'acesso a rede/arquivo',
    'dart:html': 'acesso a rede',
  };

  final arquivos = Directory('lib/features/ai_assistant')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('a feature tem código para auditar', () {
    expect(arquivos, isNotEmpty);
  });

  for (final arquivo in arquivos) {
    test('${arquivo.path.replaceAll('\\', '/')} não importa rede nem fontes externas de dados', () {
      final imports = arquivo.readAsLinesSync().where((l) => l.trimLeft().startsWith('import '));

      for (final linha in imports) {
        for (final entrada in proibidos.entries) {
          expect(
            linha.contains(entrada.key),
            isFalse,
            reason: 'import proibido (${entrada.value}): $linha',
          );
        }
      }
    });
  }
}
