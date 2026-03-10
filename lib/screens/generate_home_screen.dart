import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../services/telemetry_service.dart';
import '../utils/app_motion.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';
import '../widgets/generate_qr_widget.dart';

class GenerateHomeScreen extends ConsumerWidget {
  const GenerateHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = QROptions.getOptions(context);
    final motion = AppMotion.of(context);

    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context).generateQR,
      actionButton: () => AppGoRouter.router.push(AppPath.settings),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 30,
        ),
        child: SizedBox(
          child: GridView.builder(
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 40),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return QROptionCard(
                option: option,
                onTap: () {
                  AppHaptics.light(context);
                  AppSounds.click();
                  ref.read(telemetryServiceProvider).track(
                    TelemetryEvents.qrTypeSelected,
                    properties: {'qr_type': option.type.name},
                  );
                  AppGoRouter.router.push(
                    AppPath.generateCode,
                    extra: option,
                  );
                },
              )
                  .animate()
                  .fadeIn(
                    delay: motion.delay(Duration(milliseconds: 60 * index)),
                    duration: motion.duration(AppMotion.medium),
                  )
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    delay: motion.delay(Duration(milliseconds: 60 * index)),
                    duration: motion.duration(AppMotion.medium),
                    curve: motion.curve(AppMotion.spring),
                  );
            },
          ),
        ),
      ),
    );
  }
}
