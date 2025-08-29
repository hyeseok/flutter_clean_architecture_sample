import 'package:clean_architecture_sample/core/ui/widgets/common_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/error_mapper.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  /// data 위젯만 받고, loading/ error 는 공통 처리
  Widget whenOrDefault({
   required Widget Function(T data) data,
   Widget? loading,
   Widget Function(String message)? error
  }) {
   return when(
      data: data,
      error: (err, _) {
        final message = ErrorMapper.toFailure(err).message;
        if (error != null) return error(message);

        return Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        );
      },
      loading: () => loading ?? const CommonLoading()
    );
  }
}