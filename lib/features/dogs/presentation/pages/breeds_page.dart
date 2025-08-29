import 'package:clean_architecture_sample/core/extensions/async_value_extensions.dart';
import 'package:clean_architecture_sample/core/extensions/result_extensions.dart';
import 'package:clean_architecture_sample/features/dogs/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/dog_providers.dart';

class BreedsPage extends ConsumerWidget {
  const BreedsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(breedsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dog Breeds'),),
      body: async.whenOrDefault(
          data: (res) => res.toWidget(
            ok: (breeds) => ListView.separated(
                itemBuilder: (_, i) {
                  final b = breeds[i];
                  final title = b.subBreeds.isEmpty
                      ? b.name : '${b.name} (${b.subBreeds.length})';

                  return ListTile(
                    title: Text(title),
                    subtitle: b.subBreeds.isEmpty ? null : Text(b.subBreeds.join(', ')),
                    onTap: () => context.push('${DogsRoutes.breedRandom}/${b.name}'),
                  );
                },
                separatorBuilder: (_, _) {
                  return const Divider(height: 1,);
                },
                itemCount: breeds.length
            )
          ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(DogsRoutes.random),
        label: const Text('랜덤 사진'),
        icon: const Icon(Icons.pets),
      ),
    );
  }

}