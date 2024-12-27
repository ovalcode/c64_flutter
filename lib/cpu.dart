import 'dart:typed_data';

import 'package:c64_flutter/cpu_tables.dart';

import 'memory.dart';

enum AddressMode {
  implied,
  /* 0 */
  accumulator,
  /* 1 */
  immediate,
  /* 2 */
  zeroPage,
  /* 3 */
  zeroPageX,
  /* 4 */
  zeroPageY,
  /* 5 */
  relative,
  /* 6 */
  absolute,
  /* 7 */
  absoluteX,
  /* 8 */
  absoluteY,
  /* 9 */
  indirect,
  /* 10 */
  indexedIndirect,
  /* 11 */
  indirectIndexed /* 12 */
}

class Cpu {
  final Memory memory;

  int calculateEffectiveAddress(int mode, int operand1, int operand2) {
    var modeAsEnum = AddressMode.values[mode];
    switch (modeAsEnum) {
      case AddressMode.zeroPage:
        return operand1;
      case AddressMode.implied:
      // TODO: Handle this case.
      case AddressMode.accumulator:
      // TODO: Handle this case.
      case AddressMode.immediate:
      // TODO: Handle this case.
      case AddressMode.zeroPageX:
        return (operand1 + _x) & 0xff;
      case AddressMode.zeroPageY:
        return (operand1 + _y) & 0xff;
      case AddressMode.relative:
      // TODO: Handle this case.
      case AddressMode.absolute:
        return (operand2 << 8) | operand1;
      case AddressMode.absoluteX:
        var add = (operand2 << 8) | operand1;
        return (add + _x) & 0xffff;
      case AddressMode.absoluteY:
        var add = (operand2 << 8) | operand1;
        return (add + _y) & 0xffff;
      case AddressMode.indirect:
      // TODO: Handle this case.
      case AddressMode.indexedIndirect: // LDA ($40,X)
        var add = operand1 + _x;
        var readByte0 = memory.getMem(add & 0xff);
        var readByte1 = memory.getMem((add + 1) & 0xff);
        return (readByte1 << 8) | readByte0;
      case AddressMode.indirectIndexed: // LDA ($40),Y
        var readByte0 = memory.getMem(operand1 & 0xff);
        var readByte1 = memory.getMem((operand1 + 1) & 0xff);
        var result = (readByte1 << 8) | readByte0;
        return (result + _y) & 0xffff;
    }
    return 0;
  }

  int _a = 0, _x = 0, _y = 0;
  bool _n = false, _z = false;
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

  bool getN() {
    return _n;
  }

  bool getZ() {
    return _z;
  }

  step() {
    var opCode = memory.getMem(pc);
    pc++;
    var insLen = CpuTables.instructionLen[opCode];
    var arg0 = 0;
    var arg1 = 0;
    if (insLen > 1) {
      arg0 = memory.getMem(pc);
      pc++;
    }
    if (insLen > 2) {
      arg1 = memory.getMem(pc);
      pc++;
    }
    var resolvedAddress = calculateEffectiveAddress(
        CpuTables.addressModes[opCode], arg0, arg1);
    switch (opCode) {
      /*
        Zero Page     LDA $44       $A5  2   3
        Zero Page,X   LDA $44,X     $B5  2   4
        Absolute      LDA $4400     $AD  3   4
        Absolute,X    LDA $4400,X   $BD  3   4+
        Absolute,Y    LDA $4400,Y   $B9  3   4+
        Indirect,X    LDA ($44,X)   $A1  2   6
        Indirect,Y    LDA ($44),Y   $B1  2   5+
    */
      case 0xa9:
        _a = arg0;
        _n = (_a & 0x80) != 0;
        _z = _a == 0;
      case 0xB5:
      case 0xAD:
      case 0xBD:
      case 0xB9:
      case 0xA1:
      case 0xB1:
        _a = memory.getMem(resolvedAddress);
        _n = (_a & 0x80) != 0;
        _z = _a == 0;

/*
LDX (LoaD X register)
Affects Flags: N Z

MODE           SYNTAX       HEX LEN TIM
Immediate     LDX #$44      $A2  2   2
Zero Page     LDX $44       $A6  2   3
Zero Page,Y   LDX $44,Y     $B6  2   4
Absolute      LDX $4400     $AE  3   4
Absolute,Y    LDX $4400,Y   $BE  3   4+

 */
      case 0xA2:
        _x = arg0;
        _n = (_x & 0x80) != 0;
        _z = _x == 0;
      case 0xA6:
      case 0xB6:
      case 0xAE:
      case 0xBE:
        _x = memory.getMem(resolvedAddress);
        _n = (_x & 0x80) != 0;
        _z = _x == 0;

      /*
      LDY (LoaD Y register)
Affects Flags: N Z

MODE           SYNTAX       HEX LEN TIM
Immediate     LDY #$44      $A0  2   2
Zero Page     LDY $44       $A4  2   3
Zero Page,X   LDY $44,X     $B4  2   4
Absolute      LDY $4400     $AC  3   4
Absolute,X    LDY $4400,X   $BC  3   4+

       */
      case 0xA0:
        _y = arg0;
        _n = (_y & 0x80) != 0;
        _z = _y == 0;
      case 0xA4:
      case 0xB4:
      case 0xAC:
      case 0xBC:
        _y = memory.getMem(resolvedAddress);
        _n = (_y & 0x80) != 0;
        _z = _y == 0;

      /*
        STA (STore Accumulator)
Affects Flags: none

MODE           SYNTAX       HEX LEN TIM
Zero Page     STA $44       $85  2   3
Zero Page,X   STA $44,X     $95  2   4
Absolute      STA $4400     $8D  3   4
Absolute,X    STA $4400,X   $9D  3   5
Absolute,Y    STA $4400,Y   $99  3   5
Indirect,X    STA ($44,X)   $81  2   6
Indirect,Y    STA ($44),Y   $91  2   6
         */
      case 0x85:
      case 0x95:
      case 0x8D:
      case 0x9D:
      case 0x99:
      case 0x81:
      case 0x91:
        memory.setMem(_a, resolvedAddress);

      /*
        STX (STore X register)
Affects Flags: none

MODE           SYNTAX       HEX LEN TIM
Zero Page     STX $44       $86  2   3
Zero Page,Y   STX $44,Y     $96  2   4
Absolute      STX $4400     $8E  3   4

         */
      case 0x86:
      case 0x96:
      case 0x8E:
        memory.setMem(_x, resolvedAddress);

      /*
      STY (STore Y register)
Affects Flags: none

MODE           SYNTAX       HEX LEN TIM
Zero Page     STY $44       $84  2   3
Zero Page,X   STY $44,X     $94  2   4
Absolute      STY $4400     $8C  3   4
       */
      case 0x84:
      case 0x94:
      case 0x8C:
        memory.setMem(_y, resolvedAddress);
    }
  }
}
