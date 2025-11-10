import 'package:shared_preferences/shared_preferences.dart';

/// 遊戲數據本地存儲管理器
class GameStorageManager {
  static const String _keyHighestScore = 'game_highest_score';
  static const String _keyTotalGames = 'game_total_games';
  static const String _keyTotalEvents = 'game_total_events';
  static const String _keyTotalCorrect = 'game_total_correct';
  static const String _keyBestCombo = 'game_best_combo';
  static const String _keyTotalPlayTime = 'game_total_play_time';
  static const String _keyLastScore = 'game_last_score';

  /// 獲取 SharedPreferences 實例
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// 保存遊戲結果
  Future<void> saveGameResult({
    required int score,
    required int eventsAnswered,
    required int correctAnswers,
    required int bestCombo,
    required double playTime,
  }) async {
    final prefs = await _getPrefs();

    // 更新最高分
    final currentHighest = prefs.getInt(_keyHighestScore) ?? 0;
    if (score > currentHighest) {
      await prefs.setInt(_keyHighestScore, score);
    }

    // 更新總局數
    final totalGames = (prefs.getInt(_keyTotalGames) ?? 0) + 1;
    await prefs.setInt(_keyTotalGames, totalGames);

    // 更新總事件數
    final totalEvents = (prefs.getInt(_keyTotalEvents) ?? 0) + eventsAnswered;
    await prefs.setInt(_keyTotalEvents, totalEvents);

    // 更新總正確答案數
    final totalCorrect = (prefs.getInt(_keyTotalCorrect) ?? 0) + correctAnswers;
    await prefs.setInt(_keyTotalCorrect, totalCorrect);

    // 更新最佳連擊
    final currentBestCombo = prefs.getInt(_keyBestCombo) ?? 0;
    if (bestCombo > currentBestCombo) {
      await prefs.setInt(_keyBestCombo, bestCombo);
    }

    // 更新總遊戲時間
    final totalPlayTime =
        (prefs.getDouble(_keyTotalPlayTime) ?? 0.0) + playTime;
    await prefs.setDouble(_keyTotalPlayTime, totalPlayTime);

    // 保存最後一局分數
    await prefs.setInt(_keyLastScore, score);
  }

  /// 獲取最高分
  Future<int> getHighestScore() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyHighestScore) ?? 0;
  }

  /// 獲取總局數
  Future<int> getTotalGames() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyTotalGames) ?? 0;
  }

  /// 獲取總事件數
  Future<int> getTotalEvents() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyTotalEvents) ?? 0;
  }

  /// 獲取總正確答案數
  Future<int> getTotalCorrectAnswers() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyTotalCorrect) ?? 0;
  }

  /// 獲取最佳連擊
  Future<int> getBestCombo() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyBestCombo) ?? 0;
  }

  /// 獲取總遊戲時間
  Future<double> getTotalPlayTime() async {
    final prefs = await _getPrefs();
    return prefs.getDouble(_keyTotalPlayTime) ?? 0.0;
  }

  /// 獲取上一局分數
  Future<int> getLastScore() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyLastScore) ?? 0;
  }

  /// 獲取整體正確率
  Future<double> getOverallAccuracy() async {
    final totalEvents = await getTotalEvents();
    if (totalEvents == 0) return 0.0;

    final totalCorrect = await getTotalCorrectAnswers();
    return (totalCorrect / totalEvents) * 100;
  }

  /// 獲取所有統計數據
  Future<Map<String, dynamic>> getAllStats() async {
    return {
      'highestScore': await getHighestScore(),
      'totalGames': await getTotalGames(),
      'totalEvents': await getTotalEvents(),
      'totalCorrect': await getTotalCorrectAnswers(),
      'bestCombo': await getBestCombo(),
      'totalPlayTime': await getTotalPlayTime(),
      'lastScore': await getLastScore(),
      'accuracy': await getOverallAccuracy(),
    };
  }

  /// 重置所有數據（僅用於測試或重置功能）
  Future<void> resetAllData() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyHighestScore);
    await prefs.remove(_keyTotalGames);
    await prefs.remove(_keyTotalEvents);
    await prefs.remove(_keyTotalCorrect);
    await prefs.remove(_keyBestCombo);
    await prefs.remove(_keyTotalPlayTime);
    await prefs.remove(_keyLastScore);
  }
}
