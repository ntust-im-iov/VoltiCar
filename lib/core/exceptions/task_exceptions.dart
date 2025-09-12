/// 任務相關的自定義異常類別

/// 等級要求不足異常
/// 當玩家等級不符合任務要求時拋出此異常
class LevelRequirementException implements Exception {
  final String message;
  
  const LevelRequirementException(this.message);
  
  @override
  String toString() => message;
}

/// 任務已被接受異常
/// 當嘗試接受已經被接受的任務時拋出此異常
class TaskAlreadyAcceptedException implements Exception {
  final String message;
  
  const TaskAlreadyAcceptedException(this.message);
  
  @override
  String toString() => message;
}

/// 任務不存在異常
/// 當嘗試操作不存在的任務時拋出此異常
class TaskNotFoundException implements Exception {
  final String message;
  
  const TaskNotFoundException(this.message);
  
  @override
  String toString() => message;
}

/// 任務狀態錯誤異常
/// 當任務狀態不符合操作要求時拋出此異常
class InvalidTaskStateException implements Exception {
  final String message;
  
  const InvalidTaskStateException(this.message);
  
  @override
  String toString() => message;
}
