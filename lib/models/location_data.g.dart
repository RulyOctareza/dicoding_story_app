// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  address: json['address'] as String,
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'address': instance.address,
    };
