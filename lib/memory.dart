import 'dart:typed_data' as type_data;

import 'package:c64_flutter/c64_bloc.dart';

class Memory {
  late type_data.ByteData _basic;
  late type_data.ByteData _character;
  late type_data.ByteData _kernal;
  var _readCount = 0;
  final type_data.ByteData image = type_data.ByteData(320*200*4);
  final type_data.ByteData _ram = type_data.ByteData(64*1024);
  late final KeyInfo keyInfo;

  Memory();

  setKeyInfo(KeyInfo keyInfo) {
    this.keyInfo = keyInfo;
  }

  populateMem(type_data.ByteData basicData, type_data.ByteData characterData,
      type_data.ByteData kernalData) {
    _basic = basicData;
    _character = characterData;
    _kernal = kernalData;
  }

  setMem(int value, int address ) {
    _ram.setInt8(address, value);
  }

  int getMem(int address) {
    _readCount++;
    if (address >= 0xA000 && address <= 0xBFFF) {
      return _basic.getUint8(address & 0x1fff);
    } else if (address >= 0xE000 && address <= 0xFFFF) {
      return _kernal.getUint8(address & 0x1fff);
    } else if (address == 0xD012) {
      return (_readCount & 1024) == 0 ? 1 : 0;
    } else if (address == 0xDC01) {
      return keyInfo.getKeyInfo(_ram.getUint8(0xDC00));
    } else {
      return _ram.getUint8(address);
    }
  }

  type_data.ByteData getDisplayImage() {
    const rowSpan = 320 * 4;
    for (int i = 0; i < 1000; i++ ) {
      var charCode = _ram.getUint8(i + 1024);
      var charAddress = charCode << 3;
      var charBitmapRow = (i ~/ 40) << 3;
      var charBitmapCol = (i % 40) << 3;
      int rawPixelPos = charBitmapRow * rowSpan + charBitmapCol * 4;
      for (int row = /*charAddress*/ 0 ; row < /*charAddress +*/ 8; row++ ) {
        int bitmapRow = _character.getUint8(row + charAddress);
        int currentRowAddress = rawPixelPos + row * rowSpan;
        for (int pixel = 0; pixel < 8; pixel++) {
          if ((bitmapRow & 0x80) != 0) {
              image.setUint32(currentRowAddress + (pixel << 2), 0x000000ff);
          } else {
              image.setUint32(currentRowAddress + (pixel << 2), 0xffffffff);
          }
          bitmapRow = bitmapRow << 1;
        }
      }

    }
    return image;
  }

  type_data.ByteData getDebugSnippet()  {
    return type_data.ByteData.sublistView(_ram, 0, 512);
  }

}
