class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: (json['page'] as num? ?? 1).toInt(),
      limit: (json['limit'] as num? ?? 10).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
      totalPages: (json['totalPages'] as num? ?? 1).toInt(),
    );
  }
}
