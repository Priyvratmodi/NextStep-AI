import 'package:flutter/material.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/utils/ui_helpers.dart';

class EditorialHeader extends StatelessWidget {
  final CareerDomain domain;
  final String pathType; // e.g., "Study Path"

  const EditorialHeader({
    super.key,
    required this.domain,
    this.pathType = "Study Path",
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Badge(
              text: domain.displayName.toUpperCase(),
              backgroundColor: cs.secondaryContainer,
              textColor: cs.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            _Badge(
              text: pathType.toUpperCase(),
              backgroundColor: cs.primaryContainer,
              textColor: cs.onPrimaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Recommended\nCareer Paths',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: 0.7,
          child: Text(
            "Based on your profile, these options balance fit, effort, earning timeline, and long-term growth.",
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
