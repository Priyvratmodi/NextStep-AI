import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'hard_filters.dart';

Map<CareerDomain, int> scoreDomains(
  List<CareerDomain> available,
  UserProfile p,
) {
  var scores = <CareerDomain, int>{};
  for (var d in available) {
    scores[d] = 0;
  }

  // ── WEIGHT 1: Life Goal (+3 pts) ────────────
  switch (p.lifeGoal) {
    case LifeGoal.money:
      scores[CareerDomain.engineeringTech] =
          (scores[CareerDomain.engineeringTech] ?? 0) + 3;
      scores[CareerDomain.bankingFinance] =
          (scores[CareerDomain.bankingFinance] ?? 0) + 3;
      scores[CareerDomain.salesMarketing] =
          (scores[CareerDomain.salesMarketing] ?? 0) + 2;
      break;
    case LifeGoal.stable:
      scores[CareerDomain.govtServices] =
          (scores[CareerDomain.govtServices] ?? 0) + 3;
      scores[CareerDomain.bankingFinance] =
          (scores[CareerDomain.bankingFinance] ?? 0) + 2;
      scores[CareerDomain.teachingAcademia] =
          (scores[CareerDomain.teachingAcademia] ?? 0) + 2;
      break;
    case LifeGoal.power:
      scores[CareerDomain.govtServices] =
          (scores[CareerDomain.govtServices] ?? 0) + 3;
      scores[CareerDomain.lawJudiciary] =
          (scores[CareerDomain.lawJudiciary] ?? 0) + 3;
      scores[CareerDomain.defenceParamilitary] =
          (scores[CareerDomain.defenceParamilitary] ?? 0) + 2;
      break;
    case LifeGoal.impact:
      scores[CareerDomain.teachingAcademia] =
          (scores[CareerDomain.teachingAcademia] ?? 0) + 3;
      scores[CareerDomain.medicalHealthcare] =
          (scores[CareerDomain.medicalHealthcare] ?? 0) + 3;
      scores[CareerDomain.agricultureRural] =
          (scores[CareerDomain.agricultureRural] ?? 0) + 2;
      break;
    case LifeGoal.freedom:
      scores[CareerDomain.designCreative] =
          (scores[CareerDomain.designCreative] ?? 0) + 3;
      scores[CareerDomain.engineeringTech] =
          (scores[CareerDomain.engineeringTech] ?? 0) + 2;
      scores[CareerDomain.salesMarketing] =
          (scores[CareerDomain.salesMarketing] ?? 0) + 1;
      break;
    case LifeGoal.growth:
      scores[CareerDomain.businessEntrepreneur] =
          (scores[CareerDomain.businessEntrepreneur] ?? 0) + 3;
      scores[CareerDomain.engineeringTech] =
          (scores[CareerDomain.engineeringTech] ?? 0) + 2;
      break;
  }

  // ── WEIGHT 2: Personality (+2 pts) ──────────
  switch (p.personality) {
    case Personality.analytical:
      scores[CareerDomain.engineeringTech] =
          (scores[CareerDomain.engineeringTech] ?? 0) + 2;
      scores[CareerDomain.bankingFinance] =
          (scores[CareerDomain.bankingFinance] ?? 0) + 2;
      break;
    case Personality.social:
      scores[CareerDomain.salesMarketing] =
          (scores[CareerDomain.salesMarketing] ?? 0) + 2;
      scores[CareerDomain.teachingAcademia] =
          (scores[CareerDomain.teachingAcademia] ?? 0) + 2;
      break;
    case Personality.creative:
      scores[CareerDomain.designCreative] =
          (scores[CareerDomain.designCreative] ?? 0) + 2;
      break;
    case Personality.leader:
      scores[CareerDomain.govtServices] =
          (scores[CareerDomain.govtServices] ?? 0) + 2;
      scores[CareerDomain.businessEntrepreneur] =
          (scores[CareerDomain.businessEntrepreneur] ?? 0) + 2;
      break;
    case Personality.helper:
      scores[CareerDomain.medicalHealthcare] =
          (scores[CareerDomain.medicalHealthcare] ?? 0) + 2;
      scores[CareerDomain.teachingAcademia] =
          (scores[CareerDomain.teachingAcademia] ?? 0) + 2;
      break;
    case Personality.builder:
      scores[CareerDomain.engineeringTech] =
          (scores[CareerDomain.engineeringTech] ?? 0) + 2;
      scores[CareerDomain.agricultureRural] =
          (scores[CareerDomain.agricultureRural] ?? 0) + 1;
      break;
  }

  // ── WEIGHT 3: Aptitude bonus (+1 pt) ────────
  if (p.aptitudeScore != null && p.aptitudeScore! >= 7) {
    scores[CareerDomain.engineeringTech] =
        (scores[CareerDomain.engineeringTech] ?? 0) + 1;
    scores[CareerDomain.medicalHealthcare] =
        (scores[CareerDomain.medicalHealthcare] ?? 0) + 1;
    scores[CareerDomain.lawJudiciary] =
        (scores[CareerDomain.lawJudiciary] ?? 0) + 1;
  }

  // remove domains not in available list
  scores.removeWhere((d, _) => !available.contains(d));

  return scores;
}

// Returns top 3 domains ranked by score
List<CareerDomain> resolveTopDomains(UserProfile p) {
  final available = applyHardFilters(p);
  final scores = scoreDomains(available, p);

  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(3).map((e) => e.key).toList();
}
