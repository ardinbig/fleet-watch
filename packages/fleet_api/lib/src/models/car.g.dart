// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Car _$CarFromJson(Map<String, dynamic> json) => Car(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      status: $enumDecode(_$CarStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$CarToJson(Car instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'speed': instance.speed,
      'status': _$CarStatusEnumMap[instance.status],
    };

const _$CarStatusEnumMap = {
  CarStatus.moving: 'moving',
  CarStatus.parked: 'parked',
  CarStatus.unknown: 'unknown',
};
