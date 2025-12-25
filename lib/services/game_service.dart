import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  static const String _recordKey = 'game_record';

  Future<int> loadRecord() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_recordKey) ?? 0;
  }

  Future<void> saveRecord(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_recordKey, score);
  }
}

