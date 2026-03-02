// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 1;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      type: fields[0] as HistoryItemType,
      value: fields[1] as String,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HistoryItemTypeAdapter extends TypeAdapter<HistoryItemType> {
  @override
  final int typeId = 0;

  @override
  HistoryItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HistoryItemType.qrCode;
      case 1:
        return HistoryItemType.transactionId;
      case 2:
        return HistoryItemType.transactionDate;
      case 3:
        return HistoryItemType.transactionAmount;
      case 4:
        return HistoryItemType.transactionStatus;
      case 5:
        return HistoryItemType.transactionType;
      case 6:
        return HistoryItemType.transactionCategory;
      default:
        return HistoryItemType.qrCode;
    }
  }

  @override
  void write(BinaryWriter writer, HistoryItemType obj) {
    switch (obj) {
      case HistoryItemType.qrCode:
        writer.writeByte(0);
        break;
      case HistoryItemType.transactionId:
        writer.writeByte(1);
        break;
      case HistoryItemType.transactionDate:
        writer.writeByte(2);
        break;
      case HistoryItemType.transactionAmount:
        writer.writeByte(3);
        break;
      case HistoryItemType.transactionStatus:
        writer.writeByte(4);
        break;
      case HistoryItemType.transactionType:
        writer.writeByte(5);
        break;
      case HistoryItemType.transactionCategory:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
