import 'package:flutter/material.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'package:career_path_finder/logic/domain_classifier.dart';
import 'package:career_path_finder/utils/ui_helpers.dart';
import 'result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8; // 5 enums + aptitude + time horizon + skills

  // State variables for the User Profile
  Education? _education;
  Situation? _situation;
  Mode? _mode;
  LifeGoal? _lifeGoal;
  Personality? _personality;
  double _aptitudeScore = 5; // Default middle
  double _timeHorizonMonths = 12; // Default 1 year
  final List<String> _skills = [];
  final TextEditingController _skillController = TextEditingController();

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submit() {
    // Construct User Profile
    final profile = UserProfile(
      education: _education ?? Education.graduate,
      situation: _situation ?? Situation.anywhere,
      mode: _mode ?? Mode.study,
      lifeGoal: _lifeGoal ?? LifeGoal.growth,
      personality: _personality ?? Personality.analytical,
      skills: _skills,
      aptitudeScore: _aptitudeScore.toInt(),
      timeHorizonMonths: _timeHorizonMonths.toInt(),
    );

    // Run Classifier
    final result = classify(profile);

    // Navigate to Results
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _education != null;
      case 1:
        return _situation != null;
      case 2:
        return _mode != null;
      case 3:
        return _lifeGoal != null;
      case 4:
        return _personality != null;
      case 5:
        return true; // Aptitude always has a value
      case 6:
        return true; // Time horizon always has a value
      case 7:
        return true; // Skills can be empty
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs),

            // Progress Bar
            Container(
              height: 6,
              width: double.infinity,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    width:
                        MediaQuery.of(context).size.width *
                        ((_currentPage + 1) / _totalPages),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildEnumPage<Education>(
                    step: 1,
                    title: "What is your highest level of education?",
                    values: Education.values,
                    selectedValue: _education,
                    onSelected: (val) {
                      setState(() => _education = val);
                      _nextPage();
                    },
                    getName: (e) => e.displayName,
                    getIcon: (e) => e.icon,
                  ),
                  _buildEnumPage<Situation>(
                    step: 2,
                    title: "What is your current location situation?",
                    values: Situation.values,
                    selectedValue: _situation,
                    onSelected: (val) {
                      setState(() => _situation = val);
                      _nextPage();
                    },
                    getName: (e) => e.displayName,
                    getIcon: (e) => e.icon,
                  ),
                  _buildEnumPage<Mode>(
                    step: 3,
                    title: "What is your immediate priority?",
                    values: Mode.values,
                    selectedValue: _mode,
                    onSelected: (val) {
                      setState(() => _mode = val);
                      _nextPage();
                    },
                    getName: (e) => e.displayName,
                    getIcon: (e) => e.icon,
                  ),
                  _buildEnumPage<LifeGoal>(
                    step: 4,
                    title: "What is your primary life goal?",
                    values: LifeGoal.values,
                    selectedValue: _lifeGoal,
                    onSelected: (val) {
                      setState(() => _lifeGoal = val);
                      _nextPage();
                    },
                    getName: (e) => e.displayName,
                    getIcon: (e) => e.icon,
                  ),
                  _buildEnumPage<Personality>(
                    step: 5,
                    title: "How would you describe your personality?",
                    values: Personality.values,
                    selectedValue: _personality,
                    onSelected: (val) {
                      setState(() => _personality = val);
                      _nextPage();
                    },
                    getName: (e) => e.displayName,
                    getIcon: (e) => e.icon,
                  ),
                  _buildAptitudePage(6),
                  _buildTimeHorizonPage(7),
                  _buildSkillsPage(8),
                ],
              ),
            ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _totalPages - 1
                            ? 'Find My Career'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: cs.primary),
              onPressed: _prevPage,
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Text(
              'ASSESSMENT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'STEP $step OF $_totalPages',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEnumPage<T>({
    required int step,
    required String title,
    required List<T> values,
    required T? selectedValue,
    required Function(T) onSelected,
    required String Function(T) getName,
    required IconData Function(T) getIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(step),
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: values.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final val = values[index];
                final isSelected = val == selectedValue;

                return InkWell(
                  onTap: () => onSelected(val),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? cs.primary : cs.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getIcon(val),
                          color: isSelected ? cs.onPrimary : cs.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            getName(val),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? cs.onPrimary
                                  : cs.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: cs.onPrimary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAptitudePage(int step) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(step),
          const Text(
            "What is your logic & aptitude score?",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Rate yourself honestly on logical reasoning and analytical problem solving.",
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              _aptitudeScore.toInt().toString(),
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.w800,
                color: cs.primary,
                letterSpacing: -5,
              ),
            ),
          ),
          const Spacer(),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: cs.primary,
              inactiveTrackColor: cs.surfaceContainerHighest,
              thumbColor: cs.primary,
              overlayColor: cs.primary.withValues(alpha: 0.12),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _aptitudeScore,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (double value) =>
                  setState(() => _aptitudeScore = value),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTimeHorizonPage(int step) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(step),
          const Text(
            "When do you need to start earning?",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Months of runway you have for preparation before requiring a steady income.",
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  _timeHorizonMonths.toInt().toString(),
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                    letterSpacing: -5,
                  ),
                ),
                Text(
                  'MONTHS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                    color: cs.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: cs.primary,
              inactiveTrackColor: cs.surfaceContainerHighest,
              thumbColor: cs.primary,
              trackHeight: 8,
            ),
            child: Slider(
              value: _timeHorizonMonths,
              min: 0,
              max: 60,
              divisions: 20,
              onChanged: (double value) =>
                  setState(() => _timeHorizonMonths = value),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSkillsPage(int step) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(step),
          const Text(
            "Add your specific skills",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "We use these to refine your trajectory. Type and press '+' to add.",
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Flutter, Design, Python',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                IconButton(
                  onPressed: _addSkill,
                  icon: Icon(Icons.add_circle, color: cs.primary, size: 32),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 12.0,
                children: _skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _skills.remove(skill)),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSkill() {
    final text = _skillController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillController.clear();
      });
    }
  }
}
