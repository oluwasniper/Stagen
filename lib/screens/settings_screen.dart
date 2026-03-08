import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/telemetry_service.dart';
import '../utils/app_motion.dart';
import '../utils/app_router.dart';
import '../utils/error_localizer.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';
import '../widgets/link_account_dialog.dart';
import '../widgets/settings_list_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String _appUrl = AppConfig.appStoreUrl;
  static const String _privacyUrl = AppConfig.privacyPolicyUrl;

  Future<void> _rateApp() async {
    final uri = Uri.parse(_appUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp() async {
    final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent('Check out Scagen! $_appUrl')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Language names keyed by language code for display in the picker.
  static const _languageNames = {
    'en': 'English',
    'pt': 'Português (Brasil)',
    'fr': 'Français',
    'es': 'Español',
  };

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final motion = AppMotion.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff333333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xffFDB623),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  AppLocalizations.of(context).changeLanguage,
                  style: const TextStyle(
                    color: Color(0xffFDB623),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...L10n.all.asMap().entries.map((entry) {
                final index = entry.key;
                final locale = entry.value;
                final isSelected =
                    locale.languageCode == currentLocale.languageCode;
                final name =
                    _languageNames[locale.languageCode] ?? locale.languageCode;

                return ListTile(
                  leading: AnimatedContainer(
                    duration: motion.duration(AppMotion.fast),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xffFDB623)
                          : Colors.transparent,
                      border: Border.all(
                        color: const Color(0xffFDB623),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 16, color: Color(0xff333333))
                        : null,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xffFDB623)
                          : const Color(0xffD9D9D9),
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(locale);
                    ref.read(telemetryServiceProvider).track(
                      TelemetryEvents.languageChanged,
                      properties: {'locale': locale.languageCode},
                    );
                    Navigator.pop(ctx);
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: motion.delay(Duration(milliseconds: 60 * index)),
                      duration:
                          motion.duration(const Duration(milliseconds: 250)),
                    )
                    .slideX(
                      begin: 0.1,
                      end: 0,
                      delay: motion.delay(Duration(milliseconds: 60 * index)),
                      duration:
                          motion.duration(const Duration(milliseconds: 250)),
                      curve: motion.curve(AppMotion.enter),
                    );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = AppMotion.of(context);
    final settings = ref.watch(settingsProvider);
    final currentLocale = ref.watch(localeProvider);
    final langName = _languageNames[currentLocale.languageCode] ?? 'English';
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    void showLinkDialog() {
      showDialog(
        context: context,
        builder: (ctx) => LinkAccountDialog(
          onSubmit: (email, password, name) async {
            await authNotifier.linkAnonymousAccount(
                email: email, password: password, name: name);
            final error = ref.read(authProvider).error;
            if (error != null) {
              throw Exception(error);
            }
          },
        ),
      );
    }

    final tiles = <Widget>[
      Text(
        AppLocalizations.of(context).settings,
        style: const TextStyle(
            color: Color(0xffFDB623),
            fontSize: 26,
            fontWeight: FontWeight.w400),
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: settings.vibrate,
        iconData: Icons.vibration_rounded,
        title: AppLocalizations.of(context).vibrate,
        subtitle: AppLocalizations.of(context).vibrateDesc,
        onSwitchChanged: (value) {
          ref.read(settingsProvider.notifier).toggleVibrate(value);
          ref.read(telemetryServiceProvider).track(
            TelemetryEvents.settingVibrationToggled,
            properties: {'enabled': value},
          );
        },
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        iconData: Icons.notifications_active_outlined,
        isSwitched: settings.beep,
        title: AppLocalizations.of(context).beep,
        subtitle: AppLocalizations.of(context).beepDesc,
        onSwitchChanged: (value) {
          ref.read(settingsProvider.notifier).toggleBeep(value);
          ref.read(telemetryServiceProvider).track(
            TelemetryEvents.settingBeepToggled,
            properties: {'enabled': value},
          );
        },
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: false,
        showSwitch: false,
        title: AppLocalizations.of(context).changeLanguage,
        subtitle: langName,
        iconData: Icons.language_rounded,
        onTap: () => _showLanguagePicker(context, ref),
      ),
      if (auth.isAnonymous) ...[
        const SizedBox(height: 20),
        SettingsListTile(
          isSwitched: false,
          showSwitch: false,
          title: AppLocalizations.of(context).linkAccountTitle,
          subtitle: AppLocalizations.of(context).linkAccountSubtitle,
          iconData: Icons.link_rounded,
          onTap: showLinkDialog,
        ),
      ],
      const SizedBox(height: 50),
      Text(
        AppLocalizations.of(context).privacy,
        style: const TextStyle(
            color: Color(0xffFDB623),
            fontSize: 26,
            fontWeight: FontWeight.w400),
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: settings.analyticsEnabled,
        iconData: Icons.analytics_outlined,
        title: AppLocalizations.of(context).shareAnalytics,
        subtitle: AppLocalizations.of(context).shareAnalyticsSubtitle,
        onSwitchChanged: (value) {
          if (value) {
            ref.read(settingsProvider.notifier).toggleAnalytics(value);
            ref
                .read(telemetryServiceProvider)
                .track(TelemetryEvents.telemetryOptedIn);
          } else {
            // Track before disabling — this opt-out event should be the last one sent.
            ref
                .read(telemetryServiceProvider)
                .track(TelemetryEvents.telemetryOptedOut);
            ref.read(settingsProvider.notifier).toggleAnalytics(value);
          }
        },
      ),
      const SizedBox(height: 50),
      Text(
        AppLocalizations.of(context).support,
        style: const TextStyle(
            color: Color(0xffFDB623),
            fontSize: 26,
            fontWeight: FontWeight.w400),
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: false,
        showSwitch: false,
        title: AppLocalizations.of(context).rateUs,
        subtitle: AppLocalizations.of(context).rateUsDesc,
        iconData: Icons.check_circle_rounded,
        onTap: _rateApp,
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: false,
        showSwitch: false,
        title: AppLocalizations.of(context).shareBtn,
        subtitle: AppLocalizations.of(context).shareDesc,
        iconData: Icons.share_rounded,
        onTap: _shareApp,
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: false,
        showSwitch: false,
        title: AppLocalizations.of(context).privacyPolicy,
        subtitle: AppLocalizations.of(context).privacyPolicyDesc,
        iconData: Icons.privacy_tip_rounded,
        onTap: _openPrivacyPolicy,
      ),
      const SizedBox(height: 50),
      Text(
        AppLocalizations.of(context).authAccount,
        style: const TextStyle(
            color: Color(0xffFDB623),
            fontSize: 26,
            fontWeight: FontWeight.w400),
      ),
      const SizedBox(height: 20),
      SettingsListTile(
        isSwitched: false,
        showSwitch: false,
        title: AppLocalizations.of(context).authLogout,
        subtitle: AppLocalizations.of(context).authLogoutDesc,
        iconData: Icons.logout_rounded,
        onTap: () async {
          await ref.read(authProvider.notifier).signOut();
          if (!context.mounted) return;

          final authState = ref.read(authProvider);
          if (!authState.isAuthenticated) {
            AppGoRouter.router.go(AppPath.auth);
            return;
          }

          final message = localizeApiError(
            AppLocalizations.of(context),
            authState.errorType,
            authState.error,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      const SizedBox(height: 20),
    ];

    return BackgroundScreenWidget(
        screenTitle: "",
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              final widget = tiles[index];
              // Only animate the ListTile‐based widgets (skip SizedBox and Text)
              if (widget is SettingsListTile) {
                return widget
                    .animate()
                    .fadeIn(
                      delay: motion.delay(Duration(milliseconds: 80 * index)),
                      duration:
                          motion.duration(const Duration(milliseconds: 350)),
                    )
                    .slideX(
                      begin: motion.reduceMotion ? 0 : 0.05,
                      end: 0,
                      delay: motion.delay(Duration(milliseconds: 80 * index)),
                      duration:
                          motion.duration(const Duration(milliseconds: 350)),
                      curve: motion.curve(AppMotion.enter),
                    );
              }
              return widget;
            },
          ),
        ));
  }
}
