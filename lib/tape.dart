import 'dart:typed_data' as type_data;

import 'package:c64_flutter/cia1.dart';

import 'alarms.dart';

abstract class TapeMemoryInterface {
  setMotor(bool on);
  int getCassetteSense();
}

class Tape implements TapeMemoryInterface {
  late Iterator _tapeImage;
  bool _playSelected = false;
  Alarms alarms;
  TapeInterrupt interrupt;
  Alarm? _tapeAlarm;
  bool _currentMotorOn = false;
  int _remainingPulseTicks = 0;

  Tape({required this.alarms, required this.interrupt});

  setTapeImage(type_data.Uint8List tapeData) {
    _tapeImage = tapeData.iterator;
    for (var i = 0; i < 21; i++) {
      _tapeImage.moveNext();
    }
    populateRemainingPulses();
  }

  populateRemainingPulses() {
    var val = _tapeImage.current;
    if (val != 0) {
      _remainingPulseTicks = val << 3;
      _tapeImage.moveNext();
    } else {
      _tapeImage.moveNext();
      var byte0 = _tapeImage.current;
      _tapeImage.moveNext();
      var byte1 = _tapeImage.current;
      _tapeImage.moveNext();
      var byte2 = _tapeImage.current;
      _tapeImage.moveNext();
      _remainingPulseTicks = (byte2 << 16) | (byte1 << 8) | byte0;
    }
  }

  playTape() {
    _playSelected = true;
    // var val = _tapeImage.current;
    // print(val);
  }

  processTapeAlarm(int remaining) {
    interrupt.triggerInterrupt();
    populateRemainingPulses();
    _tapeAlarm!.setTicks(_remainingPulseTicks + remaining);
  }

  setupAlarms() {
    _tapeAlarm ??= alarms.addAlarm( (remaining) => processTapeAlarm(remaining));
    if (_tapeAlarm!.list == null) {
      alarms.reAddAlarm(_tapeAlarm!);
    }
    _tapeAlarm!.setTicks(_remainingPulseTicks);
  }

  @override
  int getCassetteSense() {
    return _playSelected ? 0 : 0x10;
  }

  @override
  setMotor(bool on) {
    if (on == _currentMotorOn) {
      return;
    }
    _currentMotorOn = on;
    if (on) {
      setupAlarms();
    } else {
      _tapeAlarm!.unlink();
      _remainingPulseTicks = _tapeAlarm?.getRemainingTicks();
    }
  }
}