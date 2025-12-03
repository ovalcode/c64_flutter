import 'dart:collection';

final class Alarm extends LinkedListEntry<Alarm> {
  var _targetClock = 0;
  late final Alarms _alarms;
  late final Function(int remainder) _callback;

  Alarm._(Alarms alarms, Function(int remainder) callback ) {
    _alarms = alarms;
    _callback = callback;
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

  Alarms();

  Alarm addAlarm(Function(int remainder) callback) {
    var alarm = Alarm._(this, callback);
    _alarmList.add(alarm);
    return alarm;
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
  }
}