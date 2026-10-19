import 'package:flutter/material.dart';
import 'package:career_path_finder/services/schedule_storage_service.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/ui/assessment_screen.dart';
import 'package:career_path_finder/ui/schedule_screen.dart';
import 'package:career_path_finder/ui/widgets/trajectory_bottom_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_path_finder/services/auth_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentNavIndex = 0;
  CareerSchedule? _activeSchedule;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final schedule = await ScheduleStorageService.loadSchedule();
    if (mounted) {
      setState(() {
        _activeSchedule = schedule;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeroSection(context),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 36),
                    _buildSectionHeader('Career Progress'),
                    const SizedBox(height: 16),
                    _buildInsightsGrid(context),
                    const SizedBox(height: 48),
                    _buildSectionHeader(
                      'Next Milestones',
                      action: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View Timeline',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B2CAF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMilestonesList(context),
                    const SizedBox(height: 120), // Bottom nav spacer
                  ]),
                ),
              ),
            ],
          ),

          // Bottom Nav
          Align(
            alignment: Alignment.bottomCenter,
            child: TrajectoryBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                if (index == _currentNavIndex) return;
                setState(() => _currentNavIndex = index);

                // Navigation Logic
                if (index == 1) {
                  // Path Finder
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AssessmentScreen()),
                  );
                } else if (index == 2) {
                  // Schedule
                  if (_activeSchedule != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ScheduleScreen(schedule: _activeSchedule!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Start an assessment to generate a schedule.',
                        ),
                      ),
                    );
                  }
                } else if (index == 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile settings are coming soon.'),
                    ),
                  );
                }
                setState(() => _currentNavIndex = 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 80,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Icon(
              Icons.explore_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DASHBOARD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
              const Text(
                'Career Path',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF182024),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(authServiceProvider).signOut();
          },
          icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Sign out',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    if (_activeSchedule == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              const Color(0xFF2F855A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'READY WHEN YOU ARE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start your assessment and get a practical role path.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AssessmentScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B2CAF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final progress = _activeSchedule!.progressPercent;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F4E5F), Color(0xFF2F855A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF68DBAE),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ACTIVE JOURNEY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_activeSchedule!.roleTitle}\nStudy Path',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
              'Plan progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: const Color(0xFF68DBAE),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ScheduleScreen(schedule: _activeSchedule!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B2CAF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Open schedule',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _buildActionTile(
        context,
        color: Theme.of(context).colorScheme.secondaryContainer,
        icon: Icons.auto_stories_outlined,
        title: 'Explore study paths',
        subtitle: 'Compare realistic directions based on your profile.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AssessmentScreen()),
          );
        },
      ),
      _buildActionTile(
        context,
        color: Theme.of(context).colorScheme.tertiaryContainer,
        icon: Icons.payments_outlined,
        title: 'Find earn-now paths',
        subtitle: 'Prioritize options with faster income potential.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AssessmentScreen()),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              actions[0],
              const SizedBox(height: 12),
              actions[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: actions[0]),
            const SizedBox(width: 12),
            Expanded(child: actions[1]),
          ],
        );
      },
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(minHeight: 168),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Icon(Icons.arrow_forward_rounded, size: 18)],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        ?action,
      ],
    );
  }

  Widget _buildInsightsGrid(BuildContext context) {
    final completed = _activeSchedule?.completedTasks ?? 0;
    final total = _activeSchedule?.totalTasks ?? 0;
    final progress = total == 0
        ? '0%'
        : '${((completed / total) * 100).round()}%';
    final activeDays =
        _activeSchedule?.days.where((day) => day.completedCount > 0).length ??
        0;
    final daysLeft = _activeSchedule == null
        ? 0
        : _activeSchedule!.targetDate
              .difference(DateTime.now())
              .inDays
              .clamp(0, 9999);

    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            'Tasks Done',
            '$completed/$total',
            progress,
            const Color(0xFF3B2CAF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            'Active Days',
            '$activeDays',
            'logged',
            const Color(0xFF006C4E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            'Days Left',
            '$daysLeft',
            'target',
            const Color(0xFF633A00),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String label,
    String value,
    String trend,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesList(BuildContext context) {
    if (_activeSchedule == null) {
      return _buildMilestoneItem(
        context,
        icon: Icons.flag_circle,
        iconColor: const Color(0xFF3B2CAF),
        iconBg: const Color(0xFFE3DFFF),
        title: 'Complete your first assessment',
        subtitle: 'Get matched with career paths and a study plan',
        time: 'Start now',
      );
    }

    final upcoming = _activeSchedule!.days
        .where((day) => day.tasks.isNotEmpty && !day.isFullyComplete)
        .take(2)
        .toList();

    return Column(
      children: upcoming.map((day) {
        final firstTask = day.tasks.first;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildMilestoneItem(
            context,
            icon: day.completedCount > 0 ? Icons.check_circle : Icons.school,
            iconColor: day.completedCount > 0
                ? const Color(0xFF006C4E)
                : const Color(0xFF3B2CAF),
            iconBg: day.completedCount > 0
                ? const Color(0xFF83F5C6)
                : const Color(0xFFE3DFFF),
            title: firstTask.title,
            subtitle: firstTask.description,
            time: 'Day ${day.dayNumber}',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
