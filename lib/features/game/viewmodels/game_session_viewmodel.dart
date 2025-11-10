import 'package:flutter/material.dart';
import '../models/game_session_summary_model.dart';
import '../repositories/game_session_repository.dart';

class GameSessionViewModel extends ChangeNotifier {
  final GameSessionRepository _gameSessionRepository;

  GameSessionSummary? _summary;
  bool _isLoading = false;
  String? _error;

  GameSessionViewModel({GameSessionRepository? gameSessionRepository})
      : _gameSessionRepository =
            gameSessionRepository ?? GameSessionRepository();

  GameSessionSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canStartGame => _summary?.canStartGame ?? false;

  Future<void> fetchGameSessionSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _summary = await _gameSessionRepository.getGameSessionSummary();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
