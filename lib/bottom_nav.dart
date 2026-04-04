import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'providers/notification_provider.dart';
import 'utils/app_asset.dart';
import 'utils/app_motion.dart';
import 'utils/route/app_path.dart';

class BottomNavigationPage extends ConsumerWidget {
  const BottomNavigationPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = navigationShell.currentIndex;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final navItems = [
      CustomNavBarItem(
        svgData: AppAsset.generateIconSvg,
        label: AppLocalizations.of(context).generate,
      ),
      CustomNavBarItem(
        svgData: AppAsset.scanIconSvg,
        label: AppLocalizations.of(context).scan,
      ),
      CustomNavBarItem(
        svgData: AppAsset.historyIconSvg,
        label: AppLocalizations.of(context).history,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _NotificationBellButton(unreadCount: unreadCount),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CustomFloatingNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          if (index != selectedIndex) {
            AppHaptics.selection(context);
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == selectedIndex,
          );
        },
        items: navItems,
      ),
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<CustomNavBarItem> items;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(36, 18, 36, 16 + safeBottom),
      child: SizedBox(
        height: 90 + safeBottom,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main bar with blur
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xff2A2A2A).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(items.length, (index) {
                        if (index == 1) return const SizedBox(width: 72);
                        return _buildNavItem(context, index);
                      }),
                    ),
                  ),
                ),
              ),
            ),

            // Center FAB scan button
            if (items.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 30,
                child: Center(
                  child: _ScanFAB(
                    isSelected: selectedIndex == 1,
                    semanticsLabel: items[1].label,
                    svgData: items[1].svgData,
                    onTap: () => onItemSelected(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = items[index];
    final isSelected = selectedIndex == index;
    final motion = AppMotion.of(context);

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.18 : 1.0,
              duration: motion.duration(AppMotion.medium),
              curve: motion.curve(AppMotion.spring),
              child: Semantics(
                selected: isSelected,
                button: true,
                label: item.label,
                child: SvgPicture.asset(
                  item.svgData,
                  colorFilter: ColorFilter.mode(
                    isSelected ? const Color(0xffFDB623) : Colors.white60,
                    BlendMode.srcIn,
                  ),
                  width: 26,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: motion.duration(AppMotion.fast),
              style: TextStyle(
                color: isSelected ? const Color(0xffFDB623) : Colors.white54,
                fontSize: isSelected ? 11.5 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
              child: Text(item.label),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: motion.duration(AppMotion.medium),
              curve: motion.curve(AppMotion.standard),
              height: 3,
              width: isSelected ? 22 : 0,
              decoration: BoxDecoration(
                color: const Color(0xffFDB623),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xffFDB623).withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanFAB extends StatefulWidget {
  final bool isSelected;
  final String svgData;
  final String semanticsLabel;
  final VoidCallback onTap;

  const _ScanFAB({
    required this.isSelected,
    required this.svgData,
    required this.semanticsLabel,
    required this.onTap,
  });

  @override
  State<_ScanFAB> createState() => _ScanFABState();
}

class _ScanFABState extends State<_ScanFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);

    return GestureDetector(
      onTap: () => widget.onTap(),
      onTapDown: (_) {
        if (!motion.reduceMotion) {
          _pressController.forward();
        }
      },
      onTapUp: (_) {
        if (!motion.reduceMotion) {
          _pressController.reverse();
        }
      },
      onTapCancel: () {
        if (!motion.reduceMotion) {
          _pressController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: motion.reduceMotion
                ? 1.0
                : _pressScale.value * (widget.isSelected ? 1.08 : 1.0),
            child: child,
          );
        },
        child: Semantics(
          selected: widget.isSelected,
          button: true,
          label: widget.semanticsLabel,
          child: Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffFDC93A), Color(0xffFDB623)],
                    )
                  : null,
              color: widget.isSelected ? null : const Color(0xff333333),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? const Color(0xffFDB623).withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.3),
                  blurRadius: widget.isSelected ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                widget.svgData,
                colorFilter: ColorFilter.mode(
                  widget.isSelected ? Colors.black : Colors.white70,
                  BlendMode.srcIn,
                ),
                width: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNavBarItem {
  final String svgData;
  final String label;

  CustomNavBarItem({required this.svgData, required this.label});
}

/// Floating notification bell with an unread-count badge.
/// Tapping navigates to the notifications inbox screen.
class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppPath.notifications),
      child: Semantics(
        button: true,
        label: unreadCount > 0
            ? '$unreadCount unread notifications'
            : 'Notifications',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xff2A2A2A).withValues(alpha: 0.88),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xffFDB623),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
