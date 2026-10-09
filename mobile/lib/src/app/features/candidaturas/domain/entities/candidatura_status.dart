/// Status da candidatura (docs/DATA-MODEL.md): `enviada | em_analise | aprovada | recusada`.
enum CandidaturaStatus {
  enviada('enviada'),
  emAnalise('em_analise'),
  aprovada('aprovada'),
  recusada('recusada');

  final String apiValue;

  const CandidaturaStatus(this.apiValue);

  static CandidaturaStatus fromApi(String value) => values.firstWhere((s) => s.apiValue == value, orElse: () => enviada);
}
