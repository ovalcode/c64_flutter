import 'dart:typed_data' as type_data;

import 'package:c64_flutter/cia1.dart';
import 'package:c64_flutter/tape.dart';

class Memory {
  late type_data.ByteData _basic;
  late type_data.ByteData _character;
  late type_data.ByteData _kernal;
  late TapeMemoryInterface _tape;
  var _readCount = 0;

  late type_data.Uint32List image;

  final type_data.ByteData _ram = type_data.ByteData(64*1024);
  late final Cia1 cia1;

  Memory();

  setCia1(Cia1 cia1) {
    this.cia1 = cia1;
  }

  setTape(TapeMemoryInterface tape) {
    _tape = tape;
  }

  setByteArray(type_data.Uint32List bytArray) {
    image = bytArray;
  }

  populateMem(type_data.ByteData basicData, type_data.ByteData characterData,
      type_data.ByteData kernalData) {
    _basic = basicData;
    _character = characterData;
    _kernal = kernalData;
  }

  setMem(int value, int address ) {
    if ((address >> 8) == 0xDC) {
      cia1.setMem(address, value);
    } else if (address == 1) {
      _ram.setInt8(address, value);
      _tape.setMotor((value & 0x20) == 0 );
    } else {
      _ram.setInt8(address, value);
    }
  }

  int getMem(int address) {
    _readCount++;
    if (address >= 0xA000 && address <= 0xBFFF) {
      return _basic.getUint8(address & 0x1fff);
    } else if (address >= 0xE000 && address <= 0xFFFF) {
      return _kernal.getUint8(address & 0x1fff);
    } else if (address == 0xD012) {
      return (_readCount & 1024) == 0 ? 1 : 0;
    } else if ((address >> 8) == 0xDC ) {
      return cia1.getMem(address);
    } else if (address == 1) {
      var value = _ram.getUint8(address) & 0xef;
      return value | _tape.getCassetteSense();
    } else {
      return _ram.getUint8(address);
    }
  }

  void renderDisplayImage() {
    const rowSpan = 320;
    for (int i = 0; i < 1000; i++ ) {
      var charCode = _ram.getUint8(i + 1024);
      var charAddress = charCode << 3;
      var charBitmapRow = (i ~/ 40) << 3;
      var charBitmapCol = (i % 40) << 3;
      int rawPixelPos = charBitmapRow * rowSpan + charBitmapCol;
      for (int row = /*charAddress*/ 0 ; row < /*charAddress +*/ 8; row++ ) {
        int bitmapRow = _character.getUint8(row + charAddress);
        int currentRowAddress = rawPixelPos + row * rowSpan;
        for (int pixel = 0; pixel < 8; pixel++) {
          if ((bitmapRow & 0x80) != 0) {
              image[currentRowAddress + (pixel)] = 0x000000ff;
          } else {
              image[currentRowAddress + (pixel)] = 0xffffffff;
          }
          bitmapRow = bitmapRow << 1;
        }
      }

    }
  }

  type_data.ByteData getDebugSnippet()  {
    return type_data.ByteData.sublistView(_ram, 0, 512);
  }

}
