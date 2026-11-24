import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/app_navigation_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/navigation/navigation_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/vehicle/vehicle_screen.dart';
import 'theme.dart';

/// Root widget of the Smart Cluster Companion App.
class SmartClusterApp extends StatelessWidget {
  const SmartClusterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cluster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      // The app is dark-only by design.
      themeMode: ThemeMode.dark,
      home: const AppShell(),
    );
  }
}

/// Maps each [AppTab] to its bottom-bar icons.
///
/// Kept here (not in the provider) so the provider stays free of UI imports.
extension _AppTabIcons on AppTab {
  IconData get icon => switch (this) {
        AppTab.dashboard => Icons.dashboard_outlined,
        AppTab.vehicle => Icons.directions_car_outlined,
        AppTab.navigation => Icons.navigation_outlined,
        AppTab.settings => Icons.settings_outlined,
      };

  IconData get selectedIcon => switch (this) {
        AppTab.dashboard => Icons.dashboard_rounded,
        AppTab.vehicle => Icons.directions_car_rounded,
        AppTab.navigation => Icons.navigation_rounded,
        AppTab.settings => Icons.settings_rounded,
      };
}

/// Persistent frame around all top-level screens.
///
/// Responsibilities:
///  * paints the gradient background once for every tab,
///  * switches between screens without losing their state,
///  * shows the glass bottom navigation bar.
///
/// The body extends behind the bar ([Scaffold.extendBody]), and Scaffold adds
/// the bar's height to the body's bottom `MediaQuery` padding, so screens
/// that use `SafeArea` automatically scroll clear of it.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  /// Screens in the same order as [AppTab.values].
  static const List<Widget> _screens = [
    DashboardScreen(),
    VehicleScreen(),
    NavigationScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Rebuild only when the selected index changes.
    final currentIndex = context.select<AppNavigationProvider, int>(
      (provider) => provider.currentIndex,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        // Transparent so the gradient above shows through.
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _GlassNavigationBar(
          currentIndex: currentIndex,
          onSelected: context.read<AppNavigationProvider>().selectIndex,
        ),
      ),
    );
  }
}

/// Frosted-glass bottom navigation bar.
class _GlassNavigationBar extends StatelessWidget {
  const _GlassNavigationBar({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            // Slightly darker than the card glass for legibility.
            color: Color(0x660B1330),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final tab in AppTab.values)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}