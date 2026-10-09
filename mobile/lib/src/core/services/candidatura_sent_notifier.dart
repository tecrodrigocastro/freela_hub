import 'dart:async';

/// Avisa o app inteiro que uma candidatura foi enviada (id da vaga), para a
/// lista de vagas marcar "Candidatado" sem recarregar. Sem dependência de feature.
class CandidaturaSentNotifier {
  final StreamController<int> _controller = StreamController<int>.broadcast();

  Stream<int> get onSent => _controller.stream;

  void notify(int vagaId) => _controller.add(vagaId);
}
