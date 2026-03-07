import 'dart:collection';

import 'package:c64_flutter/alarms.dart';

import 'emulator_controller.dart';

abstract class TapeInterrupt {
  triggerInterrupt();
}

class Cia1 implements TapeInterrupt {
  int timerAlatchLow = 0xff;
  int timerAlatchHigh = 0xff;
  int timerAvalue = 0xffff;
  int timerBlatchLow = 0xff;
  int timerBlatchHigh = 0xff;
  int timerBvalue = 0xffff;
  Alarms alarms;
  Alarm? timerAalarm;
  bool timerAstarted = false;
  bool timerAoneshot = false;
  Alarm? timerBalarm;
  bool timerBstarted = false;
  bool timerBoneshot = false;
  int registerE = 0;
  int registerF = 0;
  int register0 = 0;
  bool timerAinterruptEnabled = false;
  bool timerAintOccurred = false;
  bool timerBinterruptEnabled = false;
  bool timerBintOccurred = false;
  bool tapeInterruptEnabled = false;
  bool tapeInterruptOccurred = false;
  late final KeyInfo keyInfo;


  Cia1({required this.alarms});

  setKeyInfo(KeyInfo keyInfo) {
    this.keyInfo = keyInfo;
  }

  updateTimerA() {
    if (!timerAstarted) {
       return;
    }
    if (timerAalarm != null) {
      timerAvalue = timerAalarm!.getRemainingTicks();
    }

  }

  updateTimerB() {
    if (!timerBstarted) {
       return;
    }
    if (timerBalarm != null) {
      timerBvalue = timerBalarm!.getRemainingTicks();
    }

  }

  hasInterrupts() {
    if (timerAintOccurred && timerAinterruptEnabled) {
      return true;
    } else if (timerBintOccurred && timerBinterruptEnabled) {
      return true;
    } else if (tapeInterruptOccurred && tapeInterruptEnabled) {
      return true;
    } else {
      return false;
    }
  }

  processTimerAalarm(int remaining) {
    // Do interrupt
    timerAintOccurred = true;
    if (timerAoneshot) {
      timerAalarm?.markForUnlinking();
      timerAstarted = false;
      return;
    }
    timerAalarm!.setTicks((timerAlatchLow | (timerAlatchHigh << 8)) + remaining);
  }

  processTimerBalarm(int remaining) {
    // Do interrupt
    timerBintOccurred = true;
    if (timerBoneshot) {
      timerBalarm?.markForUnlinking();
      timerBstarted = false;
      return;
    }
    timerBalarm!.setTicks((timerBlatchLow | (timerBlatchHigh << 8)) + remaining);
  }

  setMem(int address, int value) {
    value = value & 0xff;
    address = address & 0xf;
    switch (address) {
      case 0x0:
        register0 = value;
      case 0x4:
        timerAlatchLow = value;
      case 0x5:
        timerAlatchHigh = value;
      case 0x6:
        timerBlatchLow = value;
      case 0x7:
        timerBlatchHigh = value;
      case 0xD:
        if ((value & 0x80) != 0) {
          timerAinterruptEnabled = ((value & 1) == 1) ? true : timerAinterruptEnabled;
        } else {
          timerAinterruptEnabled = ((value & 1) == 1) ? false : timerAinterruptEnabled;
        }
        if ((value & 0x80) != 0) {
          timerBinterruptEnabled = ((value & 2) == 2) ? true : timerBinterruptEnabled;
        } else {
          timerBinterruptEnabled = ((value & 2) == 2) ? false : timerBinterruptEnabled;
        }
        if ((value & 0x80) != 0) {
          tapeInterruptEnabled = ((value & 16) == 16) ? true : tapeInterruptEnabled;
        } else {
          tapeInterruptEnabled = ((value & 16) == 16) ? false : tapeInterruptEnabled;
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
      case 0xF:
        // update timer
        // NB!! only get alarm instance when you start a timer
        // if stop timer remove from queue
        // if start timer ......
        // if timer starts or timer is started and forced
        // schedule new timer
        var startTimerB = ((value & 1) == 1) ? true : false;
        var forceTimerB = ((value & 16) != 0) ? true : false;
        updateTimerB();
        if (forceTimerB) {
          timerBvalue = timerBlatchLow | (timerBlatchHigh << 8);
        }
        var startingTimerB = startTimerB & !timerBstarted;
        var stoppingTimerB = !startTimerB & timerBstarted;
        var alreadyRunningTimerB = startTimerB && timerBstarted;
        if (startingTimerB || (alreadyRunningTimerB && forceTimerB)) {
          // schedule timer on alarm
          timerBalarm ??= alarms.addAlarm( (remaining) => processTimerBalarm(remaining));
          if (timerBalarm!.list == null) {
            alarms.reAddAlarm(timerBalarm!);
          }
          timerBalarm!.setTicks(timerBvalue);
          // set timer as started
        } else if (stoppingTimerB) {
          //unschedule timer B
          timerBalarm!.unlink();
        }
        timerBoneshot = (value & 8) != 0;
        timerBstarted = startTimerB;
        registerF = value;
      default:
        // throw "Not implemented";
    }

  }

  int getMem(int address) {
    // print("getMem ${address.toRadixString(16)}");
    updateTimerA();
    updateTimerB();
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
      case 0x6:
        return timerBvalue & 0xff;
      case 0x7:
        return timerBvalue >> 8;
      case 0xD:
        var value = 0;
        if (timerAintOccurred) {
          timerAintOccurred = false;
          value = value | 0x81;
        }
        if (timerBintOccurred) {
          timerBintOccurred = false;
          value = value | 0x82;
        }
        if (tapeInterruptOccurred) {
          tapeInterruptOccurred = false;
          value = value | 0x84;
        }
        return value;
      case 0xE:
        var result = registerE & 0x06;
        result = result | (timerAstarted ? 1 : 0);
        result = result | (timerAoneshot ? 8 : 0);
        return result;
      case 0xF:
        var result = registerF & 0x06;
        result = result | (timerBstarted ? 1 : 0);
        result = result | (timerBoneshot ? 8 : 0);
        return result;
    }
    return 255;
  }

  @override
  triggerInterrupt() {
    tapeInterruptOccurred = true;
  }
}
