import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../l10n/app_localizations.dart';
import 'generate_qr_widget.dart';
import 'k_textfield_widget.dart';

/// Callback type for lazily creating/retrieving text controllers by key.
typedef GetController = TextEditingController Function(String key);

class GenerateQRCodeBody extends StatelessWidget {
  final QROption type;
  final GetController getController;
  final VoidCallback? onImportContact;
  const GenerateQRCodeBody({
    super.key,
    required this.type,
    required this.getController,
    this.onImportContact,
  });

  @override
  Widget build(BuildContext context) {
    // return Column();
    switch (type.type) {
      case QROptionType.text:
        return TextBody(controller: getController('text'));
      case QROptionType.website:
        return WebsiteBody(controller: getController('website'));
      case QROptionType.whatsapp:
        return WhatsAppBody(controller: getController('whatsapp'));
      case QROptionType.twitter:
        return TwitterBody(controller: getController('twitter'));
      case QROptionType.email:
        return EmailBody(controller: getController('email'));
      case QROptionType.instagram:
        return InstagramBody(controller: getController('instagram'));
      case QROptionType.telephone:
        return TelephoneBody(controller: getController('telephone'));
      case QROptionType.wifi:
        return WifiBodyTextWidget(
          networkController: getController('network'),
          passwordController: getController('password'),
        );
      case QROptionType.event:
        return EventBodyTextWidget(
          eventNameController: getController('eventName'),
          startDateController: getController('startDate'),
          endDateController: getController('endDate'),
          eventLocationController: getController('eventLocation'),
          descriptionController: getController('description'),
        );
      case QROptionType.contact:
        return ContactBodyTextWidget(
          firstNameController: getController('firstName'),
          lastNameController: getController('lastName'),
          companyController: getController('company'),
          jobController: getController('job'),
          phoneController: getController('phone'),
          emailController: getController('email'),
          websiteController: getController('website'),
          addressController: getController('address'),
          cityController: getController('city'),
          countryController: getController('country'),
          onImportContact: onImportContact,
        );
      case QROptionType.business:
        return BusinessBodyTextWidget(
          companyController: getController('company'),
          phoneController: getController('phone'),
          emailController: getController('email'),
          websiteController: getController('website'),
          addressController: getController('address'),
          cityController: getController('city'),
          countryController: getController('country'),
        );
      case QROptionType.location:
        return LocationBodyTextWidget(
          latitudeController: getController('latitude'),
          longitudeController: getController('longitude'),
        );
    }
  }
}

class TextBody extends StatelessWidget {
  final TextEditingController controller;
  const TextBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).textLabel,
      hintText: AppLocalizations.of(context).textHint,
      controller: controller,
    );
  }
}

class WebsiteBody extends StatelessWidget {
  final TextEditingController controller;
  const WebsiteBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).websiteLabel,
      hintText: AppLocalizations.of(context).websiteHint,
      controller: controller,
    );
  }
}

class WhatsAppBody extends StatelessWidget {
  final TextEditingController controller;
  const WhatsAppBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).whatsappNumberLabel,
      hintText: AppLocalizations.of(context).whatsappNumberHint,
      controller: controller,
    );
  }
}

class TwitterBody extends StatelessWidget {
  final TextEditingController controller;
  const TwitterBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).twitterUsernameLabel,
      hintText: AppLocalizations.of(context).twitterUsernameHint,
      controller: controller,
    );
  }
}

class EmailBody extends StatelessWidget {
  final TextEditingController controller;
  const EmailBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).emailLabel,
      hintText: AppLocalizations.of(context).emailHint,
      controller: controller,
    );
  }
}

class InstagramBody extends StatelessWidget {
  final TextEditingController controller;
  const InstagramBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).instagramUsernameLabel,
      hintText: AppLocalizations.of(context).instagramUsernameHint,
      controller: controller,
    );
  }
}

class TelephoneBody extends StatelessWidget {
  final TextEditingController controller;
  const TelephoneBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context).phoneNumberLabel,
      hintText: AppLocalizations.of(context).phoneNumberHint,
      controller: controller,
    );
  }
}

class OneTextWidget extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  const OneTextWidget({
    super.key,
    required this.labelText,
    required this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: labelText,
          hintText: hintText,
          autoFocus: true,
          controller: controller,
        ),
      ],
    );
  }
}

class WifiBodyTextWidget extends StatefulWidget {
  final TextEditingController networkController;
  final TextEditingController passwordController;
  const WifiBodyTextWidget({
    super.key,
    required this.networkController,
    required this.passwordController,
  });

  @override
  State<WifiBodyTextWidget> createState() => _WifiBodyTextWidgetState();
}

class _WifiBodyTextWidgetState extends State<WifiBodyTextWidget> {
  bool _isLoadingNetworks = false;
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<String?> _getConnectedSsid() async {
    if (kIsWeb) return null;
    try {
      final rawName = await _networkInfo.getWifiName();
      if (rawName == null) return null;

      final normalized = rawName.replaceAll('"', '').trim();
      if (normalized.isEmpty) return null;
      if (normalized.toLowerCase() == '<unknown ssid>' ||
          normalized.toLowerCase() == 'unknown ssid') {
        return null;
      }
      return normalized;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _loadDeviceNetworks() async {
    if (kIsWeb) {
      throw Exception('Wi-Fi scan is not supported on web.');
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is required to scan Wi-Fi.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required to scan Wi-Fi.');
    }

    await WiFiScan.instance.startScan();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final accessPoints = await WiFiScan.instance.getScannedResults();

    final ssids = accessPoints
        .map((ap) => ap.ssid.trim())
        .where((ssid) => ssid.isNotEmpty)
        .toSet()
        .toList()
      ..sort(
          (left, right) => left.toLowerCase().compareTo(right.toLowerCase()));

    return ssids;
  }

  Future<void> _pickWifiFromDevice() async {
    if (_isLoadingNetworks) return;
    setState(() => _isLoadingNetworks = true);

    try {
      final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
      final connectedSsid = await _getConnectedSsid();

      List<String> ssids = [];
      try {
        ssids = await _loadDeviceNetworks();
      } catch (_) {
        if (!isIOS) {
          rethrow;
        }
      }

      if (connectedSsid != null && !ssids.contains(connectedSsid)) {
        ssids = [connectedSsid, ...ssids];
      }

      if (!mounted) return;

      if (ssids.isEmpty) {
        if (isIOS && connectedSsid != null) {
          widget.networkController.text = connectedSsid;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).wifiUsingConnectedNetwork,
              ),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).wifiNoNetworksFound),
          ),
        );
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).wifiPickerTitle,
                  style: const TextStyle(
                    color: Color(0xffFDB623),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ssids.length,
                    itemBuilder: (itemContext, index) {
                      final ssid = ssids[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.wifi, color: Color(0xffFDB623)),
                        title: Text(ssid),
                        subtitle: connectedSsid == ssid
                            ? Text(
                                AppLocalizations.of(context)
                                    .wifiUseConnectedNetwork,
                              )
                            : null,
                        onTap: () {
                          widget.networkController.text = ssid;
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).wifiScanPermissionRequired),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingNetworks = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: AppLocalizations.of(context).networkLabel,
          hintText: AppLocalizations.of(context).networkHint,
          autoFocus: true,
          controller: widget.networkController,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _isLoadingNetworks ? null : _pickWifiFromDevice,
          icon: _isLoadingNetworks
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.wifi_find_rounded),
          label: Text(
            _isLoadingNetworks
                ? AppLocalizations.of(context).wifiLoadingNetworks
                : AppLocalizations.of(context).wifiChooseFromDevice,
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xffFDB623),
            padding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).passwordLabel,
          hintText: AppLocalizations.of(context).passwordHint,
          autoFocus: true,
          controller: widget.passwordController,
        ),
      ],
    );
  }
}

class EventBodyTextWidget extends StatelessWidget {
  final TextEditingController eventNameController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController eventLocationController;
  final TextEditingController descriptionController;
  const EventBodyTextWidget({
    super.key,
    required this.eventNameController,
    required this.startDateController,
    required this.endDateController,
    required this.eventLocationController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: AppLocalizations.of(context).eventNamelabel,
          hintText: AppLocalizations.of(context).eventNameHint,
          autoFocus: true,
          controller: eventNameController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).startDateAndTimeLabel,
          hintText: AppLocalizations.of(context).startDateAndTimeHint,
          autoFocus: true,
          controller: startDateController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).endDateAndTimeLabel,
          hintText: AppLocalizations.of(context).endDateAndTimeHint,
          autoFocus: true,
          controller: endDateController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).eventLocationLabel,
          hintText: AppLocalizations.of(context).eventLocationHint,
          autoFocus: true,
          controller: eventLocationController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).descriptionLabel,
          hintText: AppLocalizations.of(context).descriptionHint,
          autoFocus: true,
          maxLines: 3,
          controller: descriptionController,
        ),
      ],
    );
  }
}

class ContactBodyTextWidget extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController companyController;
  final TextEditingController jobController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final VoidCallback? onImportContact;
  const ContactBodyTextWidget({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.companyController,
    required this.jobController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
    required this.addressController,
    required this.cityController,
    required this.countryController,
    this.onImportContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onImportContact != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onImportContact,
                icon: const Icon(
                  Icons.contacts,
                  color: Color(0xffFDB623),
                  size: 20,
                ),
                label: Text(
                  AppLocalizations.of(context).importFromContacts,
                  style: const TextStyle(
                    color: Color(0xffFDB623),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffFDB623)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context).firstNameLabel,
          firstHint: AppLocalizations.of(context).firstNameHint,
          secondLabel: AppLocalizations.of(context).lastNameLabel,
          secondHint: AppLocalizations.of(context).lastNameHint,
          firstController: firstNameController,
          secondController: lastNameController,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context).companyLabel,
          firstHint: AppLocalizations.of(context).companyHint,
          secondLabel: AppLocalizations.of(context).jobLabel,
          secondHint: AppLocalizations.of(context).jobHint,
          firstController: companyController,
          secondController: jobController,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context).phoneLabel,
          firstHint: AppLocalizations.of(context).phoneHint,
          secondLabel: AppLocalizations.of(context).emailLabel,
          secondHint: AppLocalizations.of(context).emailHint,
          firstController: phoneController,
          secondController: emailController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).websiteLabel,
          hintText: AppLocalizations.of(context).websiteHint,
          autoFocus: true,
          controller: websiteController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).addressLabel,
          hintText: AppLocalizations.of(context).addressHint,
          autoFocus: true,
          controller: addressController,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context).cityLabel,
          firstHint: AppLocalizations.of(context).cityHint,
          secondLabel: AppLocalizations.of(context).countryLabel,
          secondHint: AppLocalizations.of(context).countryHint,
          firstController: cityController,
          secondController: countryController,
        ),
      ],
    );
  }
}

class BusinessBodyTextWidget extends StatelessWidget {
  final TextEditingController companyController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  const BusinessBodyTextWidget({
    super.key,
    required this.companyController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
    required this.addressController,
    required this.cityController,
    required this.countryController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: AppLocalizations.of(context).companyLabel,
          hintText: AppLocalizations.of(context).companyHint,
          autoFocus: true,
          controller: companyController,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context).phoneLabel,
          firstHint: AppLocalizations.of(context).phoneHint,
          secondLabel: AppLocalizations.of(context).emailLabel,
          secondHint: AppLocalizations.of(context).emailHint,
          firstController: phoneController,
          secondController: emailController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).websiteLabel,
          hintText: AppLocalizations.of(context).websiteHint,
          autoFocus: true,
          controller: websiteController,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context).addressLabel,
          hintText: AppLocalizations.of(context).addressHint,
          autoFocus: true,
          controller: addressController,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context).cityLabel,
          firstHint: AppLocalizations.of(context).cityHint,
          secondLabel: AppLocalizations.of(context).companyLabel,
          secondHint: AppLocalizations.of(context).companyHint,
          firstController: cityController,
          secondController: countryController,
        ),
      ],
    );
  }
}

class RowDoubleTextField extends StatelessWidget {
  const RowDoubleTextField({
    super.key,
    required this.context,
    required this.firstLabel,
    required this.firstHint,
    required this.secondLabel,
    required this.secondHint,
    this.firstController,
    this.secondController,
  });

  final BuildContext context;
  final String firstLabel;
  final dynamic firstHint;
  final String secondLabel;
  final dynamic secondHint;
  final TextEditingController? firstController;
  final TextEditingController? secondController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 60,
          child: KTextField(
            labelText: firstLabel,
            hintText: firstHint,
            autoFocus: true,
            controller: firstController,
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 60,
          child: KTextField(
            labelText: secondLabel,
            hintText: secondHint,
            autoFocus: true,
            controller: secondController,
          ),
        ),
      ],
    );
  }
}

class LocationBodyTextWidget extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  const LocationBodyTextWidget({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
  });

  @override
  State<LocationBodyTextWidget> createState() => _LocationBodyTextWidgetState();
}

class _LocationBodyTextWidgetState extends State<LocationBodyTextWidget> {
  bool _isLoadingLocation = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .snackbarLocationPermissionDenied)),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)
                    .snackbarLocationPermissionPermanentlyDenied,
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      widget.latitudeController.text = position.latitude.toString();
      widget.longitudeController.text = position.longitude.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .snackbarFailedToGetLocation(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoadingLocation ? null : _useCurrentLocation,
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: Color(0xffFDB623)),
            label: Text(
              _isLoadingLocation
                  ? 'Getting location...'
                  : 'Use Current Location',
              style: const TextStyle(color: Color(0xffFDB623)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xffFDB623)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 16),
        KTextField(
          labelText: 'Latitude',
          hintText: 'Enter latitude',
          autoFocus: true,
          controller: widget.latitudeController,
        ),
        const SizedBox(height: 20),
        KTextField(
          labelText: 'Longitude',
          hintText: 'Enter longitude',
          autoFocus: true,
          controller: widget.longitudeController,
        ),
      ],
    );
  }
}
