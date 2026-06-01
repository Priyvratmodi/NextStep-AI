import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_path_finder/models/schedule_models.dart';

class ScheduleStorageService {
  static const _key = 'career_schedule';

  static Future<void> saveSchedule(CareerSchedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, schedule.toJsonString());
  }

  static Future<CareerSchedule?> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CareerSchedule.fromJsonString(raw);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> hasSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }
}
