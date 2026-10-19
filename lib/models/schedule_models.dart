import 'dart:convert';

class ScheduledTask {
  String id;
  String title;
  String description;
  bool isCompleted;

  ScheduledTask({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  ScheduledTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return ScheduledTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
  };

  factory ScheduledTask.fromJson(Map<String, dynamic> json) => ScheduledTask(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: json['title'] ?? 'Task',
    description: json['description'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
  );
}

class DayPlan {
  int dayNumber;
  DateTime date;
  List<ScheduledTask> tasks;

  DayPlan({required this.dayNumber, required this.date, required this.tasks});

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  bool get isFullyComplete =>
      tasks.isNotEmpty && completedCount == tasks.length;

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'date': date.toIso8601String(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
    dayNumber: json['dayNumber'] ?? 0,
    date: DateTime.parse(json['date']),
    tasks: (json['tasks'] as List<dynamic>? ?? [])
        .map((t) => ScheduledTask.fromJson(t as Map<String, dynamic>))
        .toList(),
  );
}

class CareerSchedule {
  String roleTitle;
  String domainName;
  DateTime startDate;
  DateTime targetDate;
  double hoursPerDay;
  List<DayPlan> days;

  CareerSchedule({
    required this.roleTitle,
    required this.domainName,
    required this.startDate,
    required this.targetDate,
    required this.hoursPerDay,
    required this.days,
  });

  int get totalTasks => days.fold(0, (sum, d) => sum + d.tasks.length);
  int get completedTasks => days.fold(0, (sum, d) => sum + d.completedCount);
  double get progressPercent =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  /// Returns summary of completed tasks for re-calibration prompts
  String get completedTasksSummary {
    final completed = <String>[];
    for (final day in days) {
      for (final task in day.tasks) {
        if (task.isCompleted) completed.add(task.title);
      }
    }
    if (completed.isEmpty) return 'None yet';
    return completed.take(20).join(', ');
  }

  Map<String, dynamic> toJson() => {
    'roleTitle': roleTitle,
    'domainName': domainName,
    'startDate': startDate.toIso8601String(),
    'targetDate': targetDate.toIso8601String(),
    'hoursPerDay': hoursPerDay,
    'days': days.map((d) => d.toJson()).toList(),
  };

  factory CareerSchedule.fromJson(Map<String, dynamic> json) => CareerSchedule(
    roleTitle: json['roleTitle'] ?? '',
    domainName: json['domainName'] ?? '',
    startDate: DateTime.parse(json['startDate']),
    targetDate: DateTime.parse(json['targetDate']),
    hoursPerDay: (json['hoursPerDay'] as num?)?.toDouble() ?? 2.0,
    days: (json['days'] as List<dynamic>? ?? [])
        .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
        .toList(),
  );

  String toJsonString() => jsonEncode(toJson());
  factory CareerSchedule.fromJsonString(String s) =>
      CareerSchedule.fromJson(jsonDecode(s));
}
