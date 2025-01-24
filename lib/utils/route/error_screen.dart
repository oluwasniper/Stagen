import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:revolutionary_stuff/utils/route/app_path.dart';

import '../app_router.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.errorText),
            ElevatedButton(
              onPressed: () {
                AppGoRouter.router.go(AppPath.splash);
              },
              child: Text(AppLocalizations.of(context)!.onboardingHeader),
            ),
            Text(AppLocalizations.of(context)!.errorOR),
            ElevatedButton(
              onPressed: () {
                AppGoRouter.router.pop();
              },
              child: Text(AppLocalizations.of(context)!.errorGoBack),
            ),
          ],
        ),
      ),
    );
  }
}
