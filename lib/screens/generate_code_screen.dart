import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../providers/qr_providers.dart';
import '../services/telemetry_service.dart';
import '../utils/app_motion.dart';
import '../utils/app_router.dart';
import '../utils/qr_link_utils.dart';
import '../utils/qr_payload_sanitizer.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';
import '../widgets/generate_qr_code_body_widget.dart';
import '../widgets/generate_qr_widget.dart';

class GenerateCodeScreen extends ConsumerStatefulWidget {
  final QROption type;
  final Map<String, String>? initialValues;
  const GenerateCodeScreen({
    super.key,
    required this.type,
    this.initialValues,
  });

  @override
  ConsumerState<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends ConsumerState<GenerateCodeScreen> {
  static final RegExp _phoneValidationRegex =
      RegExp(r'^\+?[0-9][0-9\-\s().]{5,}$');

  /// Map of field name → controller. Created dynamically by the body widget.
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _getController(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  @override
  void initState() {
    super.initState();
    final values = widget.initialValues;
    if (values == null || values.isEmpty) return;
    for (final entry in values.entries) {
      _getController(entry.key).text = entry.value;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Build the QR data string from the user input based on the QR type.
  String _buildQRData() {
    switch (widget.type.type) {
      case QROptionType.text:
        return _controllers['text']?.text.trim() ?? '';
      case QROptionType.website:
        return buildWebsiteQrPayload(
          _controllers['website']?.text ?? '',
        );
      case QROptionType.whatsapp:
        return buildWhatsAppQrPayload(_controllers['whatsapp']?.text ?? '');
      case QROptionType.twitter:
        return buildTwitterQrPayload(_controllers['twitter']?.text ?? '');
      case QROptionType.email:
        return buildMailtoQrPayload(_controllers['email']?.text ?? '');
      case QROptionType.instagram:
        return buildInstagramQrPayload(_controllers['instagram']?.text ?? '');
      case QROptionType.telephone:
        return buildTelephoneQrPayload(_controllers['telephone']?.text ?? '');
      case QROptionType.sms:
        return buildSmsQrPayload(
          numberRaw: _controllers['smsNumber']?.text ?? '',
          messageRaw: _controllers['smsMessage']?.text ?? '',
        );
      case QROptionType.telegram:
        return buildTelegramQrPayload(_controllers['telegram']?.text ?? '');
      case QROptionType.linkedin:
        return buildLinkedInQrPayload(_controllers['linkedin']?.text ?? '');
      case QROptionType.wifi:
        final ssid = escapeWifiQrField(
          _controllers['network']?.text.trim() ?? '',
        );
        final pass = escapeWifiQrField(
          _controllers['password']?.text.trim() ?? '',
        );
        return 'WIFI:T:WPA;S:$ssid;P:$pass;;';
      case QROptionType.event:
        final name = escapeVEventQrText(
          _controllers['eventName']?.text.trim() ?? '',
        );
        final start = normalizeSingleLineQrField(
          _controllers['startDate']?.text.trim() ?? '',
        );
        final end = normalizeSingleLineQrField(
          _controllers['endDate']?.text.trim() ?? '',
        );
        final location = escapeVEventQrText(
          _controllers['eventLocation']?.text.trim() ?? '',
        );
        final desc = escapeVEventQrText(
          _controllers['description']?.text.trim() ?? '',
        );
        return 'BEGIN:VEVENT\nSUMMARY:$name\nDTSTART:$start\nDTEND:$end\nLOCATION:$location\nDESCRIPTION:$desc\nEND:VEVENT';
      case QROptionType.contact:
        final first = escapeVCardQrText(
          _controllers['firstName']?.text.trim() ?? '',
        );
        final last = escapeVCardQrText(
          _controllers['lastName']?.text.trim() ?? '',
        );
        final company = escapeVCardQrText(
          _controllers['company']?.text.trim() ?? '',
        );
        final job = escapeVCardQrText(
          _controllers['job']?.text.trim() ?? '',
        );
        final phone = escapeVCardQrText(
          normalizeSingleLineQrField(_controllers['phone']?.text.trim() ?? ''),
        );
        final email = escapeVCardQrText(
          normalizeSingleLineQrField(_controllers['email']?.text.trim() ?? ''),
        );
        final web = escapeVCardQrText(
          normalizeSingleLineQrField(
            _controllers['website']?.text.trim() ?? '',
          ),
        );
        final addr = escapeVCardQrText(
          _controllers['address']?.text.trim() ?? '',
        );
        final city = escapeVCardQrText(
          _controllers['city']?.text.trim() ?? '',
        );
        final country = escapeVCardQrText(
          _controllers['country']?.text.trim() ?? '',
        );
        return 'BEGIN:VCARD\nVERSION:3.0\nN:$last;$first\nORG:$company\nTITLE:$job\nTEL:$phone\nEMAIL:$email\nURL:$web\nADR:;;$addr;$city;;;$country\nEND:VCARD';
      case QROptionType.business:
        final company = escapeVCardQrText(
          _controllers['company']?.text.trim() ?? '',
        );
        final phone = escapeVCardQrText(
          normalizeSingleLineQrField(_controllers['phone']?.text.trim() ?? ''),
        );
        final email = escapeVCardQrText(
          normalizeSingleLineQrField(_controllers['email']?.text.trim() ?? ''),
        );
        final web = escapeVCardQrText(
          normalizeSingleLineQrField(
            _controllers['website']?.text.trim() ?? '',
          ),
        );
        final addr = escapeVCardQrText(
          _controllers['address']?.text.trim() ?? '',
        );
        final city = escapeVCardQrText(
          _controllers['city']?.text.trim() ?? '',
        );
        final country = escapeVCardQrText(
          _controllers['country']?.text.trim() ?? '',
        );
        return 'BEGIN:VCARD\nVERSION:3.0\nORG:$company\nTEL:$phone\nEMAIL:$email\nURL:$web\nADR:;;$addr;$city;;;$country\nEND:VCARD';
      case QROptionType.location:
        return buildGeoQrPayload(
          latitudeRaw: _controllers['latitude']?.text ?? '',
          longitudeRaw: _controllers['longitude']?.text ?? '',
        );
    }
  }

  String? _validateInput() {
    final l10n = AppLocalizations.of(context);
    switch (widget.type.type) {
      case QROptionType.website:
        final website = _controllers['website']?.text.trim() ?? '';
        if (website.isEmpty) return null;
        if (!isLikelyValidWebsiteInput(website)) {
          return l10n.validationInvalidInput;
        }
        return null;
      case QROptionType.whatsapp:
        final value = _controllers['whatsapp']?.text.trim() ?? '';
        if (value.isEmpty) return null;
        if (buildWhatsAppQrPayload(value).isEmpty) {
          return l10n.validationInvalidInput;
        }
        return null;
      case QROptionType.twitter:
        final value = _controllers['twitter']?.text.trim() ?? '';
        if (value.isEmpty) return null;
        if (buildTwitterQrPayload(value).isEmpty) {
          return l10n.validationInvalidInput;
        }
        return null;
      case QROptionType.email:
        final email = _controllers['email']?.text.trim() ?? '';
        if (email.isEmpty) return null;
        if (buildMailtoQrPayload(email).isEmpty) {
          return l10n.authEmailInvalid;
        }
        return null;
      case QROptionType.instagram:
        final value = _controllers['instagram']?.text.trim() ?? '';
        if (value.isEmpty) return null;
        if (buildInstagramQrPayload(value).isEmpty) {
          return l10n.validationInvalidInput;
        }
        return null;
      case QROptionType.telephone:
        final phone = _controllers['telephone']?.text.trim() ?? '';
        if (phone.isEmpty) return null;
        if (buildTelephoneQrPayload(phone).isEmpty) {
          return l10n.validationInvalidInput;
        }
        return null;
      case QROptionType.sms:
        final number = _controllers['smsNumber']?.text.trim() ?? '';
        if (number.isEmpty) {
          return l10n.validationSmsNumberRequired;
        }
        if (!_phoneValidationRegex.hasMatch(number)) {
          return l10n.validationSmsNumberInvalid;
        }
        return null;
      case QROptionType.telegram:
        final telegram = _controllers['telegram']?.text.trim() ?? '';
        if (telegram.isEmpty) {
          return l10n.validationTelegramRequired;
        }
        if (buildTelegramQrPayload(telegram).isEmpty) {
          return l10n.validationTelegramInvalid;
        }
        return null;
      case QROptionType.linkedin:
        final linkedIn = _controllers['linkedin']?.text.trim() ?? '';
        if (linkedIn.isEmpty) {
          return l10n.validationLinkedinRequired;
        }
        if (buildLinkedInQrPayload(linkedIn).isEmpty) {
          return l10n.validationLinkedinInvalid;
        }
        return null;
      case QROptionType.location:
        final latitude = _controllers['latitude']?.text.trim() ?? '';
        final longitude = _controllers['longitude']?.text.trim() ?? '';
        if (latitude.isEmpty && longitude.isEmpty) return null;
        if (buildGeoQrPayload(
          latitudeRaw: latitude,
          longitudeRaw: longitude,
        ).isEmpty) {
          return l10n.validationInvalidInput;
        }
        return null;
      default:
        return null;
    }
  }

  /// Pick a contact from the phone's address book and fill the form fields.
  Future<void> _importFromContacts() async {
    ref
        .read(telemetryServiceProvider)
        .track(TelemetryEvents.contactImportRequested);
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      ref
          .read(telemetryServiceProvider)
          .track(TelemetryEvents.contactImportDenied);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).contactPermissionDenied,
            ),
          ),
        );
      }
      return;
    }

    final contact = await FlutterContacts.openExternalPick();
    if (contact == null) return;

    // Re-fetch full contact details (the picker only returns minimal info).
    final fullContact = await FlutterContacts.getContact(
      contact.id,
      withProperties: true,
      withAccounts: false,
      withPhoto: false,
      withThumbnail: false,
      withGroups: false,
    );
    if (fullContact == null) return;
    ref
        .read(telemetryServiceProvider)
        .track(TelemetryEvents.contactImportSuccess);

    // Populate form controllers with the imported data.
    _getController('firstName').text = fullContact.name.first;
    _getController('lastName').text = fullContact.name.last;

    if (fullContact.organizations.isNotEmpty) {
      _getController('company').text = fullContact.organizations.first.company;
      _getController('job').text = fullContact.organizations.first.title;
    }

    if (fullContact.phones.isNotEmpty) {
      _getController('phone').text = fullContact.phones.first.number;
    }

    if (fullContact.emails.isNotEmpty) {
      _getController('email').text = fullContact.emails.first.address;
    }

    if (fullContact.websites.isNotEmpty) {
      _getController('website').text = fullContact.websites.first.url;
    }

    if (fullContact.addresses.isNotEmpty) {
      final addr = fullContact.addresses.first;
      _getController('address').text = addr.street;
      _getController('city').text = addr.city;
      _getController('country').text = addr.country;
    }
  }

  void _onGenerate() {
    final validationError = _validateInput();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final data = _buildQRData();
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).snackbarFillRequiredFields)),
      );
      return;
    }

    AppHaptics.medium(context);
    AppSounds.click();

    ref.read(telemetryServiceProvider).track(
      TelemetryEvents.qrGenerated,
      properties: {'qr_type': widget.type.type.name},
    );

    // Save to providers for display in GeneratedQRScreen
    ref.read(generatedQRDataProvider.notifier).state = data;
    ref.read(generatedQRLabelProvider.notifier).state = widget.type.label;
    ref.read(generatedQRTypeProvider.notifier).state = widget.type.type.name;

    // Save to Appwrite via the generated history provider
    final record = QRRecord(
      data: data,
      type: 'generated',
      qrType: widget.type.type.name,
      label: widget.type.label,
    );
    ref.read(generatedHistoryProvider.notifier).addRecord(record);

    // Navigate to the generated QR screen
    AppGoRouter.router.push(AppPath.generatedQRResult);
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);

    return BackgroundScreenWidget(
      screenTitle: widget.type.label,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff3B3B3B).withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(6),
                    border: const Border.symmetric(
                      horizontal: BorderSide(
                        color: Color(0xffFDB623),
                        width: 3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff000000).withValues(alpha: 0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Hero(
                          tag: 'qr_icon_${widget.type.type.name}',
                          child: SvgPicture.asset(
                            widget.type.svgData,
                            colorFilter: const ColorFilter.mode(
                              Color(0xffFDB623),
                              BlendMode.srcIn,
                            ),
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GenerateQRCodeBody(
                          type: widget.type,
                          getController: _getController,
                          onImportContact:
                              widget.type.type == QROptionType.contact
                                  ? _importFromContacts
                                  : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ElevatedButton(
                          onPressed: _onGenerate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFDB623),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            // 'Generate QR Code',
                            AppLocalizations.of(context).generateQRCodeBtn,
                            style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: motion.duration(AppMotion.slow))
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: motion.duration(AppMotion.slow),
                    curve: motion.curve(AppMotion.enter),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
