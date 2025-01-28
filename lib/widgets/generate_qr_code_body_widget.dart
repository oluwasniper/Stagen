import 'package:flutter/material.dart';
import 'generate_qr_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'k_textfield_widget.dart';

class GenerateQRCodeBody extends StatelessWidget {
  final QROption type;
  const GenerateQRCodeBody({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // return Column();
    switch (type.type) {
      case QROptionType.text:
        return TextBody();
      case QROptionType.website:
        return WebsiteBody();
      case QROptionType.whatsapp:
        return WhatsAppBody();
      case QROptionType.twitter:
        return TwitterBody();
      case QROptionType.email:
        return EmailBody();
      case QROptionType.instagram:
        return InstagramBody();
      case QROptionType.telephone:
        return TelephoneBody();
      case QROptionType.wifi:
        return WifiBodyTextWidget();
      case QROptionType.event:
        return EventBodyTextWidget();
      case QROptionType.contact:
        return ContactBodyTextWidget();
      case QROptionType.business:
        return BusinessBodyTextWidget();
      case QROptionType.location:
        //TODO: Handle this case.
        return Center(child: Text('Default Widget'));
    }
  }
}

class TextBody extends StatelessWidget {
  const TextBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      //  'Text',
      labelText: AppLocalizations.of(context)!.textLabel,
      // 'Enter text',
      hintText: AppLocalizations.of(context)!.textHint,
    );
  }
}

class WebsiteBody extends StatelessWidget {
  const WebsiteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context)!.websiteLabel,
      hintText: AppLocalizations.of(context)!.websiteHint,
    );
  }
}

class WhatsAppBody extends StatelessWidget {
  const WhatsAppBody({super.key});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context)!.whatsappNumberLabel,
      hintText: AppLocalizations.of(context)!.whatsappNumberHint,
    );
  }
}

class TwitterBody extends StatelessWidget {
  const TwitterBody({super.key});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context)!.twitterUsernameLabel,
      hintText: AppLocalizations.of(context)!.twitterUsernameHint,
    );
  }
}

class EmailBody extends StatelessWidget {
  const EmailBody({super.key});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context)!.emailLabel,
      hintText: AppLocalizations.of(context)!.emailHint,
    );
  }
}

class InstagramBody extends StatelessWidget {
  const InstagramBody({super.key});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context)!.instagramUsernameLabel,
      hintText: AppLocalizations.of(context)!.instagramUsernameHint,
    );
  }
}

class TelephoneBody extends StatelessWidget {
  const TelephoneBody({super.key});

  @override
  Widget build(BuildContext context) {
    return OneTextWidget(
      labelText: AppLocalizations.of(context)!.phoneNumberLabel,
      hintText: AppLocalizations.of(context)!.phoneNumberHint,
    );
  }
}

class OneTextWidget extends StatelessWidget {
  final String labelText;
  final String hintText;
  const OneTextWidget({
    super.key,
    required this.labelText,
    required this.hintText,
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
        ),
      ],
    );
  }
}

class WifiBodyTextWidget extends StatelessWidget {
  const WifiBodyTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: AppLocalizations.of(context)!.networkLabel,
          hintText: AppLocalizations.of(context)!.networkHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.passwordLabel,
          hintText: AppLocalizations.of(context)!.passwordHint,
          autoFocus: true,
        ),
      ],
    );
  }
}

class EventBodyTextWidget extends StatelessWidget {
  const EventBodyTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: AppLocalizations.of(context)!.eventNamelabel,
          hintText: AppLocalizations.of(context)!.eventNameHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.startDateAndTimeLabel,
          hintText: AppLocalizations.of(context)!.startDateAndTimeHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.endDateAndTimeLabel,
          hintText: AppLocalizations.of(context)!.endDateAndTimeHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.eventLocationLabel,
          hintText: AppLocalizations.of(context)!.eventLocationHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.descriptionLabel,
          hintText: AppLocalizations.of(context)!.descriptionHint,
          autoFocus: true,
          maxLines: 3,
        ),
      ],
    );
  }
}

class ContactBodyTextWidget extends StatelessWidget {
  const ContactBodyTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context)!.firstNameLabel,
          firstHint: AppLocalizations.of(context)!.firstNameHint,
          secondLabel: AppLocalizations.of(context)!.lastNameLabel,
          secondHint: AppLocalizations.of(context)!.lastNameHint,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context)!.companyLabel,
          firstHint: AppLocalizations.of(context)!.companyHint,
          secondLabel: AppLocalizations.of(context)!.jobLabel,
          secondHint: AppLocalizations.of(context)!.jobHint,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context)!.phoneLabel,
          firstHint: AppLocalizations.of(context)!.phoneHint,
          secondLabel: AppLocalizations.of(context)!.emailLabel,
          secondHint: AppLocalizations.of(context)!.emailHint,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.websiteLabel,
          hintText: AppLocalizations.of(context)!.websiteHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.addressLabel,
          hintText: AppLocalizations.of(context)!.addressHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context)!.cityLabel,
          firstHint: AppLocalizations.of(context)!.cityHint,
          secondLabel: AppLocalizations.of(context)!.countryLabel,
          secondHint: AppLocalizations.of(context)!.countryHint,
        ),
      ],
    );
  }
}

class BusinessBodyTextWidget extends StatelessWidget {
  const BusinessBodyTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextField(
          labelText: AppLocalizations.of(context)!.companyLabel,
          hintText: AppLocalizations.of(context)!.companyHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context)!.phoneLabel,
          firstHint: AppLocalizations.of(context)!.phoneHint,
          secondLabel: AppLocalizations.of(context)!.emailLabel,
          secondHint: AppLocalizations.of(context)!.emailHint,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.websiteLabel,
          hintText: AppLocalizations.of(context)!.websiteHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        KTextField(
          labelText: AppLocalizations.of(context)!.addressLabel,
          hintText: AppLocalizations.of(context)!.addressHint,
          autoFocus: true,
        ),
        SizedBox(height: 20),
        RowDoubleTextField(
          context: context,
          firstLabel: AppLocalizations.of(context)!.cityLabel,
          firstHint: AppLocalizations.of(context)!.cityHint,
          secondLabel: AppLocalizations.of(context)!.companyLabel,
          secondHint: AppLocalizations.of(context)!.companyHint,
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
  });

  final BuildContext context;
  final String firstLabel;
  final dynamic firstHint;
  final String secondLabel;
  final dynamic secondHint;

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
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 60,
          child: KTextField(
            labelText: secondLabel,
            hintText: secondHint,
            autoFocus: true,
          ),
        ),
      ],
    );
  }
}
