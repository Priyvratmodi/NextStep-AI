import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'conflict_resolver.dart';

class ClassifyResult {
  final CareerDomain primaryDomain;
  final List<CareerDomain> topThree;
  final String mode; // "study" or "earn_now"
  final List<String> conflictsResolved;
  final UserProfile profile;

  ClassifyResult({
    required this.primaryDomain,
    required this.topThree,
    required this.mode,
    required this.conflictsResolved,
    required this.profile,
  });
}

ClassifyResult classify(UserProfile p) {
  final conflicts = <String>[];

  // detect conflicts and log them
  if (p.lifeGoal == LifeGoal.money && p.situation == Situation.tierThree) {
    conflicts.add("Goal=money conflicts with Tier3 situation. Situation wins.");
  }

  if (p.lifeGoal == LifeGoal.power && p.mode == Mode.earnNow) {
    conflicts.add("Power goal needs long study. Earn-now limits path options.");
  }

  if (p.lifeGoal == LifeGoal.freedom && p.situation == Situation.tierThree) {
    conflicts.add(
      "Freedom goal best in WFH/metro. Tier3 limits freelance options.",
    );
  }

  // run the classifier
  final topThree = resolveTopDomains(p);
  final primary = topThree.first;

  // save to Hive so regeneration stays consistent
  // Hive.box('profile').put('domain', primary.name);

  return ClassifyResult(
    primaryDomain: primary,
    topThree: topThree,
    mode: p.mode.name,
    conflictsResolved: conflicts,
    profile: p,
  );
}

// Call like this from your Flutter screen:
// final result = classify(userProfile);
// final domain = result.primaryDomain;
// → pass domain to your AI prompt
