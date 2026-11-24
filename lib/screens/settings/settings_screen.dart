import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/section_title.dart';

/// Settings tab: placeholder rows for features that are still to come.
///
/// Transparent like every tab: the gradient and bottom bar come from the
/// app shell.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Content never grows wider than this, so tablets stay readable.
  static const double _maxContentWidth = 700;

  /// Shown in the About card. Keep in sync with pubspec.yaml.
  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Includes the bottom bar height, because the shell extends the body
    // behind it.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Rebuilds only if the vehicle name changes.
    final vehicleName = context.select<VehicleProvider, String>(
      (provider) => provider.vehicle.name,
    );

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              bottomInset + AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Screen title -----------------------------------------
                Semantics(
                  header: true,
                  child: Text('Settings', style: textTheme.headlineMedium),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Cluster and app preferences',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // --- Cluster ----------------------------------------------
                const SectionTitle(title: 'Cluster'),
                const SizedBox(height: AppSpacing.md),
                const _SettingsGroup(
                  tiles: [
                    _SettingsTile(
                      icon: Icons.bluetooth_searching_rounded,
                      title: 'Pair new cluster',
                      subtitle: 'Scan for a Raspberry Pi cluster over BLE',
                    ),
                    _SettingsTile(
                      icon: Icons.system_update_alt_rounded,
                      title: 'Cluster firmware',
                      subtitle: 'Check the installed cluster version',
                    ),
                    _SettingsTile(
                      icon: Icons.brightness_6_rounded,
                      title: 'Cluster brightness',
                      subtitle: 'Adjust the cluster display',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // --- Preferences ------------------------------------------
                const SectionTitle(title: 'Preferences'),
                const SizedBox(height: AppSpacing.md),
                const _SettingsGroup(
                  tiles: [
                    _SettingsTile(
                      icon: Icons.straighten_rounded,
                      title: 'Units',
                      subtitle: 'Kilometres, litres, degrees Celsius',
                      value: 'Metric',
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Appearance',
                      subtitle: 'The app is dark by design',
                      value: 'Dark',
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Alerts',
                      subtitle: 'Low fuel, low battery, disconnects',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // --- About ------------------------------------------------
                const SectionTitle(title: 'About'),
                const SizedBox(height: AppSpacing.md),
                _AboutCard(vehicleName: vehicleName, version: _appVersion),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single glass card holding several settings rows separated by dividers.
///
/// One blur layer per group, instead of one per row.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.tiles});

  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(),
              ),
            tiles[i],
          ],
        ],
      ),
    );
  }
}

/// One settings row. Placeholder: tapping shows a "coming soon" message.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Current value shown on the right, for example "Metric". When null, a
  /// chevron is shown instead.
  final String? value;

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$title is coming soon')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: () => _showComingSoon(context),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.sm - 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 20, color: AppColors.primaryGlow),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleSmall?.copyWith(fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      trailing: value == null
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            )
          : Text(
              value!,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primaryGlow,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// App identity card: logo badge, name, version, and the connected vehicle.
class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.vehicleName, required this.version});

  final String vehicleName;
  final String version;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      semanticLabel: 'Smart Cluster Companion, version $version, '
          'paired vehicle $vehicleName',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.speed_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SMART CLUSTER',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      letterSpacing: 2,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Companion App · v$version',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}