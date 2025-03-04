import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';

import '../widgets/generate_qr_widget.dart';

class GenerateHomeScreen extends StatelessWidget {
  const GenerateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context)!.generateQR,
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
            itemCount: QROptions.getOptions(context).length,
            itemBuilder: (context, index) {
              final option = QROptions.getOptions(context)[index];
              return GestureDetector(
                  onTap: () {
                    AppGoRouter.router.push(
                      AppPath.generateCode,
                      extra: option,
                    );
                  },
                  child: QROptionCard(option: option));
            },
          ),
        ),
      ),
    );
  }
}
