import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../app_router.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Error: Page not found'),
            ElevatedButton(
              onPressed: () {
                AppGoRouter.router.go('/onboarding');
              },
              child: Text(AppLocalizations.of(context)!.onboardingHeader),
            ),
          ],
        ),
      ),
    );
  }
}
