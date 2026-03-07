import 'package:c64_flutter/tape.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'alarms.dart';
import 'cia1.dart';
import 'cpu.dart';
import 'keyboard_scan_map.dart';
import 'memory.dart';
import 'dart:typed_data' as type_data;

abstract class KeyInfo {
  int getKeyInfo(int column);
}

class EmulatorController implements KeyInfo{
  final Memory memory = Memory();
  final List<int> matrix = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff];
  late final Cpu _cpu = Cpu(memory: memory);
  late final Tape _tape;
  late final Alarms alarms = Alarms();
  FocusNode focusNode = FocusNode();
  bool tapeLoaded = false;

  EmulatorController._();

  static Future<EmulatorController> create() async {
    final instance = EmulatorController._();
    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    final basicData = await rootBundle.load("assets/basic.bin");
    final characterData = await rootBundle.load("assets/characters.bin");
    final kernalData = await rootBundle.load("assets/kernal.bin");
    Cia1 cia1 = Cia1(alarms: alarms);
    cia1.setKeyInfo(this);
    Tape tape = Tape(alarms: alarms, interrupt: cia1);
    _tape = tape;
    memory.setCia1(cia1);
    memory.populateMem(basicData, characterData, kernalData);
    memory.setTape(tape);
    _cpu.setInterruptCallback(() => cia1.hasInterrupts());
    _cpu.reset();
  }

  void executeChunk() {
    int targetCycles = _cpu.getCycles() + 16666;
    do {
      _cpu.step();
      alarms.processAlarms(_cpu.getCycles());
      // Process alarms
      // In memory class
      // cia clas existing
    } while (_cpu.getCycles() < targetCycles);
    memory.renderDisplayImage();
  }

  void setCanvasArray(type_data.Uint32List byteArray) {
    memory.setByteArray(byteArray);
  }

  void setTapeImage(FilePickerResult result) {
    tapeLoaded = true;
    _tape.setTapeImage(result.files.single.bytes!);
  }

  void playTape() {
    _tape.playTape();
  }

  void keyboardEvent(LogicalKeyboardKey keyCode, bool keyDown) {
    int c64KeyCode = keyMap[keyCode] ?? 0;
    int col = c64KeyCode >> 3;
    int row = 1 << (c64KeyCode & 7);
    if (!keyDown) {
      print("The key is up");
      matrix[col] |= row;
    } else {
      print("The key is down");
      matrix[col] &= ~row;
    }

  }

  @override
  int getKeyInfo(int column) {
    int result = 0xff; // Accumulator for the OR'ed numbers

    for (var row in matrix) {
      if ((column & 1) == 0) {
        result &= row; // Bitwise OR the current number with finalOrValue
      }

      column = column >> 1;
    }

    return result;
  }
}