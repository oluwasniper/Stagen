import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'utils/app_asset.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,

    /// {@template navigation_shell}
    /// Required parameter that holds the [NavigationShell] instance.
    /// The [NavigationShell] is responsible for managing the navigation state
    /// and transitions between different routes in the application.
    ///
    /// Used by the bottom navigation bar to handle route transitions and
    /// maintain navigation history.
    /// {@endtemplate}
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  /// Handler for when a bottom navigation item is tapped.
  ///
  /// Takes an [index] parameter which represents the index of the tapped item
  /// in the bottom navigation bar. This index corresponds to the position
  /// of the item in the navigation items list, starting from 0.
  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  int _selectedIndex = 1;

  /// A list of [CustomNavBarItem] objects representing the navigation menu items.
  ///
  /// Each item in the list contains information needed to display and handle
  /// navigation bar elements, such as icons, labels, and associated pages/routes.
  /// The order of items in this list determines their display order in the
  /// navigation bar from left to right.
  late List<CustomNavBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    // _navItems = [
    //   CustomNavBarItem(
    //       svgData: AppAsset.generateIconSvg,
    //       label: AppLocalizations.of(context)!.generate),
    //   CustomNavBarItem(
    //       svgData: AppAsset.scanIconSvg,
    //       label: AppLocalizations.of(context)!.scan),
    //   CustomNavBarItem(
    //       svgData: AppAsset.historyIconSvg,
    //       label: AppLocalizations.of(context)!.history),
    // ];
  }

  @override
  void didUpdateWidget(covariant BottomNavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell != widget.navigationShell) {
      _selectedIndex = widget.navigationShell.currentIndex;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navItems = [
      CustomNavBarItem(
          svgData: AppAsset.generateIconSvg,
          label: AppLocalizations.of(context)!.generate),
      CustomNavBarItem(
          svgData: AppAsset.scanIconSvg,
          label: AppLocalizations.of(context)!.scan),
      CustomNavBarItem(
          svgData: AppAsset.historyIconSvg,
          label: AppLocalizations.of(context)!.history),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,

      /// Allows the [Scaffold]'s body to extend behind the [BottomNavigationBar].
      ///
      /// When set to true, the body of the scaffold will be positioned behind the bottom navigation bar,
      /// creating a floating effect. This is particularly useful when implementing translucent or
      /// transparent navigation bars, or when using [FloatingActionButton] that overlaps with the
      /// bottom navigation bar.
      extendBody: true,

      /// A custom floating navigation bar widget positioned at the bottom of the screen.
      ///
      /// This widget creates a floating navigation bar that serves as the main navigation
      /// component for the application. Unlike the standard [BottomNavigationBar], this
      /// custom implementation provides a floating appearance and can be styled according
      /// to specific design requirements.

      bottomNavigationBar: CustomFloatingNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _onItemTapped(index);
          });
        },
        items: _navItems,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: SizedBox(
        height: 105,
        child: Stack(
          /// Specifies the clipping behavior of this container's contents.
          ///
          /// When set to [Clip.none], no clipping occurs, allowing child widgets to draw
          /// outside of this container's bounds. This is useful when you want effects
          /// like shadows or glows to extend beyond the container's boundaries.
          clipBehavior: Clip.none,
          children: [
            // Main Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor,
                  color: Color(0xff333333),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  /// Generates a list of widgets dynamically.
                  ///
                  /// Uses [List.generate] to create a collection of widgets based on a specified length.
                  /// Each element in the list is created by the generator function provided as a parameter.
                  /// This is commonly used for creating repeating UI elements with varying content.
                  children: List.generate(
                    items.length,

                    /// Builds a bottom navigation item or spacing based on the index.
                    /// Returns a [Widget] that is either:
                    /// - A navigation item built by [_buildNavItem] for all indices except 1
                    /// - A [SizedBox] with width 60 when index is 1
                    ///
                    /// This is commonly used in bottom navigation bars to create spacing
                    /// between navigation items, typically for accommodating a center FAB.
                    ///
                    /// @param index The index position in the bottom navigation bar
                    /// @return A [Widget] representing either a nav item or spacing
                    (index) =>
                        index != 1 ? _buildNavItem(index) : SizedBox(width: 60),
                  ),
                ),
              ),
            ),
            // Floating Scan Button
            /// A custom-styled circular button positioned at the bottom center of the navigation bar.
            ///
            /// This widget is rendered only when there are multiple navigation items (items.length > 1).
            /// It creates a floating action button-like element with the following features:
            ///
            /// * Positioned 35 logical pixels from the bottom
            /// * Circular shape with 70x70 dimensions
            /// * Contains an SVG icon from the second navigation item (items[1])
            /// * Changes color based on selection state:
            ///   - Selected: #FDB623 (amber)
            ///   - Unselected: Theme's primary color
            /// * Includes a subtle shadow effect
            /// * SVG icon color changes to white70 when unselected
            ///
            /// The button responds to tap gestures by calling [onItemSelected] with index 1.
            if (items.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 35,
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(35),
                    onTap: () => onItemSelected(1),
                    child: Container(
                      height: 70,
                      width: 70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedIndex == 1
                            ? Color(0xffFDB623)
                            // : Theme.of(context).primaryColor,
                            : Color(0xff333333),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        items[1].svgData,
                        colorFilter: selectedIndex != 1
                            ? const ColorFilter.mode(
                                Colors.white70, BlendMode.srcIn)
                            : null,
                        width: 30,
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

  // Simplified _buildNavItem for non-search items
  /// Builds a single navigation item for the bottom navigation bar.
  ///
  /// [index] The index of the navigation item in the items list.
  ///
  /// Returns a custom-styled [InkWell] widget that represents a navigation item with:
  /// - An SVG icon that changes color based on selection state
  /// - A text label below the icon
  /// - A bottom indicator bar that appears when selected
  ///
  /// The navigation item's appearance changes based on [selectedIndex]:
  /// - Selected state: Gold color (#FDB623) for icon, text and indicator
  /// - Unselected state: White70 color for icon and text, transparent indicator
  ///
  /// The layout includes:
  /// - Horizontal padding of 20
  /// - Vertical padding of 5
  /// - Icon width of 30
  /// - Text size of 17
  /// - Bottom indicator height of 4 and width of 60
  Widget _buildNavItem(int index) {
    final item = items[index];
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              item.svgData,

              colorFilter: isSelected
                  ? const ColorFilter.mode(Color(0xffFDB623), BlendMode.srcIn)
                  : const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
              width: 30,
              // size: 24,
            ),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? Color(0xffFDB623) : Colors.white70,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xffFDB623) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNavBarItem {
  final String svgData;
  final String label;

  CustomNavBarItem({
    required this.svgData,
    required this.label,
  });
}
