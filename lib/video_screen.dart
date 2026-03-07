import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'emulator_canvas.dart';
import 'emulator_controller.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {

  late final Ticker _ticker;
  late EmulatorController controller;
  late EmulatorCanvas emCanvas;
  int lastProcessed = 0;

  @override
  void initState() {
    super.initState();

    controller = context.read<EmulatorController>();
    emCanvas = EmulatorCanvas(320, 200);
    controller.setCanvasArray(emCanvas.getFrameBuffer());

    _ticker = createTicker((Duration elapsed) {
      if ((elapsed.inMilliseconds - lastProcessed) < 16) {
        return;
      }
      lastProcessed = elapsed.inMilliseconds;

      controller.executeChunk();
      emCanvas.renderFrame();
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4040E0), // Classic C64 blue
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.folder),
                  onPressed: () async {
                    // FilePickerResult? result = await FilePicker.platform.pickFiles();
                    final result = await FilePicker.platform.pickFiles(
                      withData: true,
                      type: FileType.custom,
                      allowedExtensions: ['tap', 't64'],
                    );
                    if (result == null) {
                      return;
                    }
                    controller.setTapeImage(result);
                  }),
              IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    controller.playTape();
                  })
            ],
          ),

          const SizedBox(
            width: 640,
            height: 400,
            child: HtmlElementView(viewType: 'emulator-canvas'),
          ),
          // EmulatorControls(),
        ],
      ),
    );
  }
}