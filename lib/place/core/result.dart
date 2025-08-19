class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.failure(String error) {
    return Result._(error: error, isSuccess: false);
  }

  bool get isFailure => !isSuccess;

  // fold 메소드 구현
  R fold<R>(R Function(String error) onFailure, R Function(T data) onSuccess) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(error!);
    }
  }
}