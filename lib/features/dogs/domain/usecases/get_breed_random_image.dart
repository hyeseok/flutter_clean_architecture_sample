import 'package:clean_architecture_sample/core/result/result.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';
import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';

class GetBreedRandomImage {
  final DogRepository repo;

  GetBreedRandomImage(this.repo);
  Future<Result<DogImage>> call(String breed) => repo.getBreedRandomImage(breed);
}