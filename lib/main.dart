import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'c64_bloc.dart';
import 'c64_event.dart';
import 'c64_state.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo 2',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => C64Bloc(),
        child: const MyHomePage(),
      ) /*const MyHomePage(title: 'Flutter Demo Home Page')*/,
    );
  }
}

class MyHomePage extends StatelessWidget {

  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Emulator C64"),
            BlocBuilder<C64Bloc, C64State>(
                builder: (BuildContext context, state) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_getRunStopButton(state, context)]);
            })
          ]),
        ),
        body: BlocBuilder<C64Bloc, C64State>(
          builder: (BuildContext context, state) {
            if (state is InitialState) {
              return const CircularProgressIndicator();
            } else if (state is DataShowState) {
              return Column(
                children: [
                  Text(getRegisterDump(state.a, state.x, state.y, state.n,
                      state.z, state.c, state.i, state.d, state.v, state.pc)),
                  Text(
                    getMemDump(state.memorySnippet),
                    style: const TextStyle(
                      fontFamily: 'RobotoMono', // Use the monospace font
                    ),
                  ),
                ],
              );
            } else if (state is RunningState) {
              return KeyboardListener(
                focusNode: context.read<C64Bloc>().focusNode,
                autofocus: true,
                onKeyEvent: (event) => {
                  if (event is KeyDownEvent) {
                    context.read<C64Bloc>().add(KeyC64Event(keyDown: true, key: event.logicalKey))
                  } else if (event is KeyUpEvent) {
                    context.read<C64Bloc>().add(KeyC64Event(keyDown: false, key: event.logicalKey))
                  }
                },
                child: RawImage(
                    image: state.image, scale: 0.5),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        floatingActionButton: BlocBuilder<C64Bloc, C64State>(
            builder: (BuildContext context, state) {
          if (state is DataShowState) {
            return FloatingActionButton(
              tooltip: 'Step',
              onPressed: () {
                context.read<C64Bloc>().add(StepEvent());
              },
              child: const Icon(Icons.arrow_forward),
            );
          } else {
            return const FloatingActionButton(
              tooltip: 'Step',
              onPressed: null,
              child: Icon(Icons.arrow_forward),
            );
          }
        }));
  }

  Widget _getRunStopButton(C64State state, BuildContext context) {
    if (state is DataShowState) {
      return IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            context.read<C64Bloc>().add(RunEvent());
          });
    } else if (state is RunningState) {
      return IconButton(
          icon: Icon(Icons.stop_circle),
          onPressed: () {
            context.read<C64Bloc>().add(StopEvent());
          });
    } else {
      return const IconButton(icon: Icon(Icons.play_arrow), onPressed: null);
    }
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
}
