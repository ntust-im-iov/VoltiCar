// 事件基類
abstract class ViewEvent {
  const ViewEvent();
}

// 觀察者接口
abstract class EventObserver {
  void notify(ViewEvent event);
}

// 事件可觀察類
abstract class EventViewModel {
  final List<EventObserver> _observers = [];

  void subscribe(EventObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  void unsubscribe(EventObserver observer) {
    _observers.remove(observer);
  }

  void notify(ViewEvent event) {
    for (var observer in _observers) {
      observer.notify(event);
    }
  }
}
