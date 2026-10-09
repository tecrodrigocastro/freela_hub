/// Identifica uma candidatura (detalhe e retirada).
class CandidaturaIdParams {
  int id;

  CandidaturaIdParams({required this.id});

  void setId(int value) {
    id = value;
  }

  static CandidaturaIdParams empty() {
    return CandidaturaIdParams(id: 0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CandidaturaIdParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CandidaturaIdParams(id: $id)';
}
