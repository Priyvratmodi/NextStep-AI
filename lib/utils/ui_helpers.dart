import 'package:flutter/material.dart';
import 'package:career_path_finder/models/enum.dart';

extension EducationExtension on Education {
  String get displayName {
    switch (this) {
      case Education.tenth:
        return "10th Pass";
      case Education.twelfthArts:
        return "12th Arts";
      case Education.twelfthSci:
        return "12th Science";
      case Education.twelfthComm:
        return "12th Commerce";
      case Education.graduate:
        return "Graduate (Any Degree)";
      case Education.postGrad:
        return "Masters / Postgrad";
    }
  }

  IconData get icon {
    switch (this) {
      case Education.tenth:
        return Icons.school_outlined;
      case Education.twelfthArts:
        return Icons.color_lens_outlined;
      case Education.twelfthSci:
        return Icons.science_outlined;
      case Education.twelfthComm:
        return Icons.calculate_outlined;
      case Education.graduate:
        return Icons.school;
      case Education.postGrad:
        return Icons.workspace_premium;
    }
  }
}

extension SituationExtension on Situation {
  String get displayName {
    switch (this) {
      case Situation.wfh:
        return "Remote / WFH";
      case Situation.metro:
        return "Metro City";
      case Situation.tierTwo:
        return "Tier 2 City";
      case Situation.tierThree:
        return "Tier 3 / Rural";
      case Situation.anywhere:
        return "Anywhere (No pref)";
    }
  }

  IconData get icon {
    switch (this) {
      case Situation.wfh:
        return Icons.home_work_outlined;
      case Situation.metro:
        return Icons.location_city_outlined;
      case Situation.tierTwo:
        return Icons.apartment_outlined;
      case Situation.tierThree:
        return Icons.landscape_outlined;
      case Situation.anywhere:
        return Icons.map_outlined;
    }
  }
}

extension ModeExtension on Mode {
  String get displayName {
    switch (this) {
      case Mode.study:
        return "Ready to study more";
      case Mode.earnNow:
        return "Need income fast";
    }
  }

  IconData get icon {
    switch (this) {
      case Mode.study:
        return Icons.menu_book_outlined;
      case Mode.earnNow:
        return Icons.attach_money_outlined;
    }
  }
}

extension LifeGoalExtension on LifeGoal {
  String get displayName {
    switch (this) {
      case LifeGoal.money:
        return "Max Income";
      case LifeGoal.stable:
        return "Job Security";
      case LifeGoal.power:
        return "Authority / Status";
      case LifeGoal.impact:
        return "Help Others";
      case LifeGoal.freedom:
        return "Flexibility / WFH";
      case LifeGoal.growth:
        return "Fast Growth";
    }
  }

  IconData get icon {
    switch (this) {
      case LifeGoal.money:
        return Icons.monetization_on_outlined;
      case LifeGoal.stable:
        return Icons.security_outlined;
      case LifeGoal.power:
        return Icons.local_police_outlined;
      case LifeGoal.impact:
        return Icons.favorite_border;
      case LifeGoal.freedom:
        return Icons.flight_takeoff;
      case LifeGoal.growth:
        return Icons.trending_up;
    }
  }
}

extension PersonalityExtension on Personality {
  String get displayName {
    switch (this) {
      case Personality.analytical:
        return "Analytical (Logic/Data)";
      case Personality.social:
        return "Social (People person)";
      case Personality.creative:
        return "Creative (Arts/Design)";
      case Personality.leader:
        return "Leader (Takes charge)";
      case Personality.helper:
        return "Helper (Care/Support)";
      case Personality.builder:
        return "Builder (Makes things)";
    }
  }

  IconData get icon {
    switch (this) {
      case Personality.analytical:
        return Icons.analytics_outlined;
      case Personality.social:
        return Icons.group_outlined;
      case Personality.creative:
        return Icons.brush_outlined;
      case Personality.leader:
        return Icons.flag_outlined;
      case Personality.helper:
        return Icons.volunteer_activism_outlined;
      case Personality.builder:
        return Icons.handyman_outlined;
    }
  }
}

extension CareerDomainExtension on CareerDomain {
  String get displayName {
    switch (this) {
      case CareerDomain.govtServices:
        return "Government Services";
      case CareerDomain.bankingFinance:
        return "Banking & Finance";
      case CareerDomain.engineeringTech:
        return "Engineering & Tech";
      case CareerDomain.medicalHealthcare:
        return "Medical / Healthcare";
      case CareerDomain.lawJudiciary:
        return "Law & Judiciary";
      case CareerDomain.businessEntrepreneur:
        return "Business & Entrepreneurship";
      case CareerDomain.teachingAcademia:
        return "Teaching & Academia";
      case CareerDomain.designCreative:
        return "Design & Creative";
      case CareerDomain.defenceParamilitary:
        return "Defence & Paramilitary";
      case CareerDomain.salesMarketing:
        return "Sales & Marketing";
      case CareerDomain.alliedHealthcare:
        return "Allied Healthcare";
      case CareerDomain.agricultureRural:
        return "Agriculture & Rural";
    }
  }

  IconData get icon {
    switch (this) {
      case CareerDomain.govtServices:
        return Icons.account_balance;
      case CareerDomain.bankingFinance:
        return Icons.account_balance_wallet;
      case CareerDomain.engineeringTech:
        return Icons.computer;
      case CareerDomain.medicalHealthcare:
        return Icons.local_hospital;
      case CareerDomain.lawJudiciary:
        return Icons.gavel;
      case CareerDomain.businessEntrepreneur:
        return Icons.business_center;
      case CareerDomain.teachingAcademia:
        return Icons.school;
      case CareerDomain.designCreative:
        return Icons.color_lens;
      case CareerDomain.defenceParamilitary:
        return Icons.security;
      case CareerDomain.salesMarketing:
        return Icons.trending_up;
      case CareerDomain.alliedHealthcare:
        return Icons.medical_services;
      case CareerDomain.agricultureRural:
        return Icons.agriculture;
    }
  }
}
