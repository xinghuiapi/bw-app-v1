class ApiResponse<T> {
  final int code;
  final String? msg;
  final T? data;

  const ApiResponse({required this.code, this.msg, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 0,
      msg: json['msg']?.toString(),
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      if (msg != null) 'msg': msg,
      if (data != null) 'data': toJsonT(data as T),
    };
  }

  bool get isSuccess => code == 200;
}
