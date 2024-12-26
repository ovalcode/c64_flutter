import 'dart:typed_data';

import 'package:c64_flutter/cpu_tables.dart';

import 'memory.dart';
enum AddressMode {
  implied,          /* 0 */
  accumulator,      /* 1 */
  immediate,        /* 2 */
  zeroPage,         /* 3 */
  zeroPageX,        /* 4 */
  zeroPageY,        /* 5 */
  relative,         /* 6 */
  absolute,         /* 7 */
  absoluteX,        /* 8 */
  absoluteY,        /* 9 */
  indirect,         /* 10 */
  indexedIndirect,  /* 11 */
  indirectIndexed   /* 12 */
}

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