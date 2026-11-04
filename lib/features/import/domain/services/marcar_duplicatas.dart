import 'package:teofinance/features/import/domain/entities/transacao_importada.dart';

/// Identidade de um lançamento para achar repetições: dia, centavos e
/// descrição sem diferença de caixa ou espaços. Valor e data iguais com
/// descrição diferente NÃO contam — pode ser outra compra.
String chaveLancamento(DateTime data, double valor, String descricao) {
  final dia = '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  final centavos = (valor * 100).round();
  final texto = descricao.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return '$dia|$centavos|$texto';
}

/// Índices, em [importadas], das linhas que já existem.
///
/// Sem FITID (CSV, ou acervo antigo), a identidade é a chave `dia|centavos|
/// descrição` em [chavesExistentes]. Conta ocorrências em vez de só testar
/// presença: duas compras iguais no mesmo dia são legítimas. Com 1 igual já
/// existente e 2 no arquivo, só uma é duplicata; a outra é nova.
///
/// Com [fitidsExistentes] informado (acervo vindo de OFX), uma linha que traz
/// `fitid` é identificada de forma exata: duplicata só se o FITID já existe.
/// Compras idênticas com FITIDs diferentes nunca se confundem. Para esse caso,
/// [chavesExistentes] deve conter só as chaves de linhas **sem** FITID, que
/// ainda podem ser comparadas pela chave.
Set<int> indicesDuplicados({
  required List<TransacaoImportada> importadas,
  required Iterable<String> chavesExistentes,
  Set<String>? fitidsExistentes,
}) {
  final disponiveis = <String, int>{};
  for (final chave in chavesExistentes) {
    disponiveis.update(chave, (n) => n + 1, ifAbsent: () => 1);
  }

  final duplicados = <int>{};
  for (var i = 0; i < importadas.length; i++) {
    final t = importadas[i];
    final fitid = t.fitid;
    if (fitid != null && fitidsExistentes != null) {
      if (fitidsExistentes.contains(fitid)) {
        duplicados.add(i);
        continue;
      }
    }
    final chave = chaveLancamento(t.data, t.valor, t.descricao);
    final restantes = disponiveis[chave] ?? 0;
    if (restantes > 0) {
      disponiveis[chave] = restantes - 1;
      duplicados.add(i);
    }
  }
  return duplicados;
}
