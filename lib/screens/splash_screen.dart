import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../utils/app_asset.dart';
import '../utils/app_motion.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _animationDone = false;
  bool _authDone = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xffFDB623),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xffFDB623),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    _startAuth();
  }

  Future<void> _startAuth() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.initComplete;
    if (!mounted) return;
    setState(() => _authDone = true);
    _maybeNavigate();
  }

  void _onAnimationComplete() {
    if (!mounted) return;
    setState(() => _animationDone = true);
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_animationDone || !_authDone) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      AppGoRouter.router.go(AppPath.home);
    } else {
      AppGoRouter.router.go(AppPath.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.sizeOf(context).width * 0.38;
    final motion = AppMotion.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFDB623),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xffFDB623),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffFDB623),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon — spring scale + fade
              Image.asset(
                AppAsset.icon,
                height: iconSize,
                width: iconSize,
                filterQuality: FilterQuality.high,
                semanticLabel:
                    '${AppLocalizations.of(context).appName} App Icon',
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: motion.duration(AppMotion.slow),
                    curve: motion.curve(AppMotion.spring),
                  )
                  .fade(
                    begin: 0,
                    end: 1,
                    duration: motion.duration(AppMotion.medium),
                  ),

              const SizedBox(height: 24),

              // App name — slide up + fade
              Text(
                AppLocalizations.of(context).appName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 1.5,
                ),
              )
                  .animate()
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    delay: motion.delay(AppMotion.fast),
                    duration: motion.duration(AppMotion.slow),
                    curve: motion.curve(AppMotion.emphasized),
                  )
                  .fade(
                    begin: 0,
                    end: 1,
                    delay: motion.delay(AppMotion.fast),
                    duration: motion.duration(AppMotion.medium),
                  ),

              const SizedBox(height: 8),

              // Tagline — last to appear, then triggers navigation
              Text(
                'Scan · Generate · Share',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.55),
                  letterSpacing: 2.2,
                ),
              )
                  .animate()
                  .fade(
                    begin: 0,
                    end: 1,
                    delay: motion.delay(const Duration(milliseconds: 520)),
                    duration:
                        motion.duration(const Duration(milliseconds: 450)),
                  )
                  .then(delay: motion.delay(AppMotion.slow))
                  .callback(callback: (_) => _onAnimationComplete()),
            ],
          ),
        ),
      ),
    );
  }
}
