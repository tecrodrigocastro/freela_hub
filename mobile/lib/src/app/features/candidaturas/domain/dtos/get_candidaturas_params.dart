class GetCandidaturasParams {
  int page;

  GetCandidaturasParams({this.page = 1});

  Map<String, dynamic> toJson() => {'page': page};

  void setPage(int value) {
    page = value;
  }

  static GetCandidaturasParams empty() {
    return GetCandidaturasParams();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetCandidaturasParams && other.page == page;
  }

  @override
  int get hashCode => page.hashCode;

  @override
  String toString() => 'GetCandidaturasParams(page: $page)';
}
