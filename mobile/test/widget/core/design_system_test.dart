import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('PrimaryButton dispara onPressed e bloqueia durante loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(PrimaryButton(label: 'Entrar', onPressed: () => taps++)));
    await tester.tap(find.text('Entrar'));
    expect(taps, 1);

    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Entrar', isLoading: true, onPressed: () => taps++)),
    );
    expect(find.text('Entrar'), findsNothing);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
  });

  testWidgets('AppTextField mostra label e erro', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: 'E-mail', errorText: 'Inválido')));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Inválido'), findsOneWidget);
  });

  test('StatusChipType.fromApi mapeia os status da API', () {
    expect(StatusChipType.fromApi('em_analise'), StatusChipType.emAnalise);
    expect(StatusChipType.fromApi('aprovada'), StatusChipType.aprovada);
    expect(StatusChipType.fromApi('recusada'), StatusChipType.recusada);
    expect(StatusChipType.fromApi('enviada'), StatusChipType.enviada);
  });

  testWidgets('VagaCard exibe selo Candidatado e responde ao toque', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(VagaCard(
        titulo: 'Designer UI/UX',
        empresa: 'Sertão Tech',
        categoria: 'Design',
        modalidade: 'Remoto',
        valor: 'R\$ 3.000 – R\$ 5.000',
        prazo: 'Até 30/10',
        jaCandidatou: true,
        onTap: () => tapped = true,
      )),
    );
    expect(find.text('Candidatado'), findsOneWidget);
    await tester.tap(find.text('Designer UI/UX'));
    expect(tapped, isTrue);
  });

  testWidgets('EmptyState e ErrorState renderizam ações', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(Column(children: [
      const EmptyState(title: 'Nenhuma vaga encontrada', message: 'Tente limpar os filtros.'),
      ErrorState(onRetry: () => retried = true),
    ])));
    expect(find.text('Nenhuma vaga encontrada'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(retried, isTrue);
  });
}
