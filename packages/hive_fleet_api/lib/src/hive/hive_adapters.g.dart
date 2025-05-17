// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class CarAdapter extends TypeAdapter<Car> {
  @override
  final typeId = 0;

  @override
  Car read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Car(
      id: fields[0] as String,
      name: fields[1] as String,
      latitude: (fields[2] as num).toDouble(),
      longitude: (fields[3] as num).toDouble(),
      speed: (fields[4] as num).toDouble(),
      status: fields[5] as CarStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Car obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.speed)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CarStatusAdapter extends TypeAdapter<CarStatus> {
  @override
  final typeId = 1;

  @override
  CarStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CarStatus.moving;
      case 1:
        return CarStatus.parked;
      case 2:
        return CarStatus.unknown;
      default:
        return CarStatus.moving;
    }
  }

  @override
  void write(BinaryWriter writer, CarStatus obj) {
    switch (obj) {
      case CarStatus.moving:
        writer.writeByte(0);
      case CarStatus.parked:
        writer.writeByte(1);
      case CarStatus.unknown:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
