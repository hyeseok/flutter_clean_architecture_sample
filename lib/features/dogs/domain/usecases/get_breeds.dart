import 'package:clean_architecture_sample/features/dogs/domain/entities/breed.dart';
import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';

class GetBreeds {
  final DogRepository repo;

  GetBreeds(this.repo);
  Future<List<Breed>> call() => repo.getBreeds();
}