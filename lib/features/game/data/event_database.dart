import '../models/game_event.dart';

/// 遊戲事件資料庫
class EventDatabase {
  static final List<GameEvent> _allEvents = [
    // ========== 正面事件 (5個) ==========
    GameEvent(
      id: 'positive_1',
      type: EventType.positive,
      title: '發現綠能充電站',
      description: '前方有使用太陽能供電的充電站！',
      options: [
        EventOption(text: '立即使用綠能充電', isCorrect: true, scoreReward: 80),
        EventOption(text: '繼續前進', isCorrect: false, scoreReward: 20),
      ],
      correctFeedback: '太棒了！使用綠能充電站，為環保盡一份力！',
      wrongFeedback: '使用綠能充電站可以支持再生能源發展喔！',
    ),

    GameEvent(
      id: 'positive_2',
      type: EventType.positive,
      title: '環保駕駛達成',
      description: '你的平穩駕駛減少了 15% 的能源消耗！',
      options: [
        EventOption(text: '繼續保持', isCorrect: true, scoreReward: 80),
      ],
      correctFeedback: '優秀的駕駛習慣！保持平穩駕駛最環保！',
      wrongFeedback: '',
    ),

    GameEvent(
      id: 'positive_3',
      type: EventType.positive,
      title: '碳足跡減少獎勵',
      description: '相比燃油車，你已減少 5kg 碳排放！',
      options: [
        EventOption(text: '領取環保獎勵', isCorrect: true, scoreReward: 80),
      ],
      correctFeedback: '每一公里的電動行駛，都在為地球降溫！',
      wrongFeedback: '',
    ),

    GameEvent(
      id: 'positive_4',
      type: EventType.positive,
      title: '再生能源加成',
      description: '使用再生煞車回收了額外電能！',
      options: [
        EventOption(text: '太棒了！', isCorrect: true, scoreReward: 80),
      ],
      correctFeedback: '再生煞車讓能源不浪費，環保又省電！',
      wrongFeedback: '',
    ),

    GameEvent(
      id: 'positive_5',
      type: EventType.positive,
      title: '環保里程碑',
      description: '你的環保行駛已等同於種植 3 棵樹！',
      options: [
        EventOption(text: '繼續努力', isCorrect: true, scoreReward: 80),
      ],
      correctFeedback: '持續使用電動車，就像在種植希望之樹！',
      wrongFeedback: '',
    ),

    // ========== 中性事件 (7個) ==========
    GameEvent(
      id: 'neutral_1',
      type: EventType.neutral,
      title: '電動車充電知識',
      description: '哪種充電方式對電池最友善？',
      options: [
        EventOption(text: '慢充（AC 充電）', isCorrect: true, scoreReward: 100),
        EventOption(text: '快充（DC 充電）', isCorrect: false, scoreReward: -30),
        EventOption(text: '都一樣', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！慢充對電池壽命較好，雖然快充方便，但建議日常使用慢充。',
      wrongFeedback: '正確答案是「慢充（AC 充電）」。慢充對電池壽命較好，雖然快充方便，但建議日常使用慢充以延長電池壽命。',
    ),

    GameEvent(
      id: 'neutral_2',
      type: EventType.neutral,
      title: '節能駕駛技巧',
      description: '以下哪個做法最省電？',
      options: [
        EventOption(text: '頻繁加速減速', isCorrect: false, scoreReward: -30),
        EventOption(text: '保持穩定速度', isCorrect: true, scoreReward: 100),
        EventOption(text: '高速行駛', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！保持穩定速度可以最大化電動車的續航里程，減少不必要的能源消耗。',
      wrongFeedback: '正確答案是「保持穩定速度」。保持穩定速度可以最大化電動車的續航里程，減少不必要的能源消耗。',
    ),

    GameEvent(
      id: 'neutral_3',
      type: EventType.neutral,
      title: '碳排放認知',
      description: '電動車相比燃油車，平均可減少多少碳排放？',
      options: [
        EventOption(text: '約 30%', isCorrect: false, scoreReward: -30),
        EventOption(text: '約 50%', isCorrect: true, scoreReward: 100),
        EventOption(text: '約 70%', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！考慮整體生命週期，電動車可減少約 50% 的碳排放。',
      wrongFeedback: '正確答案是「約 50%」。考慮整體生命週期，電動車可減少約 50% 的碳排放，對環境更友善。',
    ),

    GameEvent(
      id: 'neutral_4',
      type: EventType.neutral,
      title: '電池回收知識',
      description: '電動車電池報廢後應該如何處理？',
      options: [
        EventOption(text: '直接丟棄', isCorrect: false, scoreReward: -30),
        EventOption(text: '回收再利用', isCorrect: true, scoreReward: 100),
        EventOption(text: '焚燒處理', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！電動車電池可以回收再利用於儲能系統，實現循環經濟。',
      wrongFeedback: '正確答案是「回收再利用」。電動車電池可以回收再利用於儲能系統，實現循環經濟，不應隨意丟棄。',
    ),

    GameEvent(
      id: 'neutral_5',
      type: EventType.neutral,
      title: '再生煞車原理',
      description: '電動車的再生煞車可以做什麼？',
      options: [
        EventOption(text: '讓車子更快', isCorrect: false, scoreReward: -30),
        EventOption(text: '回收動能轉換成電能', isCorrect: true, scoreReward: 100),
        EventOption(text: '減少輪胎磨損', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！再生煞車將動能轉換回電能儲存，提升能源效率。',
      wrongFeedback: '正確答案是「回收動能轉換成電能」。再生煞車將動能轉換回電能儲存，提升能源效率，這是電動車的重要優勢。',
    ),

    GameEvent(
      id: 'neutral_6',
      type: EventType.neutral,
      title: '充電時機選擇',
      description: '什麼時候充電對環境最友善？',
      options: [
        EventOption(text: '尖峰用電時段', isCorrect: false, scoreReward: -30),
        EventOption(text: '離峰時段（夜間）', isCorrect: true, scoreReward: 100),
        EventOption(text: '隨時充電都一樣', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！離峰時段充電可減輕電網負擔，且通常使用較多再生能源。',
      wrongFeedback: '正確答案是「離峰時段（夜間）」。離峰時段充電可減輕電網負擔，且通常使用較多再生能源，對環境更友善。',
    ),

    GameEvent(
      id: 'neutral_7',
      type: EventType.neutral,
      title: '電動車環保迷思',
      description: '電動車的電力來源若是火力發電，還環保嗎？',
      options: [
        EventOption(text: '不環保', isCorrect: false, scoreReward: -30),
        EventOption(text: '依然比燃油車環保', isCorrect: true, scoreReward: 100),
        EventOption(text: '完全沒差別', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！即使使用火力發電，電動車的整體效率仍優於燃油車，碳排放更低。',
      wrongFeedback: '正確答案是「依然比燃油車環保」。即使使用火力發電，電動車的整體效率仍優於燃油車，碳排放更低。',
    ),

    // ========== 負面事件 (3個) ==========
    GameEvent(
      id: 'negative_1',
      type: EventType.negative,
      title: '電量低警告',
      description: '電量剩餘 10%！應該採取什麼行動？',
      options: [
        EventOption(text: '立即尋找充電站', isCorrect: true, scoreReward: 120),
        EventOption(text: '繼續行駛', isCorrect: false, scoreReward: -30),
        EventOption(text: '開啟節能模式', isCorrect: false, scoreReward: 60),
      ],
      correctFeedback: '正確！電量過低時應盡快充電，避免影響電池壽命。',
      wrongFeedback: '最佳答案是「立即尋找充電站」。電量過低時應盡快充電，避免影響電池壽命和行車安全。',
    ),

    GameEvent(
      id: 'negative_2',
      type: EventType.negative,
      title: '非環保駕駛習慣',
      description: '偵測到急加速和急煞車，能源效率降低 20%！如何改善？',
      options: [
        EventOption(text: '不理會', isCorrect: false, scoreReward: -30),
        EventOption(text: '調整為平穩駕駛', isCorrect: true, scoreReward: 120),
        EventOption(text: '繼續保持', isCorrect: false, scoreReward: -30),
      ],
      correctFeedback: '正確！平穩駕駛不僅省電，也能延長車輛使用壽命。',
      wrongFeedback: '正確答案是「調整為平穩駕駛」。平穩駕駛不僅省電，也能延長車輛使用壽命，是最環保的駕駛方式。',
    ),

    GameEvent(
      id: 'negative_3',
      type: EventType.negative,
      title: '充電站選擇',
      description: '有兩個充電站可選：一個使用綠能，一個使用傳統電力。你會選擇？',
      options: [
        EventOption(text: '綠能充電站（較遠）', isCorrect: true, scoreReward: 120),
        EventOption(text: '傳統充電站（較近）', isCorrect: false, scoreReward: 50),
      ],
      correctFeedback: '很好！選擇綠能充電站雖然較遠，但對環境更友善。',
      wrongFeedback: '最佳選擇是「綠能充電站（較遠）」。雖然較遠，但選擇綠能充電站可以支持再生能源發展，對環境更友善。',
    ),
  ];

  /// 獲取所有事件
  static List<GameEvent> getAllEvents() {
    return List.from(_allEvents);
  }

  /// 根據類型獲取事件
  static List<GameEvent> getEventsByType(EventType type) {
    return _allEvents.where((event) => event.type == type).toList();
  }

  /// 隨機獲取一個事件（根據權重）
  /// 正面事件：30%，中性事件：50%，負面事件：20%
  static GameEvent getRandomEvent() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;

    EventType selectedType;
    if (random < 30) {
      selectedType = EventType.positive;
    } else if (random < 80) {
      selectedType = EventType.neutral;
    } else {
      selectedType = EventType.negative;
    }

    final eventsOfType = getEventsByType(selectedType);
    final index = DateTime.now().microsecondsSinceEpoch % eventsOfType.length;
    return eventsOfType[index];
  }
}
