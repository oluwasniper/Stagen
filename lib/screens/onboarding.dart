import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_asset.dart';
import '../utils/app_motion.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    AppHaptics.light(context);
    final motion = AppMotion.of(context);
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: motion.duration(const Duration(milliseconds: 420)),
        curve: motion.curve(AppMotion.standard),
      );
    } else {
      AppGoRouter.router.go(AppPath.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFDB623),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xff222222),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffFDB623),
        body: Column(
          children: [
            // Logo area — fixed, doesn't scroll
            Expanded(
              flex: 5,
              child: Center(
                child: Image.asset(
                  AppAsset.icon,
                  width: MediaQuery.sizeOf(context).width * 0.32,
                  filterQuality: FilterQuality.high,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration:
                          motion.duration(const Duration(milliseconds: 600)),
                      curve: motion.curve(AppMotion.spring),
                    )
                    .fade(
                      begin: 0,
                      end: 1,
                      duration: motion.duration(AppMotion.medium),
                    ),
              ),
            ),

            // Card area
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff222222),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  children: [
                    // Page indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalPages,
                          (i) => AnimatedContainer(
                            duration: motion.duration(AppMotion.fast),
                            curve: motion.curve(AppMotion.standard),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 5,
                            width: _currentPage == i ? 28 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? const Color(0xffFDB623)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        children: [
                          _OnboardingPage(
                            svgAsset: AppAsset.scanIconSvg,
                            title:
                                AppLocalizations.of(context).onboardingHeader,
                            subtitle: AppLocalizations.of(context)
                                .onboardingSubHeader,
                          ),
                          _OnboardingPage(
                            svgAsset: AppAsset.generateIconSvg,
                            title: _localTitle(context, 1),
                            subtitle: _localSub(context, 1),
                          ),
                          _OnboardingPage(
                            svgAsset: AppAsset.historyIconSvg,
                            title: _localTitle(context, 2),
                            subtitle: _localSub(context, 2),
                          ),
                        ],
                      ),
                    ),

                    // CTA button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFDB623),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _next,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _totalPages - 1
                                    ? AppLocalizations.of(context)
                                        .onboardingSkipButton
                                    : 'Next',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localTitle(BuildContext context, int page) {
    // Reuse existing keys; pages 1/2 fall back gracefully
    return page == 1 ? 'Generate QR Codes' : 'Track Your History';
  }

  String _localSub(BuildContext context, int page) {
    return page == 1
        ? 'Create QR codes for text, Wi-Fi, contacts, events and more — in seconds.'
        : 'All your scanned and generated QR codes stored securely and synced across devices.';
  }
}

class _OnboardingPage extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgAsset,
            colorFilter: const ColorFilter.mode(
              Color(0xffFDB623),
              BlendMode.srcIn,
            ),
            width: 52,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
