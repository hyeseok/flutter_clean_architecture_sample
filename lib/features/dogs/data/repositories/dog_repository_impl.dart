import 'package:clean_architecture_sample/core/result/result.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/breed.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';
import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';

import '../datasources/dog_remote_ds.dart';

class DogRepositoryImpl implements DogRepository {
  final DogRemoteDataSource remote;
  DogRepositoryImpl(this.remote);


  @override
  Future<Result<DogImage>> getBreedRandomImage(String breed) async {
    final result = (await remote.fetchBreedRandomImage(breed)).toEntity();
    return Ok(result);
  }

  @override
  Future<Result<List<Breed>>> getBreeds() async {
    final result = (await remote.fetchBreeds()).toEntities();
    return Ok(result);
  }

  @override
  Future<Result<DogImage>> getRandomImage() async {
    final result = (await remote.fetchRandomImage()).toEntity();
    return Ok(result);
  }

}