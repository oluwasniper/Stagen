import 'qr_payload_sanitizer.dart';

const int _kMaxExternalUriLength = 4096;

final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final RegExp _phoneRegex = RegExp(r'^\+?[0-9][0-9\-\s().]{5,}$');
final RegExp _domainRegex = RegExp(
  r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}([/?#].*)?$',
);
final RegExp _twitterHandleRegex = RegExp(r'^[A-Za-z0-9_]{1,15}$');
final RegExp _instagramHandleRegex = RegExp(r'^[A-Za-z0-9._]{1,30}$');
final RegExp _telegramHandleRegex = RegExp(r'^[A-Za-z0-9_]{5,32}$');
final RegExp _linkedInHandleRegex = RegExp(r'^[A-Za-z0-9_-]{3,100}$');

Uri? tryParseSafeExternalActionUri(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty ||
      trimmed.length > _kMaxExternalUriLength ||
      _containsControlCharacters(trimmed)) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) return null;

  final scheme = uri.scheme.toLowerCase();
  switch (scheme) {
    case 'http':
    case 'https':
      if (!uri.isAbsolute || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
        return null;
      }
      return uri;
    case 'mailto':
      if (uri.userInfo.isNotEmpty || uri.host.isNotEmpty || uri.path.isEmpty) {
        return null;
      }
      return uri;
    case 'tel':
    case 'sms':
    case 'smsto':
    case 'geo':
      if (uri.userInfo.isNotEmpty || uri.host.isNotEmpty) {
        return null;
      }
      if (uri.path.isEmpty && uri.query.isEmpty) {
        return null;
      }
      return uri;
    default:
      return null;
  }
}

String buildWebsiteQrPayload(String raw) {
  final normalized = normalizeSingleLineQrField(raw);
  if (normalized.isEmpty || _containsControlCharacters(normalized)) {
    return '';
  }

  final initialUri = Uri.tryParse(normalized);
  final candidate = initialUri != null && initialUri.hasScheme
      ? normalized
      : 'https://$normalized';
  final uri = tryParseSafeExternalActionUri(candidate);
  if (uri == null) return '';
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return '';
  return uri.toString();
}

String buildWhatsAppQrPayload(String raw) {
  final normalized = normalizeSingleLineQrField(raw);
  if (normalized.isEmpty || _containsControlCharacters(normalized)) return '';

  var digits = '';
  final uri = Uri.tryParse(normalized);
  if (uri != null && uri.hasScheme) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      if (host == 'wa.me' || host.endsWith('.wa.me')) {
        final segment = _firstNonEmptySegment(uri.pathSegments);
        digits = segment?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      } else if (host == 'api.whatsapp.com' || host.endsWith('.whatsapp.com')) {
        digits = (uri.queryParameters['phone'] ?? '')
            .replaceAll(RegExp(r'[^0-9]'), '');
      }
    }
  }
  if (digits.isEmpty) {
    digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
  }
  if (digits.length < 7 || digits.length > 15) return '';
  return Uri.https('wa.me', '/$digits').toString();
}

String buildTwitterQrPayload(String raw) {
  final handle = _extractSocialHandle(
    raw,
    allowedHosts: const {
      'twitter.com',
      'www.twitter.com',
      'x.com',
      'www.x.com',
    },
  );
  if (!_twitterHandleRegex.hasMatch(handle)) return '';
  return Uri.https('twitter.com', '/$handle').toString();
}

String buildInstagramQrPayload(String raw) {
  final handle = _extractSocialHandle(
    raw,
    allowedHosts: const {
      'instagram.com',
      'www.instagram.com',
    },
  );
  if (!_instagramHandleRegex.hasMatch(handle)) return '';
  return Uri.https('instagram.com', '/$handle').toString();
}

String buildMailtoQrPayload(String raw) {
  final email = normalizeSingleLineQrField(raw);
  if (!_emailRegex.hasMatch(email)) return '';
  return Uri(scheme: 'mailto', path: email).toString();
}

String buildTelephoneQrPayload(String raw) {
  final phone = normalizeSingleLineQrField(raw);
  if (!_phoneRegex.hasMatch(phone)) return '';
  return Uri(scheme: 'tel', path: phone).toString();
}

String buildSmsQrPayload({
  required String numberRaw,
  required String messageRaw,
}) {
  final number = normalizeSingleLineQrField(numberRaw);
  final message = normalizeSingleLineQrField(messageRaw);
  if (!_phoneRegex.hasMatch(number)) return '';
  if (message.isEmpty) return 'SMSTO:$number';
  return Uri(
    scheme: 'sms',
    path: number,
    queryParameters: {'body': message},
  ).toString();
}

String buildTelegramQrPayload(String raw) {
  final normalized = normalizeSingleLineQrField(raw);
  if (normalized.isEmpty || _containsControlCharacters(normalized)) return '';

  final uri = Uri.tryParse(normalized);
  if (uri != null && uri.hasScheme) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') ||
        !(host == 't.me' ||
            host == 'www.t.me' ||
            host == 'telegram.me' ||
            host == 'www.telegram.me')) {
      return '';
    }
    final segment = _firstNonEmptySegment(uri.pathSegments);
    if (segment == null || !_telegramHandleRegex.hasMatch(segment)) return '';
    return Uri.https('t.me', '/$segment').toString();
  }

  final handle = _normalizeHandle(normalized);
  if (!_telegramHandleRegex.hasMatch(handle)) return '';
  return Uri.https('t.me', '/$handle').toString();
}

String buildLinkedInQrPayload(String raw) {
  final normalized = normalizeSingleLineQrField(raw);
  if (normalized.isEmpty || _containsControlCharacters(normalized)) return '';

  final uri = Uri.tryParse(normalized);
  if (uri != null && uri.hasScheme) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') ||
        !(host == 'linkedin.com' || host.endsWith('.linkedin.com'))) {
      return '';
    }
    if (uri.pathSegments.length < 2 || uri.pathSegments.first != 'in') {
      return '';
    }
    final handle = uri.pathSegments[1].trim();
    if (!_linkedInHandleRegex.hasMatch(handle)) return '';
    return Uri.https('www.linkedin.com', '/in/$handle').toString();
  }

  final handle = _normalizeHandle(normalized);
  if (!_linkedInHandleRegex.hasMatch(handle)) return '';
  return Uri.https('www.linkedin.com', '/in/$handle').toString();
}

String buildGeoQrPayload({
  required String latitudeRaw,
  required String longitudeRaw,
}) {
  final latitude = double.tryParse(normalizeSingleLineQrField(latitudeRaw));
  final longitude = double.tryParse(normalizeSingleLineQrField(longitudeRaw));
  if (latitude == null ||
      longitude == null ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180) {
    return '';
  }

  return 'geo:${_formatCoordinate(latitude)},${_formatCoordinate(longitude)}';
}

String sanitizeShareFileStem(
  String raw, {
  String fallback = 'qr',
}) {
  final normalized = raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized.isEmpty ? fallback : normalized;
}

bool isLikelyValidWebsiteInput(String raw) {
  final normalized = normalizeSingleLineQrField(raw);
  if (normalized.isEmpty) return false;
  if (_containsControlCharacters(normalized)) return false;
  final uri = Uri.tryParse(normalized);
  if (uri != null && uri.hasScheme) {
    return buildWebsiteQrPayload(normalized).isNotEmpty;
  }
  return _domainRegex.hasMatch(normalized) &&
      buildWebsiteQrPayload(normalized).isNotEmpty;
}

bool isLikelyValidGenericQrInput(String value) {
  return normalizeSingleLineQrField(value).isNotEmpty;
}

bool _containsControlCharacters(String value) {
  return value.contains(RegExp(r'[\x00-\x1F\x7F]'));
}

String _normalizeHandle(String raw) {
  final normalized = normalizeSingleLineQrField(raw);
  return normalized.startsWith('@') ? normalized.substring(1) : normalized;
}

String _extractSocialHandle(String raw, {required Set<String> allowedHosts}) {
  final normalized = normalizeSingleLineQrField(raw);
  final uri = Uri.tryParse(normalized);
  if (uri != null && uri.hasScheme) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    if ((scheme == 'http' || scheme == 'https') &&
        allowedHosts.contains(host)) {
      return _firstNonEmptySegment(uri.pathSegments) ?? '';
    }
  }
  return _normalizeHandle(normalized);
}

String? _firstNonEmptySegment(List<String> segments) {
  for (final segment in segments) {
    if (segment.isNotEmpty) return segment;
  }
  return null;
}

String _formatCoordinate(double value) {
  var formatted = value.toStringAsFixed(6);
  formatted = formatted.replaceFirst(RegExp(r'0+$'), '');
  formatted = formatted.replaceFirst(RegExp(r'\.$'), '');
  return formatted;
}
