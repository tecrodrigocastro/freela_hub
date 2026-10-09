class EnviarCandidaturaParams {
  int vagaId;
  String mensagem;
  double? valorProposto;

  EnviarCandidaturaParams({
    required this.vagaId,
    required this.mensagem,
    this.valorProposto,
  });

  /// Corpo de `POST /vagas/{id}/candidaturas`; o id vai na URL.
  Map<String, dynamic> toJson() {
    return {
      'mensagem': mensagem.trim(),
      if (valorProposto != null) 'valor_proposto': valorProposto,
    };
  }

  void setMensagem(String value) {
    mensagem = value;
  }

  void setValorProposto(double? value) {
    valorProposto = value;
  }

  static EnviarCandidaturaParams empty() {
    return EnviarCandidaturaParams(vagaId: 0, mensagem: '');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnviarCandidaturaParams && other.vagaId == vagaId && other.mensagem == mensagem && other.valorProposto == valorProposto;
  }

  @override
  int get hashCode => vagaId.hashCode ^ mensagem.hashCode ^ valorProposto.hashCode;

  @override
  String toString() => 'EnviarCandidaturaParams(vagaId: $vagaId, mensagem: $mensagem, valorProposto: $valorProposto)';
}
