import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/timer_session.dart';

class TimerService {
  static const String _sessionsKey = 'timer_sessions';
  static const String _todayDateKey = 'time_today_date';

  Future<List<TimerSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null) {
      final List<dynamic> decoded = json.decode(sessionsJson);
      return decoded.map((item) => TimerSession.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveSessions(List<TimerSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson =
        json.encode(sessions.map((session) => session.toJson()).toList());
    await prefs.setString(_sessionsKey, sessionsJson);
  }

  Future<int> loadTodayTime() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'time_today_${today.year}_${today.month}_${today.day}';

    final savedDate = prefs.getString(_todayDateKey);
    final todayString = '${today.year}_${today.month}_${today.day}';

    if (savedDate != todayString) {
      await prefs.setString(_todayDateKey, todayString);
      await prefs.setInt(todayKey, 0);
      return 0;
    }

    return prefs.getInt(todayKey) ?? 0;
  }

  Future<void> saveTodayTime(int totalTimeToday) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'time_today_${today.year}_${today.month}_${today.day}';
    final todayString = '${today.year}_${today.month}_${today.day}';

    await prefs.setInt(todayKey, totalTimeToday);
    await prefs.setString(_todayDateKey, todayString);
  }

  int calculateTodayTime(List<TimerSession> sessions) {
    final today = DateTime.now();
    return sessions
        .where((session) =>
            session.endTime != null &&
            session.startTime.year == today.year &&
            session.startTime.month == today.month &&
            session.startTime.day == today.day)
        .fold(0, (sum, session) => sum + session.durationSeconds);
  }
}

