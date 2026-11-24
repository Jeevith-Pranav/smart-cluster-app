import 'package:flutter/foundation.dart';

/// The four top-level destinations of the app, in bottom-bar order.
///
/// The enum order is the tab order. [AppTab.index] is used directly as the
/// index for the navigation bar and the screen stack.
enum AppTab {
  dashboard('Dashboard'),
  vehicle('Vehicle'),
  navigation('Navigation'),
  settings('Settings');

  const AppTab(this.label);

  /// Label shown under the bottom-bar icon.
  final String label;
}

/// Tracks the currently selected bottom-navigation tab.
///
/// Kept independent from vehicle data so that UI navigation can change
/// without touching the data layer, and vice versa.
class AppNavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.dashboard;

  /// The tab currently shown.
  AppTab get currentTab => _currentTab;

  /// Index of the current tab, for use with a navigation bar.
  int get currentIndex => _currentTab.index;

  /// Selects [tab]. Does nothing if it is already selected.
  void selectTab(AppTab tab) {
    if (tab == _currentTab) return;
    _currentTab = tab;
    notifyListeners();
  }

  /// Selects a tab by its bar index. Ignores out-of-range values.
  void selectIndex(int index) {
    if (index < 0 || index >= AppTab.values.length) return;
    selectTab(AppTab.values[index]);
  }
}