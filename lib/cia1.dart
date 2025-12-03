import 'dart:collection';

import 'package:c64_flutter/alarms.dart';

import 'c64_bloc.dart';

class Cia1 {
  int timerAlatchLow = 0xff;
  int timerAlatchHigh = 0xff;
  int timerAvalue = 0xffff;
  Alarms alarms;
  Alarm? timerAalarm;
  bool timerAstarted = false;
  bool timerAoneshot = false;
  int registerE = 0;
  int register0 = 0;
  bool timerAinterruptEnabled = false;
  bool timerAintOccurred = false;
  late final KeyInfo keyInfo;


  Cia1({required this.alarms});

  setKeyInfo(KeyInfo keyInfo) {
    this.keyInfo = keyInfo;
  }

/*
  processTimerAEvent() {
    
  }
*/

  updateTimerA() {
    if (!timerAstarted) {
       return;
    }
    if (timerAalarm != null) {
      timerAvalue = timerAalarm!.getRemainingTicks();
    }

  }

  hasInterrupts() {
    if (timerAintOccurred && timerAinterruptEnabled) {
      return true;
    } else {
      return false;
    }
  }

  processTimerAalarm(int remaining) {
    // Do interrupt
    timerAintOccurred = true;
    if (timerAoneshot) {
      timerAalarm?.unlink();
      timerAstarted = false;
      return;
    }
    timerAalarm!.setTicks((timerAlatchLow | (timerAlatchHigh << 8)) + remaining);
  }

  setMem(int address, int value) {
    print("setMem ${address.toRadixString(16)} ${value.toRadixString(16)}");
    value = value & 0xff;
    address = address & 0xf;
    switch (address) {
      case 0x0:
        register0 = value;
      case 0x4:
        timerAlatchLow = value;
      case 0x5:
        timerAlatchHigh = value;
      case 0xD:
        if ((value & 0x80) != 0) {
          timerAinterruptEnabled = ((value & 1) == 1) ? true : timerAinterruptEnabled;
        } else {
          timerAinterruptEnabled = ((value & 1) == 1) ? false : timerAinterruptEnabled;
        }
      case 0xE:
        // update timer
        // NB!! only get alarm instance when you start a timer
        // if stop timer remove from queue
        // if start timer ......
        // if timer starts or timer is started and forced
        // schedule new timer
        var startTimerA = ((value & 1) == 1) ? true : false;
        var forceTimerA = ((value & 16) != 0) ? true : false;
        updateTimerA();
        if (forceTimerA) {
          timerAvalue = timerAlatchLow | (timerAlatchHigh << 8);
        }
        var startingTimerA = startTimerA & !timerAstarted;
        var stoppingTimerA = !startTimerA & timerAstarted;
        var alreadyRunningTimerA = startTimerA && timerAstarted;
        if (startingTimerA || (alreadyRunningTimerA && forceTimerA)) {
          // schedule timer on alarm
          timerAalarm ??= alarms.addAlarm( (remaining) => processTimerAalarm(remaining));
          if (timerAalarm!.list == null) {
            alarms.reAddAlarm(timerAalarm!);
          }
          timerAalarm!.setTicks(timerAvalue);
          // set timer as started
        } else if (stoppingTimerA) {
          //unschedule timer A
          timerAalarm!.unlink();
        }
        timerAoneshot = (value & 8) != 0;
        timerAstarted = startTimerA;
        registerE = value;
      default:
        // throw "Not implemented";
    }

  }

  int getMem(int address) {
    print("getMem ${address.toRadixString(16)}");
    updateTimerA();
    address = address & 0xf;
    switch (address) {
      case 0x0:
        return register0;
      case 0x1:
        return keyInfo.getKeyInfo(register0);
      case 0x4:
        return timerAvalue & 0xff;
      case 0x5:
        return timerAvalue >> 8;
      case 0xD:
        if (timerAintOccurred) {
          timerAintOccurred = false;
          return 0x81;
        } else {
          return 0;
        }
      case 0xE:
        var result = registerE & 0x06;
        result = result | (timerAstarted ? 1 : 0);
        result = result | (timerAoneshot ? 8 : 0);
        return result;
    }
    return 255;
  }
}
/*
class Cia1 {
  int timerA = 0xffff;
  int timerAlatchLow = 0xff;
  int timerAlatchHigh = 0xff;
  int registerE = 0;
  late final Alarms alarms;

  // Cia1({required alarms});

  setMem(int address, int value) {
    value = value & 0xff;
    address = address & 0xf;
    switch (address) {
      case 0x4:
        timerAlatchLow = value;
      case 0x5:
        timerAlatchHigh = value;
      case 0xE:
        registerE = value;
      default:
        throw "Not implemented";
    }
  }

  int getMem(int address) {
    address = address & 0xf;
    switch (address) {
      case 0x4:
        return timerA & 0xff;
      case 0x5:
        return (timerA >> 8) & 0xff;
      case 0xE:
        return registerE & 0xEF;

      default:
        throw "Not implemented";
    }
    return 0;
  }
}
*/
