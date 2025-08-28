import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/dog_remote_ds.dart';
import 'data/repositories/dog_repository_impl.dart';

void registerDogsModules(GetIt sl) {
  sl.registerLazySingleton<DogRemoteDataSource>(() => DogRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<DogRepository>(() => DogRepositoryImpl(sl<DogRemoteDataSource>()));
}