import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/sync/sync_pausa.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_conta_data_source.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_local_data_source.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_remote_data_source.dart';
import 'package:teofinance/features/lgpd/data/repositories/lgpd_repository_impl.dart';
import 'package:teofinance/features/meta/data/datasources/meta_local_datasource.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

class _Conta implements LgpdContaDataSource {
  @override
  String? uid = 'u1';
  @override
  String? email = 'ana@exemplo.com';

  String senhaCorreta = 'certa';
  bool falharAoExcluirConta = false;
  bool contaExcluida = false;

  @override
  Future<void> reautenticar(String senha) async {
    if (senha != senhaCorreta) throw fb.FirebaseAuthException(code: 'wrong-password');
  }

  @override
  Future<void> excluirConta() async {
    if (falharAoExcluirConta) throw fb.FirebaseAuthException(code: 'requires-recent-login');
    contaExcluida = true;
  }
}

class _ArmazenamentoSeguro implements FlutterSecureStorage {
  final dados = <String, String>{'biometria': 'true', 'discreto': '1'};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final nome = invocation.memberName;
    if (nome == #deleteAll) {
      dados.clear();
      return Future<void>.value();
    }
    final chave = invocation.namedArguments[#key] as String?;
    if (nome == #write) {
      dados[chave!] = invocation.namedArguments[#value] as String;
      return Future<void>.value();
    }
    if (nome == #read) return Future<String?>.value(dados[chave]);
    if (nome == #delete) {
      dados.remove(chave);
      return Future<void>.value();
    }
    throw UnimplementedError(nome.toString());
  }
}

/// Firestore sem conexão: qualquer chamada falha como falharia no aparelho.
class _FirestoreOffline implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
}

Failure _falha<T>(dynamic r) => (r.swap().getOrElse((_) => throw StateError('esperava Left'))) as Failure;

void main() {
  late AppDatabase db;
  late FakeFirebaseFirestore nuvem;
  late _Conta conta;
  late _ArmazenamentoSeguro seguro;

  LgpdRepositoryImpl criar({FirebaseFirestore? firestore}) => LgpdRepositoryImpl(
        LgpdLocalDataSource(db, seguro),
        LgpdRemoteDataSource(firestore ?? nuvem),
        conta,
        agora: () => DateTime(2026, 10, 19, 12),
      );

  Future<void> semearLocal() async {
    await TransacaoLocalDataSource(db).criar(
      descricao: 'Café',
      valor: -12.5,
      data: DateTime(2026, 10, 5),
      categoria: 'Mercado',
    );
    await OrcamentoLocalDataSource(db).definirLimite(categoria: 'Mercado', limite: 500);
    await MetaLocalDataSource(db).criar(
      nome: 'Reserva',
      valorAlvo: 1000,
      prazo: DateTime(2027, 12, 1),
      valorAtual: 100,
    );
  }

  Future<void> semearNuvem() async {
    for (final nome in LgpdRemoteDataSource.colecoes) {
      await nuvem.collection('users').doc('u1').collection(nome).doc('a').set({'x': 1});
      await nuvem.collection('users').doc('u1').collection(nome).doc('b').set({'x': 2});
    }
  }

  Future<int> docsNaNuvem() async {
    var total = 0;
    for (final nome in LgpdRemoteDataSource.colecoes) {
      total += (await nuvem.collection('users').doc('u1').collection(nome).get()).docs.length;
    }
    return total;
  }

  Future<int> linhasLocais() async {
    var total = 0;
    for (final tabela in db.allTables) {
      total += (await db.select(tabela).get()).length;
    }
    return total;
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    nuvem = FakeFirebaseFirestore();
    conta = _Conta();
    seguro = _ArmazenamentoSeguro();
  });

  tearDown(() => db.close());

  group('exportar', () {
    test('reúne conta, data e todas as tabelas, com datas em texto ISO', () async {
      await semearLocal();

      final json = (await criar().exportarDados()).getOrElse((f) => throw StateError(f.message));
      final arquivo = jsonDecode(json) as Map<String, dynamic>;

      expect(arquivo['versao'], 1);
      expect(arquivo['exportadoEm'], '2026-10-19T12:00:00.000');
      expect(arquivo['conta'], {'uid': 'u1', 'email': 'ana@exemplo.com'});

      final dados = arquivo['dados'] as Map<String, dynamic>;
      expect(dados.keys, containsAll([
        'transacoes', 'perfis_banco', 'rendas', 'metas', 'parcelamentos',
        'orcamentos', 'extrato_linhas', 'reconciliacao_vinculos',
      ]));
      expect((dados['transacoes'] as List).single['name'], 'Café');
      expect((dados['orcamentos'] as List).single['limite'], 500);
      expect((dados['metas'] as List).single['nome'], 'Reserva');
      expect((dados['transacoes'] as List).single['occurredAt'], isA<String>());
    });

    test('sem dados, cada tabela sai como lista vazia', () async {
      final json = (await criar().exportarDados()).getOrElse((f) => throw StateError(f.message));
      final dados = (jsonDecode(json) as Map<String, dynamic>)['dados'] as Map<String, dynamic>;

      expect(dados.values.every((v) => (v as List).isEmpty), isTrue);
    });
  });

  group('excluir', () {
    test('senha errada não apaga nada em lugar nenhum', () async {
      await semearLocal();
      await semearNuvem();

      final r = await criar().excluirTodosOsDados(senha: 'errada');

      expect(_falha(r), isA<AuthFailure>());
      expect(_falha(r).message, 'Senha incorreta.');
      expect(await docsNaNuvem(), greaterThan(0));
      expect(await linhasLocais(), greaterThan(0));
      expect(conta.contaExcluida, isFalse);
    });

    test('com a senha certa apaga a nuvem, a conta e o aparelho', () async {
      await semearLocal();
      await semearNuvem();

      final r = await criar().excluirTodosOsDados(senha: 'certa');

      expect(r.isRight(), isTrue);
      expect(await docsNaNuvem(), 0);
      expect(conta.contaExcluida, isTrue);
      expect(await linhasLocais(), 0);
      expect(seguro.dados, isEmpty);
    });

    test('apaga mais de um lote de documentos', () async {
      final colecao = nuvem.collection('users').doc('u1').collection('transacoes');
      for (var i = 0; i < 850; i++) {
        await colecao.doc('t$i').set({'x': i});
      }

      final r = await criar().excluirTodosOsDados(senha: 'certa');

      expect(r.isRight(), isTrue);
      expect((await colecao.get()).docs, isEmpty);
    });

    test('sem conexão nada é apagado, o usuário continua com a conta e pode repetir', () async {
      await semearLocal();

      final r = await criar(firestore: _FirestoreOffline()).excluirTodosOsDados(senha: 'certa');

      expect(_falha(r), isA<ServerFailure>());
      expect(conta.contaExcluida, isFalse);
      expect(await linhasLocais(), greaterThan(0));
      expect(seguro.dados, isNotEmpty);
    });

    test('falha ao apagar a conta mantém os dados locais e explica como repetir', () async {
      await semearLocal();
      await semearNuvem();
      conta.falharAoExcluirConta = true;

      final r = await criar().excluirTodosOsDados(senha: 'certa');

      expect(_falha(r), isA<AuthFailure>());
      expect(_falha(r).message, contains('Saia, entre de novo'));
      expect(await linhasLocais(), greaterThan(0));
      expect(conta.contaExcluida, isFalse);
    });

    test('falha ao apagar a conta depois de apagar a nuvem pausa o sync, para não reenviar os dados', () async {
      await semearLocal();
      await semearNuvem();
      conta.falharAoExcluirConta = true;

      await criar().excluirTodosOsDados(senha: 'certa');

      expect(await syncPausado(seguro), isTrue);
    });

    test('sem conexão o sync não fica pausado, pois a nuvem não foi apagada', () async {
      await semearLocal();

      await criar(firestore: _FirestoreOffline()).excluirTodosOsDados(senha: 'certa');

      expect(await syncPausado(seguro), isFalse);
    });

    test('senha errada não pausa o sync', () async {
      await criar().excluirTodosOsDados(senha: 'errada');

      expect(await syncPausado(seguro), isFalse);
    });

    test('exclusão concluída deixa o armazenamento limpo, sem pausa residual', () async {
      await semearLocal();
      await semearNuvem();

      await criar().excluirTodosOsDados(senha: 'certa');

      expect(await syncPausado(seguro), isFalse);
      expect(seguro.dados, isEmpty);
    });

    test('repetir a exclusão depois de uma falha conclui o trabalho', () async {
      await semearLocal();
      await semearNuvem();
      conta.falharAoExcluirConta = true;
      await criar().excluirTodosOsDados(senha: 'certa');

      conta.falharAoExcluirConta = false;
      final r = await criar().excluirTodosOsDados(senha: 'certa');

      expect(r.isRight(), isTrue);
      expect(await docsNaNuvem(), 0);
      expect(await linhasLocais(), 0);
    });

    test('sem usuário logado devolve falha de autenticação', () async {
      conta.uid = null;

      final r = await criar().excluirTodosOsDados(senha: 'certa');

      expect(_falha(r), isA<AuthFailure>());
    });
  });

  test('toda coleção que o SyncEngine usa está na lista apagada pela LGPD', () {
    final fonte = File('lib/features/sync/data/sync_engine.dart').readAsStringSync();
    final usadas = RegExp(r"_colecao\('([a-z_]+)'\)").allMatches(fonte).map((m) => m.group(1)!).toSet();

    expect(usadas, isNotEmpty);
    expect(
      LgpdRemoteDataSource.colecoes.toSet().containsAll(usadas),
      isTrue,
      reason: 'coleção do sync sem exclusão LGPD: ${usadas.difference(LgpdRemoteDataSource.colecoes.toSet())}',
    );
  });
}
