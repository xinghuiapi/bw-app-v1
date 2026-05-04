import 'json_utils.dart';

class PaginatedData<T> {
  final List<T> data;
  final int? total;
  final int? currentPage;
  final int? lastPage;
  final int? perPage;

  const PaginatedData({
    this.data = const [],
    this.total,
    this.currentPage,
    this.lastPage,
    this.perPage,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedData<T>(
      data: jsonList(json['data'], fromJsonT),
      total: jsonInt(json['total']),
      currentPage: jsonInt(json['current_page']),
      lastPage: jsonInt(json['last_page'] ?? json['lastPage']),
      perPage: jsonInt(json['per_page']),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'data': data.map(toJsonT).toList(),
      if (total != null) 'total': total,
      if (currentPage != null) 'current_page': currentPage,
      if (lastPage != null) 'last_page': lastPage,
      if (perPage != null) 'per_page': perPage,
    };
  }
}
