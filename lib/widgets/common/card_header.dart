import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Header row for dashboard cards: a tinted icon badge and an uppercase title.
///
/// ```dart
/// const CardHeader(
///   title: 'FUEL',
///   icon: Icons.local_gas_station_rounded,
///   color: AppColors.primary,
/// )
/// ```
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.trailing,
  });

  /// Title text, for example "BATTERY". Shown as given, so pass upper case.
  final String title;

  /// Icon shown inside the badge.
  final IconData icon;

  /// Accent colour of the icon and its tinted badge background.
  final Color color;

  /// Optional widget aligned to the right edge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Decorative badge. The card's own semantic label carries the meaning.
        ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm - 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm - 1),
              child: Icon(icon, size: 18, color: color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              letterSpacing: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}