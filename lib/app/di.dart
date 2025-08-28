import 'package:clean_architecture_sample/core/network/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../features/dogs/di.dart' as dogs_di;

final sl = GetIt.instance;

Future<void> initAppDI() async {
  sl.registerLazySingleton<Dio>(() => makeDio());
  dogs_di.registerDogsModules(sl);
}