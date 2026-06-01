import 'package:flutter/material.dart';
import 'package:career_path_finder/services/ai_service.dart';

class PathCard extends StatelessWidget {
  final AiRoleSuggestion role;
  final VoidCallback onTap;

  const PathCard({super.key, required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color badgeColor;
    Color onBadgeColor;
    IconData typeIcon;

    switch (role.type.toLowerCase()) {
      case 'high reward':
        badgeColor = const Color(0xFFFFE2B8);
        onBadgeColor = const Color(0xFF3C2500);
        typeIcon = Icons.military_tech;
        break;
      case 'wildcard':
        badgeColor = const Color(0xFFD7EEF4);
        onBadgeColor = const Color(0xFF0D2E38);
        typeIcon = Icons.auto_awesome;
        break;
      case 'safe bet':
      default:
        badgeColor = cs.secondaryContainer.withValues(alpha: 0.5);
        onBadgeColor = cs.onSecondaryContainer;
        typeIcon = Icons.verified;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 14, color: onBadgeColor),
                                const SizedBox(width: 6),
                                Text(
                                  role.type.toUpperCase(),
                                  style: TextStyle(
                                    color: onBadgeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            role.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.chevron_right, color: cs.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  role.summary,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoTag(icon: Icons.school_outlined, label: role.exam),
                    _InfoTag(
                      icon: Icons.schedule_outlined,
                      label: role.duration,
                    ),
                    _InfoTag(icon: Icons.payments_outlined, label: role.salary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
