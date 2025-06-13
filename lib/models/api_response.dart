import 'package:json_annotation/json_annotation.dart';
import 'story.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool error;
  final String message;
  final T? data;

  ApiResponse({
    required this.error,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class StoriesResponse {
  final List<Story> listStory;

  StoriesResponse({required this.listStory});

  factory StoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$StoriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoriesResponseToJson(this);
}
