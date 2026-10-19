import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'package:career_path_finder/models/schedule_models.dart';
import 'package:career_path_finder/utils/ui_helpers.dart';

class AiRoleSuggestion {
  final String title;
  final String summary;
  final String type; // Safe Bet, High Reward, Wildcard
  final String exam; // e.g., GATE
  final String duration; // e.g., 2 Years
  final String salary; // e.g., $80k - $140k

  AiRoleSuggestion({
    required this.title,
    required this.summary,
    required this.type,
    required this.exam,
    required this.duration,
    required this.salary,
  });

  factory AiRoleSuggestion.fromJson(Map<String, dynamic> json) {
    return AiRoleSuggestion(
      title: json['title'] ?? 'Unknown Role',
      summary: json['summary'] ?? 'No summary available.',
      type: json['type'] ?? 'Safe Bet',
      exam: json['exam'] ?? 'Standard Exam',
      duration: json['duration'] ?? '1-2 Years',
      salary: json['salary'] ?? 'Competitive',
    );
  }
}

class AiService {
  static const _groqModel = 'llama-3.1-8b-instant';
  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static String _getApiKey() {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY is not set in .env');
    }
    return apiKey;
  }

  static List<AiRoleSuggestion> _fallbackRoles(
    CareerDomain domain,
    UserProfile profile,
  ) {
    final fastIncome = profile.mode == Mode.earnNow;
    final remote = profile.situation == Situation.wfh;

    switch (domain) {
      case CareerDomain.engineeringTech:
        return [
          AiRoleSuggestion(
            title: remote ? 'Flutter Developer' : 'Software Developer',
            summary:
                'Build apps and web products using programming, debugging, and product thinking. This fits analytical or builder profiles and can start with a strong project portfolio.',
            type: 'Safe Bet',
            exam: 'None',
            duration: fastIncome ? '3-6 Months' : '6-12 Months',
            salary: 'INR 4L - 18L',
          ),
          AiRoleSuggestion(
            title: 'Data Analyst',
            summary:
                'Turn raw data into dashboards, insights, and business decisions. It is a practical path if you enjoy logic, spreadsheets, SQL, and clear communication.',
            type: 'Safe Bet',
            exam: 'None',
            duration: '4-8 Months',
            salary: 'INR 3.5L - 12L',
          ),
          AiRoleSuggestion(
            title: 'Cloud Support Engineer',
            summary:
                'Help teams run reliable cloud systems, troubleshoot incidents, and learn infrastructure. It offers a good bridge from support into DevOps or platform engineering.',
            type: 'High Reward',
            exam: 'AWS / Azure',
            duration: '6-10 Months',
            salary: 'INR 5L - 20L',
          ),
          AiRoleSuggestion(
            title: 'AI Automation Specialist',
            summary:
                'Use APIs, no-code tools, and scripting to automate business workflows. It is a fast-moving path for someone who wants practical earning opportunities.',
            type: 'Wildcard',
            exam: 'None',
            duration: '2-5 Months',
            salary: 'INR 4L - 16L',
          ),
        ];
      case CareerDomain.bankingFinance:
        return [
          AiRoleSuggestion(
            title: 'Banking Associate',
            summary:
                'Prepare for banking exams and customer-facing finance roles. This is stable, structured, and suitable when job security matters.',
            type: 'Safe Bet',
            exam: 'IBPS / SBI',
            duration: '6-12 Months',
            salary: 'INR 3L - 9L',
          ),
          AiRoleSuggestion(
            title: 'Financial Analyst',
            summary:
                'Analyze company performance, budgets, and investment data. It rewards analytical thinking and communication.',
            type: 'High Reward',
            exam: 'NISM / CFA L1',
            duration: '6-15 Months',
            salary: 'INR 5L - 18L',
          ),
          AiRoleSuggestion(
            title: 'Insurance Advisor',
            summary:
                'Sell and advise on insurance products with measurable earning potential. It works well for social personalities who need income sooner.',
            type: 'Safe Bet',
            exam: 'IRDAI',
            duration: '1-3 Months',
            salary: 'INR 2.5L - 10L',
          ),
          AiRoleSuggestion(
            title: 'Fintech Operations Specialist',
            summary:
                'Work on payments, risk checks, onboarding, and customer operations in fintech companies. It can become a gateway into product or compliance roles.',
            type: 'Wildcard',
            exam: 'None',
            duration: '3-6 Months',
            salary: 'INR 3L - 12L',
          ),
        ];
      case CareerDomain.govtServices:
      case CareerDomain.defenceParamilitary:
      case CareerDomain.lawJudiciary:
        return [
          AiRoleSuggestion(
            title: 'Civil Services Aspirant',
            summary:
                'Prepare for competitive public service roles with a disciplined study plan. This path fits people who value authority, impact, and long-term stability.',
            type: 'High Reward',
            exam: 'UPSC / State PSC',
            duration: '12-24 Months',
            salary: 'INR 6L - 18L',
          ),
          AiRoleSuggestion(
            title: 'Government Clerk / Assistant',
            summary:
                'Target administrative roles through SSC and state exams. It is a more accessible route to stable government employment.',
            type: 'Safe Bet',
            exam: 'SSC / State Exams',
            duration: '6-12 Months',
            salary: 'INR 3L - 8L',
          ),
          AiRoleSuggestion(
            title: 'Legal Assistant',
            summary:
                'Support case research, documentation, and office workflow for legal teams. It is a practical entry path while building deeper legal knowledge.',
            type: 'Safe Bet',
            exam: 'None',
            duration: '3-6 Months',
            salary: 'INR 2.5L - 7L',
          ),
          AiRoleSuggestion(
            title: 'Policy Research Associate',
            summary:
                'Work on research, reports, and public-interest projects with NGOs or policy firms. It suits people who care about impact and writing.',
            type: 'Wildcard',
            exam: 'None',
            duration: '6-12 Months',
            salary: 'INR 3L - 10L',
          ),
        ];
      case CareerDomain.medicalHealthcare:
      case CareerDomain.alliedHealthcare:
        return [
          AiRoleSuggestion(
            title: 'Medical Lab Technician',
            summary:
                'Run diagnostics, sample processing, and lab workflows. It is a structured healthcare path with steady demand.',
            type: 'Safe Bet',
            exam: 'DMLT / BMLT',
            duration: '12-24 Months',
            salary: 'INR 2.5L - 8L',
          ),
          AiRoleSuggestion(
            title: 'Healthcare Administrator',
            summary:
                'Manage hospital operations, patient coordination, and records. It fits organized, social, or helper profiles.',
            type: 'Safe Bet',
            exam: 'Hospital Admin Cert',
            duration: '6-12 Months',
            salary: 'INR 3L - 12L',
          ),
          AiRoleSuggestion(
            title: 'Clinical Data Coordinator',
            summary:
                'Support healthcare studies by organizing patient and trial data. It blends healthcare interest with analytical work.',
            type: 'High Reward',
            exam: 'None',
            duration: '4-8 Months',
            salary: 'INR 4L - 14L',
          ),
          AiRoleSuggestion(
            title: 'Telehealth Support Specialist',
            summary:
                'Help patients access remote consultations and digital health services. It can be a good option for remote or tier-two situations.',
            type: 'Wildcard',
            exam: 'None',
            duration: '2-4 Months',
            salary: 'INR 2.5L - 8L',
          ),
        ];
      case CareerDomain.designCreative:
      case CareerDomain.salesMarketing:
      case CareerDomain.businessEntrepreneur:
      case CareerDomain.teachingAcademia:
      case CareerDomain.agricultureRural:
        return [
          AiRoleSuggestion(
            title: 'Digital Marketing Specialist',
            summary:
                'Run campaigns, content, analytics, and lead generation. It has quick entry points and rewards experimentation.',
            type: fastIncome ? 'Safe Bet' : 'High Reward',
            exam: 'Google / Meta Cert',
            duration: '2-6 Months',
            salary: 'INR 3L - 12L',
          ),
          AiRoleSuggestion(
            title: 'UI/UX Designer',
            summary:
                'Design useful app and website experiences using research, wireframes, and visual systems. It suits creative people who also like problem solving.',
            type: 'High Reward',
            exam: 'Portfolio',
            duration: '4-9 Months',
            salary: 'INR 4L - 16L',
          ),
          AiRoleSuggestion(
            title: 'Online Tutor',
            summary:
                'Teach academic or skill-based subjects through online platforms. It is flexible, practical, and works well for helper or social personalities.',
            type: 'Safe Bet',
            exam: 'None',
            duration: '1-3 Months',
            salary: 'INR 2L - 10L',
          ),
          AiRoleSuggestion(
            title: 'Local Business Operator',
            summary:
                'Build a small service, retail, or agri-linked business around local demand. It is riskier but can fit people who want independence.',
            type: 'Wildcard',
            exam: 'None',
            duration: '3-12 Months',
            salary: 'Variable',
          ),
        ];
    }
  }

  static List<DayPlan> _fallbackSchedule({
    required String roleTitle,
    required int totalDays,
    required DateTime startDate,
  }) {
    final phases = [
      'Foundation',
      'Core skills',
      'Project practice',
      'Portfolio polish',
      'Interview prep',
      'Applications',
    ];

    return List.generate(totalDays, (index) {
      final day = index + 1;
      final phase =
          phases[((index / totalDays) * phases.length).floor().clamp(
            0,
            phases.length - 1,
          )];
      return DayPlan(
        dayNumber: day,
        date: startDate.add(Duration(days: index)),
        tasks: [
          ScheduledTask(
            id: 'fallback_${day}_0',
            title: '$phase study',
            description:
                'Spend focused time on $phase topics for the $roleTitle path.',
          ),
          ScheduledTask(
            id: 'fallback_${day}_1',
            title: 'Practice and notes',
            description:
                'Complete one practical exercise, then write clear notes and blockers.',
          ),
        ],
      );
    });
  }

  static String _cleanJson(String raw) {
    String cleaned = raw.trim();

    // Try to extract from ```json ... ```
    final RegExp jsonBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = jsonBlock.firstMatch(cleaned);
    if (match != null && match.group(1) != null) {
      cleaned = match.group(1)!;
    }

    cleaned = cleaned.trim();

    // Try to find the start of a JSON block (either [ or {)
    final startBracket = cleaned.indexOf('[');
    final startBrace = cleaned.indexOf('{');

    int startIdx = -1;
    int endIdx = -1;

    if (startBracket != -1 && (startBrace == -1 || startBracket < startBrace)) {
      startIdx = startBracket;
      endIdx = cleaned.lastIndexOf(']');
    } else if (startBrace != -1) {
      startIdx = startBrace;
      endIdx = cleaned.lastIndexOf('}');
    }

    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      cleaned = cleaned.substring(startIdx, endIdx + 1);
    }

    return cleaned;
  }

  static Future<dynamic> _callGroq(String prompt) async {
    final apiKey = _getApiKey();
    final uri = Uri.parse(_groqUrl);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _groqModel,
        'messages': [
          {'role': 'system', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Groq API error ${response.statusCode}: ${response.body}',
      );
    }
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }

  // ─── Role Suggestions ─────────────────────────────────────────────────────

  static Future<List<AiRoleSuggestion>> suggestRoles(
    CareerDomain domain,
    UserProfile profile,
  ) async {
    final systemPrompt =
        '''
You are an expert career counselor. 
A user has taken a career assessment and their top recommended domain is "${domain.displayName}".
Here are the user's details:
- Education: ${profile.education.displayName}
- Situation: ${profile.situation.displayName}
- Primary Mode: ${profile.mode.displayName}
- Life Goal: ${profile.lifeGoal.displayName}
- Personality: ${profile.personality.displayName}
- Logic/Aptitude Score (0-10): ${profile.aptitudeScore}
- Time before needing income: ${profile.timeHorizonMonths} months
- Skills: ${profile.skills.isNotEmpty ? profile.skills.join(", ") : "None specified"}

Based ONLY on the domain "${domain.displayName}" and tailoring specifically to these user characteristics, suggest 4 distinct job roles. 

Provide the response in pure JSON format ONLY containing an array of objects. Do not wrap it in markdown block quotes (like ```json), just output the raw JSON array.
Each object must have these fields:
- "title": Job role title.
- "summary": A 2-3 sentence overview of what the role entails and why it fits this user.
- "type": Classify this path as "Safe Bet", "High Reward", or "Wildcard" based on the user's profile and the role's difficulty/potential.
- "exam": The most critical exam or certification needed (e.g., "GATE", "GRE/TOEFL", "UPSC", "None").
- "duration": Estimated preparation time (e.g., "1-2 Years").
- "salary": Estimated annual salary range (e.g., "\$80k - \$120k").

Example format:
[
  {
    "title": "Software Engineer",
    "summary": "Full-stack development focus...",
    "type": "Safe Bet",
    "exam": "None",
    "duration": "1 Year",
    "salary": "\$70k - \$130k"
  }
]
    ''';

    try {
      final raw = await _callGroq(systemPrompt) as String;
      final cleaned = _cleanJson(raw);
      try {
        final List<dynamic> jsonList = jsonDecode(cleaned);
        return jsonList.map((j) => AiRoleSuggestion.fromJson(j)).toList();
      } catch (e) {
        debugPrint('JSON Parsing Error: $e');
        debugPrint('Raw Response: $raw');
        debugPrint('Cleaned Response: $cleaned');
        return _fallbackRoles(domain, profile);
      }
    } catch (e) {
      debugPrint('Using fallback role suggestions: $e');
      return _fallbackRoles(domain, profile);
    }
  }

  // ─── Schedule Generation ───────────────────────────────────────────────────

  /// Generates a fresh day-wise schedule.
  static Future<List<DayPlan>> generateSchedule({
    required String roleTitle,
    required String domainName,
    required int totalDays,
    required double hoursPerDay,
    required DateTime startDate,
  }) async {
    // Cap at 14 milestone days to ensure the AI doesn't hit token limits
    final int aiDays = totalDays <= 14 ? totalDays : 14;

    final prompt =
        '''
You are an expert career coach. Create a structured study schedule for the role "$roleTitle" in "$domainName".

Total preparation days: $totalDays
AI-generated milestone days needed: $aiDays 

Output ONLY a JSON object with a "days" key containing a list of objects. DO NOT include ANY other text.
Format:
{
  "days": [
    {
      "day_number": 1,
      "tasks": [
        { "title": "Concise Task Title", "description": "Brief actionable instruction" }
      ]
    }
  ]
}

Rules:
- Each day should have 2-4 tasks for $hoursPerDay hours of study.
- Space the $aiDays days evenly across $totalDays days (e.g., if aiDays=14 and totalDays=60, use day numbers like 1, 5, 10...).
- Keep task titles under 7 words.
- Output ONLY the JSON object.
''';

    try {
      final raw = await _callGroq(prompt) as String;
      final cleaned = _cleanJson(raw);

      List<dynamic> jsonList;
      try {
        final Map<String, dynamic> data = jsonDecode(cleaned);
        jsonList = data['days'] as List<dynamic>? ?? [];
      } catch (e) {
        // Fallback for array format if AI ignores the object wrap
        try {
          jsonList = jsonDecode(cleaned) as List<dynamic>;
        } catch (e2) {
          debugPrint('JSON Parsing Error (Schedule): $e2');
          debugPrint('Raw AI Response: $raw');
          debugPrint('Cleaned Response: $cleaned');
          return _fallbackSchedule(
            roleTitle: roleTitle,
            totalDays: totalDays,
            startDate: startDate,
          );
        }
      }

      final List<DayPlan> aiDayPlans = jsonList.map((d) {
        final dayNum = (d['day_number'] as num).toInt();
        final tasksList = (d['tasks'] as List<dynamic>? ?? []);
        return DayPlan(
          dayNumber: dayNum,
          date: startDate.add(Duration(days: dayNum - 1)),
          tasks: tasksList.asMap().entries.map((e) {
            final t = e.value as Map<String, dynamic>;
            return ScheduledTask(
              id: '${dayNum}_${e.key}_${DateTime.now().millisecondsSinceEpoch}',
              title: t['title'] ?? 'Study task',
              description: t['description'] ?? '',
            );
          }).toList(),
        );
      }).toList();

      // Fill in any missing days between AI-generated milestone days
      return _fillMissingDays(aiDayPlans, totalDays, startDate);
    } catch (e) {
      debugPrint('Using fallback schedule: $e');
      return _fallbackSchedule(
        roleTitle: roleTitle,
        totalDays: totalDays,
        startDate: startDate,
      );
    }
  }

  /// Re-generates remaining schedule based on completed tasks.
  static Future<List<DayPlan>> regenerateSchedule({
    required CareerSchedule existingSchedule,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final remaining = existingSchedule.targetDate.difference(today).inDays;
    if (remaining <= 0) throw Exception('Target date has already passed.');

    final completedSummary = existingSchedule.completedTasksSummary;

    final prompt =
        '''
You are an expert career coach re-calibrating a study schedule.

Role: ${existingSchedule.roleTitle}
Domain: ${existingSchedule.domainName}
Hours per day: ${existingSchedule.hoursPerDay} hours
Remaining days: $remaining
Topics/tasks already completed: $completedSummary

Generate a fresh JSON schedule for the REMAINING $remaining days, building on what was already completed.
Skip beginner content that was already covered. Focus on what's next.

Output ONLY a raw JSON array:
[
  {
    "day_number": 1,
    "tasks": [
      { "title": "Short task title", "description": "1-2 sentence actionable description" }
    ]
  }
]

Rules:
- Day 1 = today ($today).
- Each day: 2-4 tasks for ${existingSchedule.hoursPerDay} hours of study.
- Output ONLY the JSON array, no extra text.
''';

    try {
      final raw = await _callGroq(prompt) as String;
      final cleaned = _cleanJson(raw);

      List<dynamic> jsonList;
      try {
        jsonList = jsonDecode(cleaned);
      } catch (e) {
        debugPrint('JSON Parsing Error (Regenerate): $e');
        debugPrint('Raw AI Response: $raw');
        debugPrint('Cleaned Response: $cleaned');
        return _fallbackSchedule(
          roleTitle: existingSchedule.roleTitle,
          totalDays: remaining,
          startDate: today,
        );
      }

      return jsonList.map((d) {
        final dayNum = (d['day_number'] as num).toInt();
        final tasksList = (d['tasks'] as List<dynamic>? ?? []);
        return DayPlan(
          dayNumber: dayNum,
          date: today.add(Duration(days: dayNum - 1)),
          tasks: tasksList.asMap().entries.map((e) {
            final t = e.value as Map<String, dynamic>;
            return ScheduledTask(
              id: '${dayNum}_${e.key}_${DateTime.now().millisecondsSinceEpoch}',
              title: t['title'] ?? 'Study task',
              description: t['description'] ?? '',
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Using fallback regenerated schedule: $e');
      return _fallbackSchedule(
        roleTitle: existingSchedule.roleTitle,
        totalDays: remaining,
        startDate: today,
      );
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Fills gaps between AI milestone days with "Review & Practice" days.
  static List<DayPlan> _fillMissingDays(
    List<DayPlan> aiDays,
    int totalDays,
    DateTime startDate,
  ) {
    final Map<int, DayPlan> byDay = {for (var d in aiDays) d.dayNumber: d};
    final List<DayPlan> full = [];

    for (int i = 1; i <= totalDays; i++) {
      if (byDay.containsKey(i)) {
        full.add(byDay[i]!);
      } else {
        // Find nearest AI day before this one to match theme
        full.add(
          DayPlan(
            dayNumber: i,
            date: startDate.add(Duration(days: i - 1)),
            tasks: [
              ScheduledTask(
                id: 'fill_${i}_0',
                title: 'Review & Practice',
                description:
                    'Revisit yesterday\'s topics and practice with exercises.',
              ),
              ScheduledTask(
                id: 'fill_${i}_1',
                title: 'Solve Practice Questions',
                description:
                    'Apply what you\'ve learned with sample questions or problems.',
              ),
            ],
          ),
        );
      }
    }
    return full;
  }
}
