# Checklist — Novo Model

- [ ] `@freezed` + `@JsonSerializable`, `fromJson`/`toJson` gerados (não escritos à mão).
- [ ] `toEntity()`/`fromEntity()` manuais, sem lógica de negócio além de mapeamento de campo.
- [ ] Nome de campo do Firestore documentado em comentário quando diferente do nome da entidade.
- [ ] Nenhum import de `flutter/*`/Riverpod no model (só `freezed`/`json_annotation`/`cloud_firestore` quando necessário para conversão de `Timestamp`).
- [ ] `dart run build_runner build --delete-conflicting-outputs` rodado e `.freezed.dart`/`.g.dart` versionados (ou gerados no CI, conforme `.gitignore` do projeto).
