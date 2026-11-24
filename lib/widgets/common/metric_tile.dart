import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// A compact label-and-value pair.
///
/// ```dart
/// const MetricTile(label: 'VOLTAGE', value: '12.6', unit: 'V')
///
/// MetricTile(
///   label: 'HEALTH',
///   value: 'Good',
///   icon: Icons.check_circle_rounded,
///   valueColor: AppColors.success,
/// )
/// ```
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.valueColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Small caption shown above the value, for example "VOLTAGE".
  final String label;

  /// Main value text, for example "12.6".
  final String value;

  /// Optional unit drawn smaller after the value, for example "V".
  final String? unit;

  /// Optional icon drawn before the value.
  final IconData? icon;

  /// Colour of the value (and icon). Defaults to the primary text colour.
  final Color? valueColor;

  /// Horizontal alignment of the label and value.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = valueColor ?? AppColors.textPrimary;

    final valueStyle = textTheme.titleLarge?.copyWith(
      color: color,
      fontSize: 22,
      height: 1.1,
    );

    final unitStyle = textTheme.labelMedium?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    // MainAxisAlignment follows the cross alignment so that a right-aligned
    // tile also hugs the right edge of its row.
    final rowAlignment = switch (crossAxisAlignment) {
      CrossAxisAlignment.end => MainAxisAlignment.end,
      CrossAxisAlignment.center => MainAxisAlignment.center,
      _ => MainAxisAlignment.start,
    };

    return Semantics(
      container: true,
      label: unit == null ? '$label $value' : '$label $value $unit',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: rowAlignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: AppSpacing.xs + 2),
                ],
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      text: value,
                      style: valueStyle,
                      children: [
                        if (unit != null)
                          TextSpan(text: ' $unit', style: unitStyle),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}