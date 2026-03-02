/// Data model representing a QR code record (either scanned or generated).
///
/// Maps to an Appwrite document in the `qr_records` collection.
class QRRecord {
  final String? id;
  final String data;
  final String type; // 'scanned' or 'generated'
  final String qrType; // e.g. 'text', 'website', 'wifi', etc.
  final String? label;
  final String? userId;
  final DateTime createdAt;

  QRRecord({
    this.id,
    required this.data,
    required this.type,
    required this.qrType,
    this.label,
    this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from Appwrite document JSON.
  factory QRRecord.fromJson(Map<String, dynamic> json) {
    return QRRecord(
      id: json['\$id'] as String?,
      data: json['data'] as String? ?? '',
      type: json['type'] as String? ?? 'generated',
      qrType: json['qrType'] as String? ?? 'text',
      label: json['label'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Appwrite document creation.
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'type': type,
      'qrType': qrType,
      'label': label,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  QRRecord copyWith({
    String? id,
    String? data,
    String? type,
    String? qrType,
    String? label,
    String? userId,
    DateTime? createdAt,
  }) {
    return QRRecord(
      id: id ?? this.id,
      data: data ?? this.data,
      type: type ?? this.type,
      qrType: qrType ?? this.qrType,
      label: label ?? this.label,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
