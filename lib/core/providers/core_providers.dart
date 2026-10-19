import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../services/notificacao_service.dart';
import '../services/notificacao_service_local.dart';

/// Instância da app Firebase, inicializada em `main.dart` antes de
/// `runApp` e injetada aqui via `overrideWithValue`.
final firebaseAppProvider = Provider<FirebaseApp>((ref) {
  throw UnimplementedError('firebaseAppProvider deve ser sobrescrito em main.dart');
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  ref.watch(firebaseAppProvider);
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  ref.watch(firebaseAppProvider);
  return FirebaseAuth.instance;
});

/// Stream do usuário autenticado — `null` quando deslogado.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Cache local (drift/SQLite), fonte de verdade offline. Ver
/// `.claude/rules/architecture.md` — `sync/` é quem concilia isto com o
/// Firestore, nunca a UI diretamente.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Armazenamento seguro (tokens, chaves locais) — nunca dado financeiro em
/// texto puro fora do drift. Ver `.claude/rules/security.md`.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Notificações locais (lembretes). Nos testes, sobrescreva com
/// `NotificacaoServiceNulo` ou um fake.
final notificacaoServiceProvider = Provider<NotificacaoService>((ref) => NotificacaoServiceLocal());
