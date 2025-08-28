import 'package:clean_architecture_sample/features/dogs/domain/entities/breed.dart';
import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';
import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';

import '../datasources/dog_remote_ds.dart';

class DogRepositoryImpl implements DogRepository {
  final DogRemoteDataSource remote;
  DogRepositoryImpl(this.remote);


  @override
  Future<DogImage> getBreedRandomImage(String breed) async => (await remote.fetchBreedRandomImage(breed)).toEntity();

  @override
  Future<List<Breed>> getBreeds() async => (await remote.fetchBreeds()).toEntities();

  @override
  Future<DogImage> getRandomImage() async => (await remote.fetchRandomImage()).toEntity();

}