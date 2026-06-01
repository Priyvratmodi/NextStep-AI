import 'package:career_path_finder/logic/domain_classifier.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifier returns ranked domains for a complete profile', () {
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
}
