import 'package:clean_architecture_sample/features/dogs/domain/entities/breed.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';

abstract class DogRepository {
  Future<List<Breed>> getBreeds();
  Future<DogImage> getRandomImage();
  Future<DogImage> getBreedRandomImage(String breed);
}