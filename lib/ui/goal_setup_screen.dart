import 'package:flutter/material.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/services/ai_service.dart';
import 'package:career_path_finder/services/schedule_storage_service.dart';
import 'package:career_path_finder/utils/ui_helpers.dart';
import 'schedule_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  final AiRoleSuggestion role;
  final CareerDomain domain;
  final UserProfile profile;

  const GoalSetupScreen({
    super.key,
    required this.role,
    required this.domain,
    required this.profile,
  });

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen>
    with SingleTickerProviderStateMixin {
  bool _isGenerating = false;
  String _loadingMessage = 'Generating your personalised schedule...';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _isGenerating = true);

    final messages = [
      'Analysing your career path...',
      'Crafting your personalised plan...',
      'Breaking down topics day by day...',
      'Almost ready...',
    ];
    int msgIndex = 0;
    final ticker = Stream.periodic(const Duration(seconds: 2)).listen((_) {
      if (mounted) {
        setState(() {
          msgIndex = (msgIndex + 1) % messages.length;
          _loadingMessage = messages[msgIndex];
        });
      }
    });

    try {
      // Default to 6 months (180 days) and 2 hours per day as requested by blueprint
      final targetDate = DateTime.now().add(const Duration(days: 180));
      final hoursPerDay = 2.0;

      final dayPlans = await AiService.generateSchedule(
        roleTitle: widget.role.title,
        domainName: widget.domain.displayName,
        totalDays: 180,
        hoursPerDay: hoursPerDay,
        startDate: DateTime.now(),
      );

      final schedule = CareerSchedule(
        roleTitle: widget.role.title,
        domainName: widget.domain.displayName,
        startDate: DateTime.now(),
        targetDate: targetDate,
        hoursPerDay: hoursPerDay,
        days: dayPlans,
      );

      await ScheduleStorageService.saveSchedule(schedule);

      ticker.cancel();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScheduleScreen(schedule: schedule)),
      );
    } catch (e) {
      ticker.cancel();
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: _isGenerating ? _buildLoadingView(cs) : _buildDetailsView(cs),
    );
  }

  Widget _buildLoadingView(ColorScheme cs) {
    return Container(
      color: const Color(0xFF101719),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 52,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _loadingMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This may take a few seconds',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(8),
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<({String title, String desc})> _blueprintForRole() {
    final title = widget.role.title.toLowerCase();

    if (title.contains('developer') ||
        title.contains('engineer') ||
        title.contains('cloud') ||
        title.contains('data') ||
        title.contains('automation')) {
      return [
        (
          title: 'Core Foundations',
          desc:
              'Build the essential tools, terminology, and daily practice routine.',
        ),
        (
          title: 'Guided Projects',
          desc:
              'Create portfolio work that proves skill instead of only listing it.',
        ),
        (
          title: 'Real-world Workflow',
          desc:
              'Practice debugging, documentation, collaboration, and delivery habits.',
        ),
        (
          title: 'Interview Readiness',
          desc:
              'Prepare applications, mock interviews, and a targeted opportunity list.',
        ),
      ];
    }

    if (title.contains('civil') ||
        title.contains('government') ||
        title.contains('banking') ||
        title.contains('clerk')) {
      return [
        (
          title: 'Exam Map',
          desc:
              'Understand syllabus, eligibility, cutoffs, and a realistic attempt plan.',
        ),
        (
          title: 'Daily Concepts',
          desc:
              'Cover reasoning, quantitative aptitude, language, and general awareness.',
        ),
        (
          title: 'Mock Practice',
          desc: 'Attempt timed mocks and revise weak areas with error logs.',
        ),
        (
          title: 'Application Track',
          desc:
              'Track forms, deadlines, admit cards, and interview preparation.',
        ),
      ];
    }

    if (title.contains('marketing') ||
        title.contains('designer') ||
        title.contains('tutor') ||
        title.contains('business')) {
      return [
        (
          title: 'Market Basics',
          desc:
              'Learn the audience, tools, pricing, and proof needed for this path.',
        ),
        (
          title: 'Portfolio Assets',
          desc:
              'Create samples, case studies, or demo lessons that show your value.',
        ),
        (
          title: 'Client Practice',
          desc:
              'Practice outreach, feedback loops, and delivery on small real tasks.',
        ),
        (
          title: 'Earning System',
          desc:
              'Build a simple weekly routine for leads, applications, and follow-ups.',
        ),
      ];
    }

    return [
      (
        title: 'Path Research',
        desc:
            'Learn the role expectations, entry requirements, and local opportunities.',
      ),
      (
        title: 'Skill Building',
        desc:
            'Practice the most important beginner skills with measurable weekly goals.',
      ),
      (
        title: 'Proof of Work',
        desc:
            'Create evidence through projects, certificates, notes, or supervised work.',
      ),
      (
        title: 'Launch Plan',
        desc: 'Prepare applications, networking, and interview practice.',
      ),
    ];
  }

  Widget _buildDetailsView(ColorScheme cs) {
    final blueprint = _blueprintForRole();

    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(cs),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                _buildSummaryCard(cs),
                const SizedBox(height: 24),
                _buildSalaryCard(),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'THE TRAJECTORY BLUEPRINT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                for (final entry in blueprint.indexed)
                  _buildBlueprintStep(
                    step: entry.$1 + 1,
                    title: entry.$2.title,
                    desc: entry.$2.desc,
                  ),
                const SizedBox(height: 160), // Space for bottom sheet
              ],
            ),
          ),
          _buildFloatingBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_back, size: 20, color: cs.primary),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.58,
                child: Text(
                  widget.role.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F4E5F),
                  ),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1a2b3c),
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.route_outlined,
            color: Color(0xFF1F4E5F),
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.role.summary,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4E5F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.payments_outlined,
              size: 150,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PATH SNAPSHOT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildSalaryLevel('ESTIMATED RANGE', widget.role.salary),
              const SizedBox(height: 20),
              _buildSalaryLevel('KEY EXAM / CERT', widget.role.exam),
              const SizedBox(height: 20),
              _buildSalaryLevel('PREP DURATION', widget.role.duration),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryLevel(String level, String salary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          level,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white70,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          salary,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBlueprintStep({
    required int step,
    required String title,
    required String desc,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFDDF4E7),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF123822),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PROGRAMMED TIMELINE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          // Simplified timeline graphic
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timelinePoint('MONTH 1', true),
              _timelinePoint('MONTH 6', true),
              _timelinePoint('YEAR 1', true),
              _timelinePoint('YEAR 2', false),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _generate,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Choose this path',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelinePoint(String text, bool active) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF1F4E5F) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
