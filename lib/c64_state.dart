import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class C64State extends Equatable {
  final int time = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [];
}

class InitialState extends C64State {}

class DataShowState extends C64State {
  DataShowState(
      {required this.memorySnippet,
      required this.a,
      required this.x,
      required this.y,
      required this.n,
      required this.z,
      required this.pc,
      required this.dumpNo});

  final ByteData memorySnippet;
  final int a;
  final int x;
  final int y;
  final bool n;
  final bool z;
  final int pc;
  final int dumpNo;

  @override
  List<Object> get props => [dumpNo];
}
