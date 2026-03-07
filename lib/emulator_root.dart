import 'package:c64_flutter/video_screen.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'emulator_controller.dart';

class EmulatorRoot extends StatefulWidget {
  // final String name;
  const EmulatorRoot({super.key});

  @override
  State<EmulatorRoot> createState() => _EmulatorRootState();
}

class _EmulatorRootState extends State<EmulatorRoot> {
  int _currentIndex = 0; // 0 = debug, 1 = video

  @override
  Widget build(BuildContext context) {
    EmulatorController controller = context.read<EmulatorController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("C64 Emulator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => setState(() => _currentIndex = 0),
          ),
          IconButton(
            icon: const Icon(Icons.tv),
            onPressed: () => setState(() => _currentIndex = 1),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // DebugScreen(),
          KeyboardListener (
            // VideoScreen(),
            focusNode: controller.focusNode,
            autofocus: true,
            onKeyEvent: (event) => {
              if (event is KeyDownEvent) {
                controller.keyboardEvent(event.logicalKey, true)
                // context.read<C64Bloc>().add(KeyC64Event(keyDown: true, key: event.logicalKey))
              } else if (event is KeyUpEvent) {
                controller.keyboardEvent(event.logicalKey, false)
                // context.read<C64Bloc>().add(KeyC64Event(keyDown: false, key: event.logicalKey))
              }
            },
            child: const VideoScreen(),

          )
        ],
      ),
    );
  }
}