import 'package:clean_architecture_sample/features/dogs/data/models/breeds_response.dart';
import 'package:clean_architecture_sample/features/dogs/data/models/dog_image_dto.dart';
import 'package:dio/dio.dart';

abstract class DogRemoteDataSource {
  Future<BreedsResponse> fetchBreeds();
  Future<DogImageDto> fetchRandomImage();
  Future<DogImageDto> fetchBreedRandomImage(String breed);
}

class DogRemoteDataSourceImpl implements DogRemoteDataSource {
  final Dio dio;
  DogRemoteDataSourceImpl(this.dio);

  @override
  Future<DogImageDto> fetchBreedRandomImage(String breed) async {
    final r = await dio.get('/api/breed/$breed/images/random');
    return DogImageDto.fromJson(r.data as Map<String, dynamic>);
  }

  @override
  Future<BreedsResponse> fetchBreeds() async {
    final r = await dio.get('/api/breeds/list/all');
    return BreedsResponse.fromJson(r.data as Map<String, dynamic>);
  }

  @override
  Future<DogImageDto> fetchRandomImage() async {
    final r = await dio.get('/api/breeds/image/random');
    return DogImageDto.fromJson(r.data as Map<String, dynamic>);
  }
}