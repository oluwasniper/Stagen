import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';

import '../l10n/app_localizations.dart';
import '../providers/connectivity_provider.dart';

class BackgroundScreenWidget extends ConsumerStatefulWidget {
  final Widget body;
  final void Function()? actionButton;
  final String screenTitle;

  const BackgroundScreenWidget({
    super.key,
    required this.body,
    this.actionButton,
    required this.screenTitle,
  });

  @override
  ConsumerState<BackgroundScreenWidget> createState() =>
      _BackgroundScreenWidgetState();
}

class _BackgroundScreenWidgetState
    extends ConsumerState<BackgroundScreenWidget> {
  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider);

    return AnnotatedRegion(
      value:
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
      ]),
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xff4E4E4E),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xff4E4E4E),
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Color(0xff4E4E4E),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(0xff525252),
              ),
            ),
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.05,
              right: -MediaQuery.of(context).size.height * 0.18,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xff4E4E4E),
                  borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.height),
                  ),
                  border: Border.all(
                    color: const Color(0xff616469),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffD9D9D9).withValues(alpha: 0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.05,
              left: -MediaQuery.of(context).size.height * 0.3,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xff4E4E4E),
                  borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.height),
                  ),
                  border: Border.all(
                    color: const Color(0xff616469),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffD9D9D9).withValues(alpha: 0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Container(),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    widget.screenTitle,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                leadingWidth: 65,
                leading: widget.actionButton == null
                    ? GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xff333333),
                            ),
                            child: Iconify(
                              Ri.arrow_left_s_line,
                              size: 40,
                              color: const Color(0xffFDB623),
                            ),
                          ),
                        ),
                      )
                    : null,
                actions: widget.actionButton != null
                    ? [
                        GestureDetector(
                          onTap: widget.actionButton,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xff333333),
                              ),
                              child: Iconify(
                                Ri.menu_3_line,
                                size: 30,
                                color: const Color(0xffFDB623),
                              ),
                            ),
                          ),
                        ),
                      ]
                    : null,
              ),
              body: Column(
                children: [
                  // Offline banner
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isOnline ? 0 : 36,
                    color: const Color(0xff2C2C2C),
                    child: isOnline
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 14,
                                color: Color(0xffFDB623),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context).noInternet,
                                style: const TextStyle(
                                  color: Color(0xffFDB623),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
