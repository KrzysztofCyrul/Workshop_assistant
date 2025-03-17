class Result<T> {
  final T? value;
  final String? error;

  const Result.success(this.value) : error = null;
  const Result.failure(this.error) : value = null;

  bool get isSuccess => error == null;
  
  void fold(Function(String error) onError, Function(T? success) onSuccess) {
    if (isSuccess) {
      onSuccess(value);
    } else {
      onError(error!);
    }
  }
}