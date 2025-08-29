import 'package:clean_architecture_sample/core/result/result.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/breed.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';

abstract class DogRepository {
  Future<Result<List<Breed>>> getBreeds();
  Future<Result<DogImage>> getRandomImage();
  Future<Result<DogImage>> getBreedRandomImage(String breed);
}