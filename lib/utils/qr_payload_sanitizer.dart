String normalizeSingleLineQrField(String value) {
  return value.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
}

String escapeWifiQrField(String value) {
  return normalizeSingleLineQrField(value)
      .replaceAll('\\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll(':', r'\:');
}

String escapeVCardQrText(String value) {
  final normalized = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  return normalized
      .replaceAll('\\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');
}

String escapeVEventQrText(String value) {
  return escapeVCardQrText(value);
}
