import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';
import '../common/card_header.dart';
import '../common/glass_card.dart';
import '../common/metric_tile.dart';
import '../common/status_chip.dart';

/// Large dashboard card showing the next turn, distance, ETA, and road.
///
/// ```dart
/// NavigationCard(instruction: NavigationInstruction.dummy)
/// ```
class NavigationCard extends StatelessWidget {
  const NavigationCard({
    super.key,
    required this.instruction,
    this.onTap,
  });

  /// The instruction to display.
  final NavigationInstruction instruction;

  /// Optional tap handler, for example to open the Navigation tab.
  final VoidCallback? onTap;

  /// Blue-tinted glass: a stronger sheen than the neutral cards.
  static final LinearGradient _tintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary.withValues(alpha: 0.34),
      AppColors.primary.withValues(alpha: 0.08),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return GlassCard(
      onTap: onTap,
      gradient: _tintGradient,
      borderColor: AppColors.primaryGlow.withValues(alpha: 0.40),
      padding: const EdgeInsets.all(AppSpacing.xl),
      semanticLabel: '${instruction.direction.instruction} in '
          '${instruction.formattedDistance}, ${_roadPhrase(instruction)}. '
          'Arrival in ${instruction.formattedEta}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CardHeader(
            title: 'NAVIGATION',
            icon: Icons.navigation_rounded,
            color: AppColors.primaryGlow,
            trailing: StatusChip(
              label: 'Guiding',
              icon: Icons.near_me_rounded,
              color: AppColors.primaryGlow,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // The maneuver block animates when the turn itself changes. The key
          // ignores the distance, so a distance countdown does not retrigger
          // the transition.
          AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            // Keeps the outgoing and incoming children left-aligned during
            // the cross-fade, instead of centred.
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: _ManeuverBlock(
              key: ValueKey<String>(
                '${instruction.direction.name}-${instruction.roadName}',
              ),
              instruction: instruction,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'ETA',
                  value: instruction.formattedEta,
                  icon: Icons.schedule_rounded,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'REMAINING',
                  value: instruction.remainingKm.toStringAsFixed(1),
                  unit: 'km',
                  icon: Icons.route_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Builds the phrase after the instruction: "onto Anna Salai", "on Mount
/// Road", or the destination name for the final step.
String _roadPhrase(NavigationInstruction instruction) {
  return switch (instruction.direction) {
    TurnDirection.arrive => instruction.roadName,
    TurnDirection.straight => 'on ${instruction.roadName}',
    _ => 'onto ${instruction.roadName}',
  };
}

/// The turn badge, distance, instruction, and road name.
class _ManeuverBlock extends StatelessWidget {
  const _ManeuverBlock({super.key, required this.instruction});

  final NavigationInstruction instruction;

  /// Side length of the gradient turn badge.
  static const double _badgeSize = 84;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ExcludeSemantics(
      child: Row(
        children: [
          // Gradient badge with the turn arrow.
          Container(
            width: _badgeSize,
            height: _badgeSize,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.55),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              instruction.direction.icon,
              size: 52,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  instruction.formattedDistance,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displaySmall?.copyWith(
                    fontSize: 40,
                    height: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  instruction.direction.instruction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    color: AppColors.primaryGlow,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _roadPhrase(instruction),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}