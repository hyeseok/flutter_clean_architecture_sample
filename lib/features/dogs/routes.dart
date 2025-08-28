import 'package:clean_architecture_sample/features/dogs/presentation/pages/breed_random_page.dart';
import 'package:clean_architecture_sample/features/dogs/presentation/pages/breeds_page.dart';
import 'package:clean_architecture_sample/features/dogs/presentation/pages/random_page.dart';
import 'package:go_router/go_router.dart';

class DogsRoutes {
  static const breeds = '/breeds';
  static const random = '/random';
  static const breedRandom = '/breed';

  static final routes = <GoRoute>[
    GoRoute(path: breeds, builder: (_, __) => const BreedsPage()),
    GoRoute(path: random, builder: (_, __) => const RandomPage()),
    GoRoute(
        path: '$breedRandom/:name',
        builder: (_, state) => BreedRandomPage(breed: state.pathParameters['name']!)
    ),
  ];
}