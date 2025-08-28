import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dog_image.dart';
import '../providers/dog_providers.dart';

class RandomPage extends ConsumerWidget {
  const RandomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(randomImageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Random Dog'),),
      body: Center(
        child: async.when(
            data: (DogImage data) => Image.network(data.url, fit: BoxFit.contain,),
            error: (Object error, StackTrace stackTrace) => Text('오류: $error'),
            loading: () => const CircularProgressIndicator()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 1) provider 재요청
          ref.refresh(randomImageProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

}