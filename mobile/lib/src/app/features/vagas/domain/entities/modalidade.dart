/// Modalidade de trabalho (docs/DATA-MODEL.md): `remoto | hibrido | presencial`.
enum Modalidade {
  remoto('remoto', 'Remoto'),
  hibrido('hibrido', 'Híbrido'),
  presencial('presencial', 'Presencial');

  final String apiValue;
  final String label;

  const Modalidade(this.apiValue, this.label);

  static Modalidade fromApi(String value) => values.firstWhere((m) => m.apiValue == value, orElse: () => remoto);
}

/// Como o valor da vaga é cobrado: `fixo | hora`.
enum TipoPagamento {
  fixo('fixo'),
  hora('hora');

  final String apiValue;

  const TipoPagamento(this.apiValue);

  static TipoPagamento fromApi(String value) => values.firstWhere((t) => t.apiValue == value, orElse: () => fixo);
}
