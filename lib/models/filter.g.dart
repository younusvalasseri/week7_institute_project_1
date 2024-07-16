// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilterAdapter extends TypeAdapter<Filter> {
  @override
  final int typeId = 6;

  @override
  Filter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Filter()
      ..name = fields[0] as String
      ..criteria = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Filter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.criteria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
