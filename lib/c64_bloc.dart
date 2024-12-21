import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'c64_event.dart';
import 'c64_state.dart';
import 'cpu.dart';
import 'memory.dart';
import 'dart:typed_data' as type_data;

class C64Bloc extends Bloc<C64Event, C64State> {
  final Memory memory = Memory();
  late final Cpu _cpu = Cpu(memory: memory);
  int dumpNo = 0;

  C64Bloc() : super(InitialState()) {
    on<InitEmulatorEvent>((event, emit) async {
      final byteArray = await rootBundle.load("assets/program.bin");
      memory.populateMem(byteArray);
      emit(DataShowState(
          dumpNo: dumpNo++,
          memorySnippet: type_data.ByteData.sublistView(byteArray, 0, 256),
          a: _cpu.getAcc(),
          x: _cpu.getX(),
          y: _cpu.getY(),
          pc: _cpu.pc));
    });

    on<StepEvent>((event, emit) {
      _cpu.step();
      // emit(C64DebugState(memorySnippet: ByteData.sublistView(memory.getDebugSnippet(), 0, 256)));
      emit(DataShowState(
          dumpNo: dumpNo++,
          memorySnippet: ByteData.sublistView(memory.getDebugSnippet(), 0, 256),
          a: _cpu.getAcc(),
          x: _cpu.getX(),
          y: _cpu.getY(),
          pc: _cpu.pc));
    });

    add(InitEmulatorEvent());
  }
}
