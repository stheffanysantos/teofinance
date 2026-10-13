import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opção de importação escolhida em "Traga seus dados" — ver Connect.dc.html.
///
/// MVP (fase 1, `.claude/plans/MVP.md`) só entrega [csv]; [openFinance] fica
/// visível na UI como indicação de roadmap (fase futura), mas sem
/// integração real ainda — ver `.claude/agents/product-manager.md`.
enum ConnectOption { openFinance, csv }

class BankLogo {
  const BankLogo({required this.name, required this.initial, required this.colorValue});

  final String name;
  final String initial;
  final int colorValue;
}

const kSupportedBanks = [
  BankLogo(name: 'Banco Aurora', initial: 'A', colorValue: 0xFF7A3FD0),
  BankLogo(name: 'Norte Bank', initial: 'N', colorValue: 0xFFD9672A),
  BankLogo(name: 'Cedro', initial: 'C', colorValue: 0xFF1F7A5A),
  BankLogo(name: 'Vértice', initial: 'V', colorValue: 0xFF2A64C4),
  BankLogo(name: '+ 40 bancos', initial: '+', colorValue: 0xFF6B7B7E),
];

final connectOptionProvider = NotifierProvider<ConnectOptionNotifier, ConnectOption>(
  ConnectOptionNotifier.new,
);

class ConnectOptionNotifier extends Notifier<ConnectOption> {
  @override
  ConnectOption build() => ConnectOption.openFinance;

  void pick(ConnectOption option) => state = option;
}
