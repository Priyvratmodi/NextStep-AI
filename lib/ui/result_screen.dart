import 'package:flutter/material.dart';
import 'package:career_path_finder/logic/domain_classifier.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/services/schedule_storage_service.dart';
import 'package:career_path_finder/ui/schedule_screen.dart';
import 'package:career_path_finder/ui/widgets/ai_role_suggestions.dart';
import 'package:career_path_finder/ui/widgets/editorial_header.dart';

class ResultScreen extends StatefulWidget {
  final ClassifyResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 12),
            _buildTopBar(context),
            const SizedBox(height: 32),

            // Active Schedule Banner (if exists)
            FutureBuilder<CareerSchedule?>(
              future: ScheduleStorageService.loadSchedule(),
              builder: (context, snapshot) {
                final schedule = snapshot.data;
                if (schedule == null) return const SizedBox.shrink();
                return _ScheduleBanner(schedule: schedule);
              },
            ),

            // Editorial Header
            EditorialHeader(domain: widget.result.primaryDomain),
            const SizedBox(height: 32),

            // AI Generated Role Paths
            AiRoleSuggestionsSection(
              domain: widget.result.primaryDomain,
              profile: widget.result.profile,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: cs.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'CAREER MATCHES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Color(0xFF1F4E5F),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cs.primaryContainer,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Icon(Icons.person, color: cs.onPrimaryContainer, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Schedule Banner (Heavily styled for the new aesthetic) ───────────────────

class _ScheduleBanner extends StatelessWidget {
  final CareerSchedule schedule;
  const _ScheduleBanner({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = schedule.progressPercent;
    final daysLeft = schedule.targetDate
        .difference(DateTime.now())
        .inDays
        .clamp(0, 9999);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ScheduleScreen(schedule: schedule)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'CONTINUE YOUR JOURNEY',
                  style: TextStyle(
                    fontSize: 10,
                      fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$daysLeft d left',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              schedule.roleTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(pct * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
