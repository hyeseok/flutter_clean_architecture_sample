import 'package:clean_architecture_sample/core/result/result.dart';
import 'package:flutter/material.dart';

import '../result/failures.dart';

extension ResultX<T> on Result<T> {
  R whenOr<R>({
    required R Function(T) ok,
    required R Function(Failure) err
  }) => when(ok: ok, err: err);

  Widget toWidget({
    required Widget Function(T) ok,
    Widget Function(Failure)? err
  }) {
    return when(
      ok: ok,
      err: (f) => err?.call(f) ?? Center(child: Text(f.message),)
    );
  }
}