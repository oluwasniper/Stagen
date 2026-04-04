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
  final bool isPendingSync;

  QRRecord({
    this.id,
    required this.data,
    required this.type,
    required this.qrType,
    this.label,
    this.userId,
    this.isPendingSync = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from Appwrite document JSON.
  ///
  /// Field lengths are capped to match the Appwrite collection schema so a
  /// tampered or corrupted document cannot produce an oversized [data] string
  /// that would exhaust memory in the QR encoder or exceed the DB column limit.
  factory QRRecord.fromJson(Map<String, dynamic> json) {
    return QRRecord(
      id: json['\$id'] as String?,
      data: _cap(json['data'] as String? ?? '', 4096),
      type: _cap(json['type'] as String? ?? 'generated', 50),
      qrType: _cap(json['qrType'] as String? ?? 'text', 50),
      label: json['label'] != null
          ? _cap(json['label'] as String, 255)
          : null,
      userId: json['userId'] != null
          ? _cap(json['userId'] as String, 255)
          : null,
      isPendingSync: false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static String _cap(String value, int maxLength) =>
      value.length <= maxLength ? value : value.substring(0, maxLength);

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
    bool? isPendingSync,
  }) {
    return QRRecord(
      id: id ?? this.id,
      data: data ?? this.data,
      type: type ?? this.type,
      qrType: qrType ?? this.qrType,
      label: label ?? this.label,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}
