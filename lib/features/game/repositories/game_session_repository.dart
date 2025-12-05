import '../models/game_session_summary_model.dart';
import '../services/game_session_service.dart';

class GameSessionRepository {
  final GameSessionService service = GameSessionService();

  /// 取得遊戲會話摘要
  Future<GameSessionSummary> getGameSessionSummary() async {
    return await service.fetchGameSessionSummary();
  }
}
