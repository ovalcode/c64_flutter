import 'dart:collection';

final class Alarm extends LinkedListEntry<Alarm> {
  var _targetClock = 0;
  late final Alarms _alarms;
  late final Function(int remainder) _callback;

  Alarm._(Alarms alarms, Function(int remainder) callback ) {
    _alarms = alarms;
    _callback = callback;
  }

  markForUnlinking() {
    _alarms.markAlarmForRemoval(this);
  }

  setTicks(int ticks) {
    _targetClock = _alarms.getCurrentCpuCount() + ticks;
  }

  getRemainingTicks() {
    return _targetClock - _alarms.getCurrentCpuCount();
  }

  getTargetClock() {
    return _targetClock;
  }

  processAlarm(int remainder) {
    _callback(remainder);
  }
}

class Alarms {
  final LinkedList<Alarm> _alarmList = LinkedList<Alarm>();
  int _cpuCount = 0;
  final List<Alarm> _toRemove = [];

  Alarms();

  Alarm addAlarm(Function(int remainder) callback) {
    var alarm = Alarm._(this, callback);
    _alarmList.add(alarm);
    return alarm;
  }

  markAlarmForRemoval(Alarm alarm) {
    _toRemove.add(alarm);
  }

  removeAlarms() {
    for (var alarm in _toRemove) {
      alarm.unlink();
    }
    _toRemove.clear();
  }

  reAddAlarm(Alarm alarm) {
    _alarmList.add(alarm);
  }

  int getCurrentCpuCount() {
    return _cpuCount;
  }

  processAlarms(int cpuCycles) {
    _cpuCount = cpuCycles;
    for (Alarm item in _alarmList) {
      if (item.getRemainingTicks() <= 0) {
        item.processAlarm(item.getRemainingTicks());
      }
    }
    removeAlarms();
  }
}