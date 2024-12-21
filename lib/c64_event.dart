import 'package:equatable/equatable.dart';

abstract class C64Event/* extends Equatable*/ {
/*
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
*/

}

class InitEmulatorEvent extends C64Event {}

class StepEvent extends C64Event {}