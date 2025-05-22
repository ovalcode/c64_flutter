import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

abstract class C64Event/* extends Equatable*/ {
/*
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
*/

}

class InitEmulatorEvent extends C64Event {}

class StepEvent extends C64Event {}

class RunEvent extends C64Event {}

class StopEvent extends C64Event {}

class KeyC64Event extends C64Event {
  final bool keyDown;
  final LogicalKeyboardKey key;
  KeyC64Event({required this.keyDown, required this.key});
}