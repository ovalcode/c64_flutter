import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:typed_data';

import 'cpu.dart';
import 'emulator_controller.dart';
import 'emulator_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await EmulatorController.create();
  runApp(
    MaterialApp(
      home: RepositoryProvider.value(
        value: controller,
        child: const EmulatorRoot(),
      )
    ));
}



  String getRegisterDump(int a, int x, int y, bool n, bool z, bool c, bool i,
      bool d, bool v, int pc) {
    return 'A: ${a.toRadixString(16).padLeft(2, '0').toUpperCase()} X: ${x.toRadixString(16).padLeft(2, '0').toUpperCase()} Y: ${y.toRadixString(16).padLeft(2, '0').toUpperCase()} N: $n Z: $z C: $c I: $i D: $d V: $v PC: ${pc.toRadixString(16).padLeft(4, '0').toUpperCase()}';
  }

  String getMemDump(ByteData memDump) {
    String result = '';
    for (int i = 0; i < memDump.lengthInBytes; i++) {
      if ((i % 32) == 0) {
        String addressLabel = i.toRadixString(16).padLeft(4, '0').toUpperCase();
        result = '$result\n$addressLabel';
      }
      result =
          '$result ${memDump.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase()}';
    }
    return result;
  }
// }
