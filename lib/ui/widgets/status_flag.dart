import 'package:flutter/material.dart';

enum StatusType { offTrack, onTrack, warning }

class StatusFlag extends StatelessWidget {
  final StatusType type;
  final String title;
  final String message;

  const StatusFlag({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;

    switch (type) {
      case StatusType.offTrack:
        badgeColor = const Color(0xFFC77800);
        break;
      case StatusType.onTrack:
        badgeColor = const Color(0xFF2F855A);
        break;
      case StatusType.warning:
        badgeColor = Colors.orangeAccent;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
