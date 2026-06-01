import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/services/ai_service.dart';
import 'package:career_path_finder/services/schedule_storage_service.dart';
import 'package:career_path_finder/ui/widgets/horizontal_calendar.dart';
import 'package:career_path_finder/ui/widgets/status_flag.dart';

class ScheduleScreen extends StatefulWidget {
  final CareerSchedule schedule;
  const ScheduleScreen({super.key, required this.schedule});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late CareerSchedule _schedule;
  bool _isRegenerating = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _schedule = widget.schedule;
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  int get _offTrackDaysCount {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    int count = 0;
    for (var d in _schedule.days) {
      final dDate = DateTime(d.date.year, d.date.month, d.date.day);
      if (dDate.isBefore(todayMidnight) &&
          !d.isFullyComplete &&
          d.tasks.isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  DayPlan? get _selectedDayPlan {
    try {
      return _schedule.days.firstWhere(
        (d) =>
            d.date.year == _selectedDate.year &&
            d.date.month == _selectedDate.month &&
            d.date.day == _selectedDate.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _save() async {
    await ScheduleStorageService.saveSchedule(_schedule);
  }

  void _toggleTask(DayPlan day, int taskIdx) {
    final dayIdx = _schedule.days.indexOf(day);
    if (dayIdx == -1) return;

    setState(() {
      final task = _schedule.days[dayIdx].tasks[taskIdx];
      _schedule.days[dayIdx].tasks[taskIdx] = task.copyWith(
        isCompleted: !task.isCompleted,
      );
    });
    _save();
  }

  Future<void> _regenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recalibrate Schedule'),
        content: const Text(
          'AI will recalibrate your schedule based on your progress, '
          'picking up from where your completed tasks left off.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Recalibrate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isRegenerating = true);

    try {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      final completedDays = _schedule.days.where((d) {
        final d0 = DateTime(d.date.year, d.date.month, d.date.day);
        return d0.isBefore(todayMidnight) || d0.isAtSameMomentAs(todayMidnight);
      }).toList();

      final newDays = await AiService.regenerateSchedule(
        existingSchedule: _schedule,
      );

      setState(() {
        _schedule = CareerSchedule(
          roleTitle: _schedule.roleTitle,
          domainName: _schedule.domainName,
          startDate: _schedule.startDate,
          targetDate: _schedule.targetDate,
          hoursPerDay: _schedule.hoursPerDay,
          days: [...completedDays, ...newDays],
        );
        _isRegenerating = false;
      });

      await _save();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Schedule recalibrated.')));
    } catch (e) {
      setState(() => _isRegenerating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: _isRegenerating ? _buildRegeneratingView(cs) : _buildMainView(cs),
    );
  }

  Widget _buildRegeneratingView(ColorScheme cs) {
    return Container(
      color: const Color(0xFF101719),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.auto_awesome, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recalibrating schedule...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is crafting your updated plan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                minHeight: 6,
                backgroundColor: Colors.white12,
                color: Color(0xFFA6D8E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(ColorScheme cs) {
    final offTrackDays = _offTrackDaysCount;
    final dayPlan = _selectedDayPlan;
    final isTodaySelected =
        _selectedDate.year == DateTime.now().year &&
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month;
    final upcomingMilestones = _schedule.days
        .where((day) => day.tasks.isNotEmpty && !day.isFullyComplete)
        .skipWhile((day) => day.date.isBefore(_selectedDate))
        .take(2)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        children: [
          _buildTopBar(cs),
          const SizedBox(height: 24),

          if (offTrackDays > 0) ...[
            StatusFlag(
              type: StatusType.offTrack,
              title: 'CURRENT STATUS',
              message: 'You have been off track for $offTrackDays days',
            ),
            const SizedBox(height: 24),
          ] else ...[
            _buildRoleHeader(cs),
            const SizedBox(height: 24),
          ],

          HorizontalCalendar(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isTodaySelected
                    ? "Today's tasks"
                    : "Tasks for ${DateFormat('MMM d').format(_selectedDate)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '${dayPlan?.tasks.length ?? 0} TOTAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (dayPlan == null || dayPlan.tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No tasks scheduled for this day.',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
                ),
              ),
            )
          else
            ...dayPlan.tasks.asMap().entries.map((e) {
              return _PremiumTaskCard(
                task: e.value,
                onToggle: () => _toggleTask(dayPlan, e.key),
              );
            }),

          const SizedBox(height: 32),
          const Text(
            'Upcoming milestones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (upcomingMilestones.isEmpty)
            _buildMilestoneCard(
              title: 'Plan complete',
              subtitle: 'Every visible milestone is done',
              percent: 1,
              dueDate: 'DONE',
              color: const Color(0xFF006C4E),
            )
          else
            ...upcomingMilestones.map((day) {
              final percent = day.tasks.isEmpty
                  ? 0.0
                  : day.completedCount / day.tasks.length;
              return _buildMilestoneCard(
                title: day.tasks.first.title,
                subtitle:
                    '${day.completedCount}/${day.tasks.length} tasks completed',
                percent: percent,
                dueDate: DateFormat('MMM d').format(day.date).toUpperCase(),
                color: percent > 0
                    ? const Color(0xFF006C4E)
                    : cs.primary,
              );
            }),

          if (offTrackDays > 0) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _regenerate,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: cs.onSurface.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Recalibrate my schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    return Row(
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
                  size: 20,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'SCHEDULE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: cs.primary,
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
          ),
          child: Icon(Icons.person, color: cs.onPrimaryContainer, size: 20),
        ),
      ],
    );
  }

  Widget _buildRoleHeader(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _schedule.domainName.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123822),
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _schedule.roleTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Mapping your technical growth trajectory',
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard({
    required String title,
    required String subtitle,
    required double percent,
    required String dueDate,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 4,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                  color: color,
                ),
                Center(
                  child: Text(
                    '${(percent * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DUE $dueDate',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.6),
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

class _PremiumTaskCard extends StatelessWidget {
  final ScheduledTask task;
  final VoidCallback onToggle;

  const _PremiumTaskCard({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Guess duration from title length for visual flavor since model doesn't have it
    final mins = (task.title.length % 3 + 1) * 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: task.isCompleted
            ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))
            : Border.all(
                color: cs.primary.withValues(alpha: 0.5),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: task.isCompleted
                    ? null
                    : Border.all(color: cs.outlineVariant),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? cs.onSurface.withValues(alpha: 0.5)
                        : cs.onSurface,
                  ),
                ),
                if (!task.isCompleted) ...[
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Badge(
                        text: 'Frontend',
                        color: cs.surfaceContainerHighest,
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        text: 'Essential',
                        color: cs.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!task.isCompleted)
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${mins}m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
