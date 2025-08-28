import 'package:clean_architecture_sample/features/dogs/domain/repositories/dog_repository.dart';
import 'package:clean_architecture_sample/features/dogs/domain/usecases/get_breeds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di.dart';
import '../../domain/entities/breed.dart';
import '../../domain/entities/dog_image.dart';
import '../../domain/usecases/get_breed_random_image.dart';
import '../../domain/usecases/get_random_image.dart';

final getBreedsUsecaseProvider =
    Provider<GetBreeds>((_) => GetBreeds(sl<DogRepository>()));
final getRandomImageUsecaseProvider =
    Provider<GetRandomImage>((_) => GetRandomImage(sl<DogRepository>()));
final getBreedRandomImageUsecaseProvider =
    Provider<GetBreedRandomImage>((_) => GetBreedRandomImage(sl<DogRepository>()));

// 목록
final breedsProvider = FutureProvider<List<Breed>>((ref) async {
  return ref.read(getBreedsUsecaseProvider).call();
});

// 랜덤 이미지
final randomImageProvider = FutureProvider<DogImage>((ref) async {
  return ref.read(getRandomImageUsecaseProvider).call();
});

// 품종별 랜덤 이미지(파라미터)
final breedRandomImageProvider = FutureProvider.family<DogImage, String>((ref, breed) async {
  return ref.read(getBreedRandomImageUsecaseProvider).call(breed);
});