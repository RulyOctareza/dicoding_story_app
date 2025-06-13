import 'package:json_annotation/json_annotation.dart';

part 'location_data.g.dart';

@JsonSerializable()
class LocationData {
  final double lat;
  final double lon;
  final String address;

  LocationData({
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => 
      _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}
