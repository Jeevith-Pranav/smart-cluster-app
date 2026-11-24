import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';

/// A compact pill that communicates one status, for example "BLE Connected".
///
/// ```dart
/// const StatusChip(
///   label: 'Cluster Online',
///   icon: Icons.memory_rounded,
///   color: AppColors.success,
/// )
///
/// StatusChip.health(
///   label: 'Battery Healthy',
///   status: HealthStatus.good,
/// )
/// ```
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.icon,
    this.color = AppColors.success,
    this.onTap,
  });

  /// Creates a chip whose colour and icon come from a [HealthStatus].
  ///
  /// Pass [icon] to override the default status icon, for example to show a
  /// battery symbol instead of a check mark.
  factory StatusChip.health({
    Key? key,
    required String label,
    required HealthStatus status,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return StatusChip(
      key: key,
      label: label,
      icon: icon ?? status.icon,
      color: status.color,
      onTap: onTap,
    );
  }

  /// Text shown in the chip.
  final String label;

  /// Icon shown before the label.
  final IconData icon;

  /// Accent colour used for the icon, text, border and tinted background.
  final Color color;

  /// Called when the chip is tapped. When null, the chip is not interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const radius = BorderRadius.all(Radius.circular(AppRadius.pill));

    return Semantics(
      label: label,
      button: onTap != null,
      container: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.38)),
          ),
          // Material provides the surface for the ink ripple.
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: AppSpacing.sm - 2),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}