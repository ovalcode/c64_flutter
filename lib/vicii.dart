import 'dart:typed_data' as type_data;

import 'package:c64_flutter/memory.dart';

import 'alarms.dart';

class Vicii {
  final type_data.ByteData _regs = type_data.ByteData(0x50);
  late final Memory memory;
  late type_data.Uint32List image;
  final type_data.Uint8List c64Buffer = type_data.Uint8List(400*284);
  late final Alarms _alarms;
  Alarm? _vicAlarm;
  bool _frameFinished = false;
  int yReg = 0;
  int currentPosStartLine = 0;
  bool visibleVerticalRegion = false;
  int charLine = 0;
  int videoMatrixPos = 0;
  late type_data.Uint8List _charCodeBuffer;

  static const List<int> c64Colors = [
  0xFF000000, // Black
  0xFFFFFFFF, // White
  0xFF000088, // Red
  0xFFEEFFAA, // Cyan
  0xFFCC44CC, // Purple
  0xFF55CC00, // Green
  0xFFAA0000, // Blue
  0xFF77EEEE, // Yellow
  0xFF5588DD, // Orange
  0xFF004466, // Brown
  0xFF7777FF, // Light Red
  0xFF333333, // Dark Grey
  0xFF777777, // Grey
  0xFF66FFAA, // Light Green
  0xFFFF8800, // Light Blue
  0xFFBBBBBB, // Light Grey
   ];
/*
Border cycles -> 5
Border pixels -> 40
Preceding cycles -> 10
first line = 51
number of lines = 312
first vblank = 300
last vblank = 15

40 + 40 + 320

visible lines 284
 */
/*
Graph.                      |===========01020304050607080910111213141516171819202122232425262728293031323334353637383940=========

X coo. \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
       1111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111111111
       89999aaaabbbbccccddddeeeeff0000111122223333444455556666777788889999aaaabbbbccccddddeeeeffff000011112222333344445555666677778888999
       c048c048c048c048c048c048c04048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048c048
 */

  Vicii(Alarms alarms) {
    _alarms = alarms;
    setupAlarms();
  }

  int getReg(int address) {
    return _regs.getUint8(address & 0x3f);
  }

  setReg(int address, int value) {
    _regs.setInt8(address & 0x3f, value);
  }

  setupAlarms() {
    _vicAlarm ??= _alarms.addAlarm( (remaining) => processVicAlarm(remaining));
    _vicAlarm!.setTicks(63);
  }

  bool getFrameFinished() {
    var tempFrameFinihsed = _frameFinished;
    _frameFinished = false;
    return tempFrameFinihsed;
  }

  processVicAlarm(int remaining) {
    _vicAlarm!.setTicks(63 + remaining);
    // process borders
    // Exit if v-blanking
    if (yReg >= 17 && yReg <= 300) {
      drawScanLine();
    }

    yReg++;
    if (yReg == 312) {
      _frameFinished = true;
      yReg = 0;
      currentPosStartLine = 0;
      videoMatrixPos = 0;
      charLine = 0;
    }
  }

  void drawScanLine() {
    int borderColor = _regs.getInt8(0x20);
    int backgroundColor = _regs.getInt8(0x21);
    // process full border
    if (yReg < 51) {
      c64Buffer.fillRange(currentPosStartLine, currentPosStartLine + 400, borderColor);
    }

    visibleVerticalRegion = yReg < 251 && yReg >= 51;
    var displayEnabled = (_regs.getUint8(0x11) & 0x10) != 0 ? true : false;
    if (visibleVerticalRegion && displayEnabled) {
      // process visible screen line
      if (charLine == 0) {
        _charCodeBuffer = memory.readVicRange(videoMatrixPos | 1024, 40);
      }
      c64Buffer.fillRange(currentPosStartLine, currentPosStartLine + 40, borderColor);
      c64Buffer.fillRange(currentPosStartLine + 40, currentPosStartLine + 40 + 320, backgroundColor);
      c64Buffer.fillRange(currentPosStartLine + 40 + 320, currentPosStartLine + 40 + 320 + 40, borderColor);
      var charDrawPointer = currentPosStartLine + 40;
      for (var charCode in _charCodeBuffer) {
        var bitmapRow = memory.readVic((charCode << 3) | charLine | 0x1000);
        if (bitmapRow & 0x80 != 0) {
          c64Buffer[charDrawPointer] = 14;
        }
        if (bitmapRow & 0x40 != 0) {
          c64Buffer[charDrawPointer + 1] = 14;
        }
        if (bitmapRow & 0x20 != 0) {
          c64Buffer[charDrawPointer + 2] = 14;
        }
        if (bitmapRow & 0x10 != 0) {
          c64Buffer[charDrawPointer + 3] = 14;
        }
        if (bitmapRow & 0x08 != 0) {
          c64Buffer[charDrawPointer + 4] = 14;
        }
        if (bitmapRow & 0x04 != 0) {
          c64Buffer[charDrawPointer + 5] = 14;
        }
        if (bitmapRow & 0x02 != 0) {
          c64Buffer[charDrawPointer + 6] = 14;
        }
        if (bitmapRow & 0x01 != 0) {
          c64Buffer[charDrawPointer + 7] = 14;
        }
        charDrawPointer = charDrawPointer + 8;
      }

    } else {
      // process full border
      c64Buffer.fillRange(currentPosStartLine, currentPosStartLine + 400, borderColor);
    }

    if (visibleVerticalRegion) {
      charLine++;
      charLine = charLine & 7;
      if (charLine == 0) {
        videoMatrixPos = videoMatrixPos + 40;
      }
    }
    currentPosStartLine = currentPosStartLine + 400;
  }

  void renderDisplayImage() {
    for (int i = 0; i < 400 * 284; i++) {
      image[i] = c64Colors[c64Buffer[i] & 0xf];
    }
  }
}