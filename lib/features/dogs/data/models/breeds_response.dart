import 'package:clean_architecture_sample/features/dogs/domain/entities/breed.dart';

class BreedsResponse {
  final Map<String, List<String>> message; // {"hound": ["afghan", "basset"]}}

  BreedsResponse(this.message);

  factory BreedsResponse.fromJson(Map<String, dynamic> json) {
    final msg = (json['message'] as Map).map(
        (k, v) => MapEntry(k as String, List<String>.from(v as List)),
    );
    return BreedsResponse(msg);
  }

  List<Breed> toEntities() =>
      message.entries.map((e) => Breed(e.key, e.value)).toList();
}