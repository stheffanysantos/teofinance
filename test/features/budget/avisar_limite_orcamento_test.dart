import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/usecases/avisar_limite_orcamento_usecase.dart';

class _Espia extends NotificacaoServiceNulo {
  final titulos = <String>[];

  @override
  Future<void> mostrarAgora({required String titulo, required String corpo}) async => titulos.add(titulo);
}

ResumoOrcamento _resumo(double gasto) => ResumoOrcamento([
  EnvelopeOrcamento(orcamento: const Orcamento(id: '1', categoria: 'Mercado', limite: 100), gasto: gasto),
]);

void main() {
  test('avisa aos 80% e ao estourar, uma vez por faixa', () async {
    final espia = _Espia();
    final uc = AvisarLimiteOrcamentoUseCase(espia);

    var avisados = await uc(resumo: _resumo(50), avisados: {});
    expect(espia.titulos, isEmpty);

    avisados = await uc(resumo: _resumo(85), avisados: avisados);
    expect(espia.titulos, hasLength(1));
    expect(avisados['Mercado'], 80);

    avisados = await uc(resumo: _resumo(90), avisados: avisados); // mesma faixa: não repete
    expect(espia.titulos, hasLength(1));

    avisados = await uc(resumo: _resumo(130), avisados: avisados);
    expect(espia.titulos, hasLength(2));
    expect(espia.titulos.last, contains('estourou'));
    expect(avisados['Mercado'], 100);

    await uc(resumo: _resumo(140), avisados: avisados);
    expect(espia.titulos, hasLength(2));
  });

  test('passar direto de 50% para estourado avisa só do estouro', () async {
    final espia = _Espia();
    await AvisarLimiteOrcamentoUseCase(espia)(resumo: _resumo(120), avisados: {});
    expect(espia.titulos.single, contains('estourou'));
  });
}
