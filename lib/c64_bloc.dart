import 'dart:async';

import 'package:c64_flutter/cia1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'alarms.dart';
import 'c64_event.dart';
import 'c64_state.dart';
import 'cpu.dart';
import 'keyboard_scan_map.dart';
import 'memory.dart';
import 'dart:typed_data' as type_data;

abstract class KeyInfo {
  int getKeyInfo(int column);
}

class C64Bloc extends Bloc<C64Event, C64State> implements KeyInfo {
  final Memory memory = Memory();
  final List<int> matrix = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff];
  final FocusNode focusNode = FocusNode();
  late final Cpu _cpu = Cpu(memory: memory);
  late final Alarms alarms = Alarms();
  type_data.ByteData image = type_data.ByteData(200*200*4);
  int dumpNo = 0;
  int frameNo = 0;
  Timer? timer;

  C64Bloc() : super(InitialState()) {
    // memory.setKeyInfo(this);
    on<InitEmulatorEvent>((event, emit) async {
      final basicData = await rootBundle.load("assets/basic.bin");
      final characterData = await rootBundle.load("assets/characters.bin");
      final kernalData = await rootBundle.load("assets/kernal.bin");
      Cia1 cia1 = Cia1(alarms: alarms);
      cia1.setKeyInfo(this);
      memory.setCia1(cia1);
      memory.populateMem(basicData, characterData, kernalData);
      _cpu.setInterruptCallback(() => cia1.hasInterrupts());
      _cpu.reset();
      emit(DataShowState(
          dumpNo: dumpNo++,
          memorySnippet: type_data.ByteData(512),
          a: _cpu.getAcc(),
          x: _cpu.getX(),
          y: _cpu.getY(),
          n: _cpu.getN() == 1,
          z: _cpu.getZ() == 1,
          c: _cpu.getC() == 1,
          i: _cpu.getI() == 1,
          d: _cpu.getD() == 1,
          v: _cpu.getV() == 1,

          pc: _cpu.pc));
    });

    on<StepEvent>((event, emit) {
      _cpu.step();
      // emit(C64DebugState(memorySnippet: ByteData.sublistView(memory.getDebugSnippet(), 0, 256)));
      emit(DataShowState(
          dumpNo: dumpNo++,
          memorySnippet: ByteData.sublistView(memory.getDebugSnippet(), 0, 512),
          a: _cpu.getAcc(),
          x: _cpu.getX(),
          y: _cpu.getY(),
          n: _cpu.getN() == 1,
          z: _cpu.getZ() == 1,
          c: _cpu.getC() == 1,
          i: _cpu.getI() == 1,
          d: _cpu.getD() == 1,
          v: _cpu.getV() == 1,

          pc: _cpu.pc));
    });

    void setImg(ui.Image data) {
      emit(RunningState(image: data, frameNo: frameNo++));
    }

    on<RunEvent>((event, emit) {
      timer = Timer.periodic(const Duration(milliseconds: 17), (timer) {
          int start = DateTime.now().millisecondsSinceEpoch;
          int targetCycles = _cpu.getCycles() + 16666;
          do {
            _cpu.step();
            alarms.processAlarms(_cpu.getCycles());
            // Process alarms
            // In memory class
            // cia clas existing
          } while (_cpu.getCycles() < targetCycles);
          ui.decodeImageFromPixels(memory.getDisplayImage().buffer.asUint8List(), 320, 200, ui.PixelFormat.bgra8888, setImg);
          int end = DateTime.now().millisecondsSinceEpoch;
      });
    });

    on<StopEvent>((event, emit) {
      timer?.cancel();
      emit(DataShowState(
          dumpNo: dumpNo++,
          memorySnippet: ByteData.sublistView(memory.getDebugSnippet(), 0, 512),
          a: _cpu.getAcc(),
          x: _cpu.getX(),
          y: _cpu.getY(),
          n: _cpu.getN() == 1,
          z: _cpu.getZ() == 1,
          c: _cpu.getC() == 1,
          i: _cpu.getI() == 1,
          d: _cpu.getD() == 1,
          v: _cpu.getV() == 1,

          pc: _cpu.pc));
    });

    on<KeyC64Event>((event, emit) {
      int c64KeyCode = keyMap[event.key] ?? 0;
      int col = c64KeyCode >> 3;
      int row = 1 << (c64KeyCode & 7);
      if (!event.keyDown) {
        matrix[col] |= row;
      } else {
        matrix[col] &= ~row;
      }
    });

    add(InitEmulatorEvent());
  }

  @override
  int getKeyInfo(int column ) {
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
