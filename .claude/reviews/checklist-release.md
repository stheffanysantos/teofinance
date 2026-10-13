# Checklist — Release

- [ ] `dart analyze --fatal-infos` e `flutter test` passando no CI.
- [ ] `firestore.rules` revisadas e testadas via emulador para todas as coleções em uso.
- [ ] Variáveis de ambiente/flavor de produção conferidas (projeto Firebase correto, nunca o de desenvolvimento).
- [ ] Modelo Gemma (se a build inclui IA local): confirmado que é baixado sob demanda, não embutido no instalador, e testado em pelo menos um dispositivo de entrada.
- [ ] Exportação/exclusão de dados (LGPD) testada ponta a ponta.
- [ ] Changelog/notas de versão escritas.
- [ ] `.claude/memory/roadmap-snapshot.md` atualizado se a release fecha uma fase do roadmap.
