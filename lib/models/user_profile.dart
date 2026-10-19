import 'enum.dart';

class UserProfile {
  Education education;
  Situation situation;
  Mode mode;
  LifeGoal lifeGoal;
  Personality personality;
  List<String> skills;
  int? aptitudeScore; // optional, 0–10
  int timeHorizonMonths; // how soon need income
  CareerDomain? domain; // set after classify()

  UserProfile({
    required this.education,
    required this.situation,
    required this.mode,
    required this.lifeGoal,
    required this.personality,
    required this.skills,
    this.aptitudeScore,
    this.timeHorizonMonths = 12,
    this.domain,
  });
}
