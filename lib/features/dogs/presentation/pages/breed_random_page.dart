import 'package:clean_architecture_sample/core/extensions/async_value_extensions.dart';
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
        child: async.whenOrDefault(
            data: (DogImage data) => Image.network(data.url, fit: BoxFit.contain,),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.refresh(breedRandomImageProvider(breed)),
        child: const Icon(Icons.refresh),
      ),
    );
  }

}