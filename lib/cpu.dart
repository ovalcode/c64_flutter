import 'dart:typed_data';

import 'memory.dart';

class Cpu {
  final Memory memory;
  int _a = 0, _x = 0, _y = 0;
  int pc = 0;
  Cpu({required this.memory});

  int getAcc() {
    return _a;
  }

  int getX() {
    return _x;
  }

  int getY() {
    return _y;
  }

  step() {
    var opCode = memory.getMem(pc);
    pc++;
    switch (opCode) {
      case 0xa9:
        _a = memory.getMem(pc);
        pc++;
      case 0x8d:
        var arg1 = memory.getMem(pc);
        pc++;
        var arg2 = memory.getMem(pc);
        pc++;
        memory.setMem(_a, (arg2 << 8) | arg1);
    }
  }
}