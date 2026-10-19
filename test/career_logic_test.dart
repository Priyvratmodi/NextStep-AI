import 'package:career_path_finder/logic/domain_classifier.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'package:career_path_finder/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Domain Classifier Tests', () {
    test('classifier returns ranked domains for a tech-oriented profile', () {
      final result = classify(
        UserProfile(
          education: Education.graduate,
          situation: Situation.wfh,
          mode: Mode.study,
          lifeGoal: LifeGoal.money,
          personality: Personality.analytical,
          skills: const ['Flutter', 'Python'],
          aptitudeScore: 8,
          timeHorizonMonths: 12,
        ),
      );

      expect(result.topThree, hasLength(3));
      expect(result.primaryDomain, result.topThree.first);
      expect(result.topThree, contains(CareerDomain.engineeringTech));
    });

    test('classifier prioritizes creative domain for artistic profile', () {
      final result = classify(
        UserProfile(
          education: Education.twelfthArts,
          situation: Situation.anywhere,
          mode: Mode.study,
          lifeGoal: LifeGoal.freedom,
          personality: Personality.creative,
          skills: const ['Figma', 'Sketching', 'Photoshop'],
          aptitudeScore: 6,
          timeHorizonMonths: 10,
        ),
      );

      expect(result.topThree, hasLength(3));
      expect(result.topThree, contains(CareerDomain.designCreative));
    });

    test('classifier handles fast-earning rural profile with appropriate paths', () {
      final result = classify(
        UserProfile(
          education: Education.tenth,
          situation: Situation.tierThree,
          mode: Mode.earnNow,
          lifeGoal: LifeGoal.money,
          personality: Personality.social,
          skills: const ['Communication', 'Sales'],
          aptitudeScore: 5,
          timeHorizonMonths: 2,
        ),
      );

      expect(result.topThree, hasLength(3));
      expect(result.primaryDomain, isNotNull);
    });
  });

  group('Schedule Model & Progress Tests', () {
    test('schedule progress is calculated from completed tasks', () {
      final schedule = CareerSchedule(
        roleTitle: 'Flutter Developer',
        domainName: 'Engineering & Tech',
        startDate: DateTime(2026),
        targetDate: DateTime(2026, 6),
        hoursPerDay: 2,
        days: [
          DayPlan(
            dayNumber: 1,
            date: DateTime(2026),
            tasks: [
              ScheduledTask(
                id: '1',
                title: 'Read docs',
                description: 'Study fundamentals',
                isCompleted: true,
              ),
              ScheduledTask(
                id: '2',
                title: 'Build sample',
                description: 'Practice implementation',
              ),
            ],
          ),
        ],
      );

      expect(schedule.totalTasks, 2);
      expect(schedule.completedTasks, 1);
      expect(schedule.progressPercent, 0.5);
    });

    test('empty schedule returns 0 progress without division by zero', () {
      final schedule = CareerSchedule(
        roleTitle: 'Empty Role',
        domainName: 'Test',
        startDate: DateTime(2026),
        targetDate: DateTime(2026, 6),
        hoursPerDay: 2,
        days: const [],
      );

      expect(schedule.totalTasks, 0);
      expect(schedule.completedTasks, 0);
      expect(schedule.progressPercent, 0.0);
    });
  });

  group('AiService Offline Fallback Tests', () {
    test('suggestRoles returns curated fallback roles when offline or without API key', () async {
      final profile = UserProfile(
        education: Education.graduate,
        situation: Situation.wfh,
        mode: Mode.study,
        lifeGoal: LifeGoal.growth,
        personality: Personality.analytical,
        skills: const ['Dart'],
        aptitudeScore: 7,
        timeHorizonMonths: 6,
      );

      final roles = await AiService.suggestRoles(
        CareerDomain.engineeringTech,
        profile,
      );

      expect(roles.isNotEmpty, isTrue);
      expect(roles.length, 4);
      expect(roles.first.title.isNotEmpty, isTrue);
      expect(roles.first.summary.isNotEmpty, isTrue);
      expect(roles.any((r) => r.type == 'Safe Bet'), isTrue);
    });

    test('generateSchedule returns valid day plans when offline', () async {
      final plans = await AiService.generateSchedule(
        roleTitle: 'Flutter Developer',
        domainName: 'Engineering & Tech',
        totalDays: 14,
        hoursPerDay: 2.0,
        startDate: DateTime.now(),
      );

      expect(plans.length, 14);
      expect(plans.first.dayNumber, 1);
      expect(plans.first.tasks.isNotEmpty, isTrue);
    });
  });
}
