import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../providers/qr_providers.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';
import '../widgets/generate_qr_code_body_widget.dart';
import '../widgets/generate_qr_widget.dart';

class GenerateCodeScreen extends ConsumerStatefulWidget {
  final QROption type;
  const GenerateCodeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends ConsumerState<GenerateCodeScreen> {
  /// Map of field name → controller. Created dynamically by the body widget.
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _getController(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
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
        return _controllers['website']?.text.trim() ?? '';
      case QROptionType.whatsapp:
        final number = _controllers['whatsapp']?.text.trim() ?? '';
        return 'https://wa.me/$number';
      case QROptionType.twitter:
        final user = _controllers['twitter']?.text.trim() ?? '';
        return 'https://twitter.com/$user';
      case QROptionType.email:
        return 'mailto:${_controllers['email']?.text.trim() ?? ''}';
      case QROptionType.instagram:
        final user = _controllers['instagram']?.text.trim() ?? '';
        return 'https://instagram.com/$user';
      case QROptionType.telephone:
        return 'tel:${_controllers['telephone']?.text.trim() ?? ''}';
      case QROptionType.wifi:
        final ssid = _controllers['network']?.text.trim() ?? '';
        final pass = _controllers['password']?.text.trim() ?? '';
        return 'WIFI:T:WPA;S:$ssid;P:$pass;;';
      case QROptionType.event:
        final name = _controllers['eventName']?.text.trim() ?? '';
        final start = _controllers['startDate']?.text.trim() ?? '';
        final end = _controllers['endDate']?.text.trim() ?? '';
        final location = _controllers['eventLocation']?.text.trim() ?? '';
        final desc = _controllers['description']?.text.trim() ?? '';
        return 'BEGIN:VEVENT\nSUMMARY:$name\nDTSTART:$start\nDTEND:$end\nLOCATION:$location\nDESCRIPTION:$desc\nEND:VEVENT';
      case QROptionType.contact:
        final first = _controllers['firstName']?.text.trim() ?? '';
        final last = _controllers['lastName']?.text.trim() ?? '';
        final company = _controllers['company']?.text.trim() ?? '';
        final job = _controllers['job']?.text.trim() ?? '';
        final phone = _controllers['phone']?.text.trim() ?? '';
        final email = _controllers['email']?.text.trim() ?? '';
        final web = _controllers['website']?.text.trim() ?? '';
        final addr = _controllers['address']?.text.trim() ?? '';
        final city = _controllers['city']?.text.trim() ?? '';
        final country = _controllers['country']?.text.trim() ?? '';
        return 'BEGIN:VCARD\nVERSION:3.0\nN:$last;$first\nORG:$company\nTITLE:$job\nTEL:$phone\nEMAIL:$email\nURL:$web\nADR:;;$addr;$city;;;$country\nEND:VCARD';
      case QROptionType.business:
        final company = _controllers['company']?.text.trim() ?? '';
        final phone = _controllers['phone']?.text.trim() ?? '';
        final email = _controllers['email']?.text.trim() ?? '';
        final web = _controllers['website']?.text.trim() ?? '';
        final addr = _controllers['address']?.text.trim() ?? '';
        final city = _controllers['city']?.text.trim() ?? '';
        final country = _controllers['country']?.text.trim() ?? '';
        return 'BEGIN:VCARD\nVERSION:3.0\nORG:$company\nTEL:$phone\nEMAIL:$email\nURL:$web\nADR:;;$addr;$city;;;$country\nEND:VCARD';
      case QROptionType.location:
        final lat = _controllers['latitude']?.text.trim() ?? '0';
        final lng = _controllers['longitude']?.text.trim() ?? '0';
        return 'geo:$lat,$lng';
    }
  }

  /// Pick a contact from the phone's address book and fill the form fields.
  Future<void> _importFromContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
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
    final data = _buildQRData();
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).snackbarFillRequiredFields)),
      );
      return;
    }

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
                    color: const Color(0xff3B3B3B).withOpacity(0.78),
                    borderRadius: BorderRadius.circular(6),
                    border: const Border.symmetric(
                      horizontal: BorderSide(
                        color: Color(0xffFDB623),
                        width: 3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff000000).withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
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
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
