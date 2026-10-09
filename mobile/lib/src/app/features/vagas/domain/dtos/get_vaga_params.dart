class GetVagaParams {
  int id;

  GetVagaParams({required this.id});

  void setId(int value) {
    id = value;
  }

  static GetVagaParams empty() {
    return GetVagaParams(id: 0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetVagaParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GetVagaParams(id: $id)';
}
