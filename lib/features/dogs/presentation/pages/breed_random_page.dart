import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dog_image.dart';
import '../providers/dog_providers.dart';

class BreedRandomPage extends ConsumerWidget {
  final String breed;
  const BreedRandomPage({super.key, required this.breed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(breedRandomImageProvider(breed));

    return Scaffold(
      appBar: AppBar(title: Text('Random: $breed'),),
      body: Center(
        child: async.when(
            data: (DogImage data) => Image.network(data.url, fit: BoxFit.contain,),
            error: (Object error, StackTrace stackTrace) => Text('오류: $error'),
            loading: () => const CircularProgressIndicator()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.refresh(breedRandomImageProvider(breed)),
        child: const Icon(Icons.refresh),
      ),
    );
  }

}