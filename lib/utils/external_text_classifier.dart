import '../widgets/generate_qr_widget.dart';

class ClassifiedExternalText {
  final QROptionType type;
  final Map<String, String> prefill;

  const ClassifiedExternalText({
    required this.type,
    required this.prefill,
  });
}

/// Maximum byte length accepted by the classifier.
///
/// QR codes can encode at most ~3 KB of binary data (version 40, 8-bit mode).
/// 8 KB is a generous ceiling that prevents ReDoS / memory exhaustion from
/// artificially large payloads injected via other code paths (e.g. deep links).
const _kMaxInputBytes = 8192;

ClassifiedExternalText classifyExternalText(String input) {
  // Reject oversized payloads before any regex work.
  if (input.length > _kMaxInputBytes) {
    return ClassifiedExternalText(
      type: QROptionType.text,
      prefill: {'text': input.substring(0, _kMaxInputBytes)},
    );
  }

  final text = input.trim();
  final lower = text.toLowerCase();

  if (lower.startsWith('wifi:')) {
    final ssid = _extractWifiValue(text, 'S');
    final password = _extractWifiValue(text, 'P');
    return ClassifiedExternalText(
      type: QROptionType.wifi,
      prefill: {
        if (ssid != null) 'network': ssid,
        if (password != null) 'password': password,
      },
    );
  }

  if (lower.startsWith('begin:vcard')) {
    return ClassifiedExternalText(
      type: QROptionType.contact,
      prefill: _parseVCard(text),
    );
  }

  if (lower.startsWith('begin:vevent')) {
    return ClassifiedExternalText(
      type: QROptionType.event,
      prefill: _parseVEvent(text),
    );
  }

  if (lower.startsWith('smsto:') || lower.startsWith('sms:')) {
    final payload = _parseSmsPayload(text);
    return ClassifiedExternalText(
      type: QROptionType.sms,
      prefill: payload,
    );
  }

  final uri = Uri.tryParse(text);
  if (uri != null && uri.hasScheme) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'mailto') {
      return ClassifiedExternalText(
        type: QROptionType.email,
        prefill: {'email': uri.path},
      );
    }
    if (scheme == 'tel') {
      return ClassifiedExternalText(
        type: QROptionType.telephone,
        prefill: {'telephone': uri.path},
      );
    }
    if (scheme == 'geo') {
      final coords = uri.path.split(',');
      return ClassifiedExternalText(
        type: QROptionType.location,
        prefill: {
          if (coords.isNotEmpty) 'latitude': coords[0],
          if (coords.length > 1) 'longitude': coords[1],
        },
      );
    }
    if (scheme == 'sms' || scheme == 'smsto') {
      return ClassifiedExternalText(
        type: QROptionType.sms,
        prefill: {
          if (uri.path.isNotEmpty) 'smsNumber': uri.path,
          if (uri.queryParameters['body']?.isNotEmpty == true)
            'smsMessage': uri.queryParameters['body']!,
        },
      );
    }
    if (scheme == 'http' || scheme == 'https') {
      final host = uri.host.toLowerCase();
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if ((host == 'wa.me' || host.endsWith('.wa.me')) &&
          pathSegments.isNotEmpty) {
        return ClassifiedExternalText(
          type: QROptionType.whatsapp,
          prefill: {'whatsapp': pathSegments.first},
        );
      }
      if ((host == 'twitter.com' ||
              host.endsWith('.twitter.com') ||
              host == 'x.com' ||
              host.endsWith('.x.com')) &&
          pathSegments.isNotEmpty) {
        return ClassifiedExternalText(
          type: QROptionType.twitter,
          prefill: {'twitter': pathSegments.first},
        );
      }
      if ((host == 'instagram.com' || host.endsWith('.instagram.com')) &&
          pathSegments.isNotEmpty) {
        return ClassifiedExternalText(
          type: QROptionType.instagram,
          prefill: {'instagram': pathSegments.first},
        );
      }
      if ((host == 't.me' ||
              host.endsWith('.t.me') ||
              host == 'telegram.me' ||
              host.endsWith('.telegram.me')) &&
          pathSegments.isNotEmpty) {
        return ClassifiedExternalText(
          type: QROptionType.telegram,
          prefill: {'telegram': pathSegments.first},
        );
      }
      if ((host == 'linkedin.com' || host.endsWith('.linkedin.com')) &&
          pathSegments.length >= 2) {
        final root = pathSegments.first.toLowerCase();
        if (root == 'in' || root == 'pub') {
          final handle = pathSegments[1].trim();
          if (handle.isNotEmpty) {
            return ClassifiedExternalText(
              type: QROptionType.linkedin,
              prefill: {'linkedin': handle},
            );
          }
        }
      }
      return ClassifiedExternalText(
        type: QROptionType.website,
        prefill: {'website': text},
      );
    }
  }

  if (_emailRegex.hasMatch(text)) {
    return ClassifiedExternalText(
      type: QROptionType.email,
      prefill: {'email': text},
    );
  }

  if (_phoneRegex.hasMatch(text)) {
    return ClassifiedExternalText(
      type: QROptionType.telephone,
      prefill: {'telephone': text},
    );
  }

  final telegramMatch = _telegramRegex.firstMatch(text);
  if (telegramMatch != null) {
    return ClassifiedExternalText(
      type: QROptionType.telegram,
      prefill: {'telegram': telegramMatch.group(1) ?? ''},
    );
  }

  final linkedInMatch = _linkedInRegex.firstMatch(text);
  if (linkedInMatch != null) {
    return ClassifiedExternalText(
      type: QROptionType.linkedin,
      prefill: {'linkedin': linkedInMatch.group(1) ?? ''},
    );
  }

  final coordMatch = _coordRegex.firstMatch(text);
  if (coordMatch != null) {
    return ClassifiedExternalText(
      type: QROptionType.location,
      prefill: {
        'latitude': coordMatch.group(1) ?? '',
        'longitude': coordMatch.group(2) ?? '',
      },
    );
  }

  if (_domainRegex.hasMatch(text)) {
    return ClassifiedExternalText(
      type: QROptionType.website,
      prefill: {'website': text},
    );
  }

  return ClassifiedExternalText(
    type: QROptionType.text,
    prefill: {'text': text},
  );
}

Map<String, String> _parseSmsPayload(String input) {
  final normalized = input.trim();
  final withoutScheme = normalized.replaceFirst(
    RegExp(r'^sms(to)?:', caseSensitive: false),
    '',
  );
  final colonIndex = withoutScheme.indexOf(':');

  String number = '';
  String message = '';
  String queryPart = '';

  if (colonIndex != -1) {
    number = withoutScheme.substring(0, colonIndex);
    message = withoutScheme.substring(colonIndex + 1);
  } else {
    final bodySeparator = withoutScheme.indexOf('?');
    final mainPart = bodySeparator == -1
        ? withoutScheme
        : withoutScheme.substring(0, bodySeparator);
    queryPart =
        bodySeparator == -1 ? '' : withoutScheme.substring(bodySeparator + 1);
    number = mainPart;
  }

  if (queryPart.isNotEmpty) {
    final qp = Uri.splitQueryString(queryPart);
    if ((qp['body'] ?? '').trim().isNotEmpty) {
      message = qp['body']!.trim();
    }
  }

  return {
    if (number.trim().isNotEmpty) 'smsNumber': number.trim(),
    if (message.trim().isNotEmpty) 'smsMessage': message.trim(),
  };
}

String? _extractWifiValue(String source, String key) {
  // Match values that may contain backslash-escaped characters (including \;).
  final escapedKey = RegExp.escape(key);
  final match = RegExp(
    '$escapedKey:((?:\\\\.|[^;])*)',
    caseSensitive: false,
  ).firstMatch(source);
  final raw = match?.group(1);
  if (raw == null) return null;
  // Unescape backslash-escaped characters (e.g. \; → ;, \\ → \).
  final value = raw.replaceAllMapped(RegExp(r'\\(.)'), (m) => m.group(1)!);
  return value.isEmpty ? null : value;
}

Map<String, String> _parseVCard(String vcard) {
  final fields = <String, String>{};
  final lines = vcard.split(RegExp(r'\r?\n')).take(200).toList();

  final n = _lineValue(lines, 'N');
  if (n != null) {
    final parts = n.split(';');
    if (parts.isNotEmpty) fields['lastName'] = parts.first;
    if (parts.length > 1) fields['firstName'] = parts[1];
  }
  final org = _lineValue(lines, 'ORG');
  final title = _lineValue(lines, 'TITLE');
  final tel = _lineValue(lines, 'TEL');
  final email = _lineValue(lines, 'EMAIL');
  final url = _lineValue(lines, 'URL');
  final adr = _lineValue(lines, 'ADR');

  if (org != null) fields['company'] = org;
  if (title != null) fields['job'] = title;
  if (tel != null) fields['phone'] = tel;
  if (email != null) fields['email'] = email;
  if (url != null) fields['website'] = url;

  if (adr != null) {
    final parts = adr.split(';');
    if (parts.length > 2) fields['address'] = parts[2];
    if (parts.length > 3) fields['city'] = parts[3];
    if (parts.length > 6) fields['country'] = parts[6];
  }
  return fields;
}

Map<String, String> _parseVEvent(String vevent) {
  final lines = vevent.split(RegExp(r'\r?\n')).take(200).toList();
  final fields = <String, String>{};

  final summary = _lineValue(lines, 'SUMMARY');
  final dtStart = _lineValue(lines, 'DTSTART');
  final dtEnd = _lineValue(lines, 'DTEND');
  final location = _lineValue(lines, 'LOCATION');
  final description = _lineValue(lines, 'DESCRIPTION');

  if (summary != null) fields['eventName'] = summary;
  if (dtStart != null) fields['startDate'] = dtStart;
  if (dtEnd != null) fields['endDate'] = dtEnd;
  if (location != null) fields['eventLocation'] = location;
  if (description != null) fields['description'] = description;

  return fields;
}

String? _lineValue(List<String> lines, String key) {
  for (final line in lines) {
    final normalized = line.trim();
    if (normalized.toUpperCase().startsWith('$key:')) {
      return normalized.substring(key.length + 1).trim();
    }
    if (normalized.toUpperCase().startsWith('$key;')) {
      final idx = normalized.indexOf(':');
      if (idx != -1 && idx + 1 < normalized.length) {
        return normalized.substring(idx + 1).trim();
      }
    }
  }
  return null;
}

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phoneRegex = RegExp(r'^\+?[0-9][0-9\-\s().]{5,}$');
final _domainRegex = RegExp(r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}([/?#].*)?$');
final _telegramRegex = RegExp(
  r'^(?:https?://)?(?:t\.me|telegram\.me)/([A-Za-z0-9_]{3,})/?$',
  caseSensitive: false,
);
final _linkedInRegex = RegExp(
  r'^(?:https?://)?(?:[a-z]+\.)?linkedin\.com/(?:in|pub)/([A-Za-z0-9_-]+)/?$',
  caseSensitive: false,
);
final _coordRegex = RegExp(
  r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
);
