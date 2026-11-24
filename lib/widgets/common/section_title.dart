import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// A section heading with an accent bar.
///
/// ```dart
/// const SectionTitle(title: 'Quick Controls')
///
/// SectionTitle(
///   title: 'Navigation',
///   subtitle: 'Turn-by-turn guidance',
///   trailing: TextButton(onPressed: () {}, child: const Text('Open')),
/// )
/// ```
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
  });

  /// Main heading text. Shown in upper case.
  final String title;

  /// Optional secondary line shown under the title.
  final String? subtitle;

  /// Optional widget aligned to the right edge, such as a button.
  final Widget? trailing;

  /// Space around the whole heading.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent bar. Decorative only.
          ExcludeSemantics(
            child: Container(
              width: 4,
              height: subtitle == null ? 18 : 32,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Semantics(
              header: true,
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      letterSpacing: 1.6,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}