import 'package:clean_architecture_sample/core/result/result.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';
import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';

class GetRandomImage {
  final DogRepository repo;

  GetRandomImage(this.repo);
  Future<Result<DogImage>> call() => repo.getRandomImage();
}