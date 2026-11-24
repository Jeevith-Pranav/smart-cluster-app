import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'providers/app_navigation_provider.dart';
import 'providers/vehicle_provider.dart';
import 'services/ble_service.dart';
import 'services/navigation_service.dart';

/// Application entry point.
///
/// Responsibilities:
///  1. Initialise Flutter bindings.
///  2. Configure system UI (edge-to-edge, light status bar icons).
///  3. Register services and providers at the root of the widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind the status and navigation bars for an immersive dark UI.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Transparent system bars with light icons, to suit the dark theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const SmartClusterBootstrap());
}

/// Wires up dependency injection for the whole app.
///
/// Services are created once and exposed through [Provider]. Replacing the
/// dummy [BleService] with a real BLE implementation later only requires
/// changing the `create` callback here.
class SmartClusterBootstrap extends StatelessWidget {
  const SmartClusterBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Services (long-lived, disposed with the app) ---
        Provider<BleService>(
          create: (_) => BleService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<NavigationService>(
          create: (_) => NavigationService(),
          dispose: (_, service) => service.dispose(),
        ),

        // --- State holders ---
        ChangeNotifierProvider<VehicleProvider>(
          create: (context) => VehicleProvider(
            bleService: context.read<BleService>(),
            navigationService: context.read<NavigationService>(),
          ),
        ),
        ChangeNotifierProvider<AppNavigationProvider>(
          create: (_) => AppNavigationProvider(),
        ),
      ],
      child: const SmartClusterApp(),
    );
  }
}