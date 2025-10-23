/// 計分管理器 - 管理遊戲分數、連擊、統計等
class ScoreManager {
  // 當前分數
  int _currentScore = 0;

  // 連擊數
  int _comboCount = 0;

  // 最高連擊數（本局）
  int _bestCombo = 0;

  // 遊戲時間（秒）
  double _gameTime = 0.0;

  // 事件統計
  int _totalEvents = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  // 每秒基礎分數
  static const int scorePerSecond = 5;

  // 連擊倍率
  static const Map<int, double> comboMultipliers = {
    0: 1.0,
    2: 1.2,
    3: 1.5,
    5: 2.0,
    10: 3.0,
  };

  /// 獲取當前分數
  int get currentScore => _currentScore;

  /// 獲取連擊數
  int get comboCount => _comboCount;

  /// 獲取最高連擊數
  int get bestCombo => _bestCombo;

  /// 獲取遊戲時間
  double get gameTime => _gameTime;

  /// 獲取總事件數
  int get totalEvents => _totalEvents;

  /// 獲取正確答案數
  int get correctAnswers => _correctAnswers;

  /// 獲取錯誤答案數
  int get wrongAnswers => _wrongAnswers;

  /// 獲取正確率
  double get accuracy {
    if (_totalEvents == 0) return 0.0;
    return (_correctAnswers / _totalEvents) * 100;
  }

  /// 獲取當前連擊倍率
  double get currentMultiplier {
    if (_comboCount >= 10) return comboMultipliers[10]!;
    if (_comboCount >= 5) return comboMultipliers[5]!;
    if (_comboCount >= 3) return comboMultipliers[3]!;
    if (_comboCount >= 2) return comboMultipliers[2]!;
    return comboMultipliers[0]!;
  }

  /// 更新遊戲時間並增加時間分數
  void updateGameTime(double dt) {
    _gameTime += dt;
    // 每秒增加基礎分數
    _currentScore += (scorePerSecond * dt).round();
  }

  /// 添加事件分數（答對）
  void addEventScore(int baseScore, bool isCorrect) {
    _totalEvents++;

    if (isCorrect) {
      _correctAnswers++;
      _comboCount++;

      // 更新最高連擊
      if (_comboCount > _bestCombo) {
        _bestCombo = _comboCount;
      }

      // 套用連擊倍率
      final multipliedScore = (baseScore * currentMultiplier).round();
      _currentScore += multipliedScore;
    } else {
      _wrongAnswers++;
      // 重置連擊
      _comboCount = 0;

      // 扣分（但不會扣到負分）
      _currentScore = (_currentScore + baseScore).clamp(0, 999999);
    }
  }

  /// 重置遊戲數據（開始新遊戲時）
  void reset() {
    _currentScore = 0;
    _comboCount = 0;
    _bestCombo = 0;
    _gameTime = 0.0;
    _totalEvents = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
  }

  /// 獲取遊戲統計摘要
  Map<String, dynamic> getGameSummary() {
    return {
      'score': _currentScore,
      'gameTime': _gameTime,
      'bestCombo': _bestCombo,
      'totalEvents': _totalEvents,
      'correctAnswers': _correctAnswers,
      'wrongAnswers': _wrongAnswers,
      'accuracy': accuracy,
    };
  }
}
