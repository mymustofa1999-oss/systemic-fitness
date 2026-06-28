class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;
  final PaginationMeta? meta;

  ApiResponse({this.success = false, this.data, this.message, this.errors, this.meta});
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({required this.page, required this.limit, required this.total, required this.totalPages});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    page: json['page'] ?? 1,
    limit: json['limit'] ?? 20,
    total: json['total'] ?? 0,
    totalPages: json['total_pages'] ?? 0,
  );
}
