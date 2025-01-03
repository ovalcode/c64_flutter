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

  int _n = 0, _z = 0, _c = 0, _i = 0, _d = 0, _v = 0;
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

  int getN() {
    return _n;
  }

  int getZ() {
    return _z;
  }

  int getC() {
    return _c;
  }

  int getI() {
    return _i;
  }

  int getD() {
    return _d;
  }

  int getV() {
    return _v;
  }

  void adc(int operand) {
    int temp = _a + operand + _c;
    _v = (((_a ^ temp) & (operand ^ temp) & 0x80) != 0) ? 1 : 0;
    _a = temp & 0xff;
    //N V Z C
    _n = ((_a & 0x80) == 0x80) ? 1 : 0;
    _z = (_a == 0) ? 1 : 0;
    _c = (temp & 0x100) != 0 ? 1 : 0;
  }

  void sbc(int operand) {
    operand = ~operand & 0xff;
    int temp = _a + operand + _c;
    _v = (((_a ^ temp) & (operand ^ temp) & 0x80) != 0) ? 1 : 0;
    _a = temp & 0xff;
    //N V Z C
    _n = ((_a & 0x80) == 0x80) ? 1 : 0;
    _z = (_a == 0) ? 1 : 0;
    _c = (temp & 0x100) != 0 ? 1 : 0;
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
    var resolvedAddress =
        calculateEffectiveAddress(CpuTables.addressModes[opCode], arg0, arg1);
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
        _n = ((_a & 0x80) != 0) ? 1 : 0;
        _z = (_a == 0) ? 1 : 0;
      case 0xA5:
      case 0xB5:
      case 0xAD:
      case 0xBD:
      case 0xB9:
      case 0xA1:
      case 0xB1:
        _a = memory.getMem(resolvedAddress);
        _n = ((_a & 0x80) != 0) ? 1 : 0;
        _z = (_a == 0) ? 1 : 0;

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
        _n = ((_x & 0x80) != 0) ? 1 : 0;
        _z = (_x == 0) ? 1 : 0;
      case 0xA6:
      case 0xB6:
      case 0xAE:
      case 0xBE:
        _x = memory.getMem(resolvedAddress);
        _n = ((_x & 0x80) != 0) ? 1 : 0;
        _z = (_x == 0) ? 1 : 0;

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
        _n = ((_y & 0x80) != 0) ? 1 : 0;
        _z = (_y == 0) ? 1 : 0;
      case 0xA4:
      case 0xB4:
      case 0xAC:
      case 0xBC:
        _y = memory.getMem(resolvedAddress);
        _n = ((_y & 0x80) != 0) ? 1 : 0;
        _z = (_y == 0) ? 1 : 0;

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
/*ADC (ADd with Carry)
Affects Flags: N V Z C

MODE           SYNTAX       HEX LEN TIM
Immediate     ADC #$44      $69  2   2
Zero Page     ADC $44       $65  2   3
Zero Page,X   ADC $44,X     $75  2   4
Absolute      ADC $4400     $6D  3   4
Absolute,X    ADC $4400,X   $7D  3   4+
Absolute,Y    ADC $4400,Y   $79  3   4+
Indirect,X    ADC ($44,X)   $61  2   6
Indirect,Y    ADC ($44),Y   $71  2   5+

+ add 1 cycle if page boundary crossed

ADC results are dependant on the setting of the decimal flag. In decimal mode, addition is carried out on the assumption that the values involved are packed BCD (Binary Coded Decimal).
There is no way to add without carry.
*/

      case 0x69:
        adc(arg0);
      case 0x65:
      case 0x75:
      case 0x6D:
      case 0x7D:
      case 0x79:
      case 0x61:
      case 0x71:
        adc(memory.getMem(resolvedAddress));
/*DEC (DECrement memory)
Affects Flags: N Z

MODE           SYNTAX       HEX LEN TIM
Zero Page     DEC $44       $C6  2   5
Zero Page,X   DEC $44,X     $D6  2   6
Absolute      DEC $4400     $CE  3   6
Absolute,X    DEC $4400,X   $DE  3   7
*/
      case 0xC6:
      case 0xD6:
      case 0xCE:
      case 0xDE:
        int temp = memory.getMem(resolvedAddress) - 1;
        temp = temp & 0xff;
        _n = ((temp & 0x80) != 0) ? 1 : 0;
        _z = (temp == 0) ? 1 : 0;
        memory.setMem(temp, resolvedAddress);
/*INC (INCrement memory)
Affects Flags: N Z

MODE           SYNTAX       HEX LEN TIM
Zero Page     INC $44       $E6  2   5
Zero Page,X   INC $44,X     $F6  2   6
Absolute      INC $4400     $EE  3   6
Absolute,X    INC $4400,X   $FE  3   7*/
      case 0xE6:
      case 0xF6:
      case 0xEE:
      case 0xFE:
        int temp = memory.getMem(resolvedAddress) + 1;
        temp = temp & 0xff;
        _n = ((temp & 0x80) != 0) ? 1 : 0;
        _z = (temp == 0) ? 1 : 0;
        memory.setMem(temp, resolvedAddress);

/*SBC (SuBtract with Carry)
Affects Flags: N V Z C

MODE           SYNTAX       HEX LEN TIM
Immediate     SBC #$44      $E9  2   2
Zero Page     SBC $44       $E5  2   3
Zero Page,X   SBC $44,X     $F5  2   4
Absolute      SBC $4400     $ED  3   4
Absolute,X    SBC $4400,X   $FD  3   4+
Absolute,Y    SBC $4400,Y   $F9  3   4+
Indirect,X    SBC ($44,X)   $E1  2   6
Indirect,Y    SBC ($44),Y   $F1  2   5+

+ add 1 cycle if page boundary crossed

SBC results are dependant on the setting of the decimal flag. In decimal mode, subtraction is carried out on the assumption that the values involved are packed BCD (Binary Coded Decimal).
There is no way to subtract without the carry which works as an inverse borrow. i.e, to subtract you set the carry before the operation. If the carry is cleared by the operation, it indicates a borrow occurred.
*/
      case 0xE9:
        sbc(arg0);
      case 0xE5:
      case 0xF5:
      case 0xED:
      case 0xFD:
      case 0xF9:
      case 0xE1:
      case 0xF1:
        sbc(memory.getMem(resolvedAddress));

/*
These instructions are implied mode, have a length of one byte and require two machine cycles.

MNEMONIC                       HEX
CLC (CLear Carry)              $18
SEC (SEt Carry)                $38
CLI (CLear Interrupt)          $58
SEI (SEt Interrupt)            $78
CLV (CLear oVerflow)           $B8
CLD (CLear Decimal)            $D8
SED (SEt Decimal)              $F8

 */
      case 0x18:
        _c = 0;
      case 0x38:
        _c = 1;
      case 0x58:
        _i = 0;
      case 0x78:
        _i = 1;
      case 0xB8:
        _v = 0;
      case 0xD8:
        _d = 0;
      case 0xF8:
        _d = 1;
    }
  }
}
