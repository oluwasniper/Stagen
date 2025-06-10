import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'history_items.g.dart';

@HiveType(typeId: 0)
enum HistoryItemType {
  @HiveField(0)
  qrCode,
  @HiveField(1)
  transactionId,
  @HiveField(2)
  transactionDate,
  @HiveField(3)
  transactionAmount,
  @HiveField(4)
  transactionStatus,
  @HiveField(5)
  transactionType,
  @HiveField(6)
  transactionCategory,
}

@HiveType(typeId: 1)
class HistoryItem {
  @HiveField(0)
  final HistoryItemType type;

  @HiveField(1)
  final String value;

  @HiveField(2)
  final DateTime date;

  const HistoryItem({
    required this.type,
    required this.value,
    required this.date,
  });
}
