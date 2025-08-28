import 'package:clean_architecture_sample/features/dogs/domain/entities/dog_image.dart';

class DogImageDto {
  final String url; // json['message']

  DogImageDto(this.url);

  factory DogImageDto.fromJson(Map<String, dynamic> json) =>
      DogImageDto(json['message'] as String);

  DogImage toEntity() => DogImage(url);
}