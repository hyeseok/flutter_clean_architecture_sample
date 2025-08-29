import 'failures.dart';

sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(Failure) err});
  R fold<R>(R Function(Failure) onErr, R Function(T) onOk) => when(ok: onOk, err: onErr);
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  @override
  R when<R>({required R Function(T p1) ok, required R Function(Failure p1) err}) => ok(value);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);

  @override
  R when<R>({required R Function(T p1) ok, required R Function(Failure p1) err}) => err(failure);
}
