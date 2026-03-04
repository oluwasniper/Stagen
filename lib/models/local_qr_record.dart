import 'package:hive/hive.dart';

import 'qr_record.dart';

const _unset = Object();

class LocalQRRecord {
  final String localId;
  final String? remoteId;
  final String data;
  final String type;
  final String qrType;
  final String? label;
  final String? userId;
  final DateTime createdAt;
  final bool pendingCreate;
  final bool pendingDelete;

  const LocalQRRecord({
    required this.localId,
    this.remoteId,
    required this.data,
    required this.type,
    required this.qrType,
    this.label,
    this.userId,
    required this.createdAt,
    this.pendingCreate = false,
    this.pendingDelete = false,
  });

  LocalQRRecord copyWith({
    String? localId,
    Object? remoteId = _unset,
    String? data,
    String? type,
    String? qrType,
    Object? label = _unset,
    Object? userId = _unset,
    DateTime? createdAt,
    bool? pendingCreate,
    bool? pendingDelete,
  }) {
    return LocalQRRecord(
      localId: localId ?? this.localId,
      remoteId: identical(remoteId, _unset) ? this.remoteId : remoteId as String?,
      data: data ?? this.data,
      type: type ?? this.type,
      qrType: qrType ?? this.qrType,
      label: identical(label, _unset) ? this.label : label as String?,
      userId: identical(userId, _unset) ? this.userId : userId as String?,
      createdAt: createdAt ?? this.createdAt,
      pendingCreate: pendingCreate ?? this.pendingCreate,
      pendingDelete: pendingDelete ?? this.pendingDelete,
    );
  }

  QRRecord toDisplayRecord() {
    return QRRecord(
      id: localId,
      data: data,
      type: type,
      qrType: qrType,
      label: label,
      userId: userId,
      createdAt: createdAt,
      isPendingSync: pendingCreate || pendingDelete,
    );
  }
}

class LocalQRRecordAdapter extends TypeAdapter<LocalQRRecord> {
  @override
  final int typeId = 17;

  @override
  LocalQRRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalQRRecord(
      localId: fields[0] as String,
      remoteId: fields[1] as String?,
      data: fields[2] as String,
      type: fields[3] as String,
      qrType: fields[4] as String,
      label: fields[5] as String?,
      userId: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      pendingCreate: fields[8] is bool ? fields[8] as bool : false,
      pendingDelete: fields[9] is bool ? fields[9] as bool : false,
    );
  }

  @override
  void write(BinaryWriter writer, LocalQRRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.remoteId)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.qrType)
      ..writeByte(5)
      ..write(obj.label)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.pendingCreate)
      ..writeByte(9)
      ..write(obj.pendingDelete);
  }
}
