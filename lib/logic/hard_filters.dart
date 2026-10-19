import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';

List<CareerDomain> applyHardFilters(UserProfile p) {
  // start with all 12 domains
  var domains = CareerDomain.values.toList();

  // ── FILTER 1: Education gates ──────────────
  if (p.education == Education.tenth) {
    // 10th pass cannot do these
    domains.removeWhere(
      (d) => [
        CareerDomain.lawJudiciary,
        CareerDomain.medicalHealthcare,
        CareerDomain.engineeringTech,
        CareerDomain.teachingAcademia,
        CareerDomain.bankingFinance,
      ].contains(d),
    );
  }

  if (p.education == Education.twelfthArts) {
    domains.removeWhere(
      (d) => [
        CareerDomain.medicalHealthcare,
        CareerDomain.engineeringTech,
        CareerDomain.alliedHealthcare,
      ].contains(d),
    );
  }

  // ── FILTER 2: Situation gates ───────────────
  if (p.situation == Situation.wfh || p.situation == Situation.tierThree) {
    // these need physical presence
    domains.removeWhere(
      (d) => [
        CareerDomain.defenceParamilitary,
        CareerDomain.lawJudiciary,
      ].contains(d),
    );
  }

  if (p.situation == Situation.wfh) {
    // WFH rules out field/physical roles
    domains.removeWhere(
      (d) => [
        CareerDomain.agricultureRural,
        CareerDomain.govtServices,
      ].contains(d),
    );
  }

  if (p.situation == Situation.tierThree) {
    // startups don't exist in tier 3
    domains.remove(CareerDomain.businessEntrepreneur);
  }

  // ── FILTER 3: Earn Now gates ────────────────
  if (p.mode == Mode.earnNow) {
    // these need 2+ years before any income
    domains.removeWhere(
      (d) => [
        CareerDomain.medicalHealthcare,
        CareerDomain.lawJudiciary,
      ].contains(d),
    );

    // if time horizon under 6 months
    if (p.timeHorizonMonths <= 6) {
      domains.remove(CareerDomain.govtServices);
    }
  }

  return domains; // filtered list
}
