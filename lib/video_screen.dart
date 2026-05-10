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
  int frameCount = 0;
  double fps = 0;
  int lastFpsUpdate = 0;

  @override
  void initState() {
    super.initState();

    controller = context.read<EmulatorController>();
    emCanvas = EmulatorCanvas(400, 284);
    controller.setCanvasArray(emCanvas.getFrameBuffer());

    _ticker = createTicker((Duration elapsed) {
      final now = elapsed.inMilliseconds;
      if ((elapsed.inMilliseconds - lastProcessed) < 16) {
        return;
      }
      lastProcessed = elapsed.inMilliseconds;

      controller.executeChunk();
      emCanvas.renderFrame();

      // FPS tracking
      frameCount++;

      if ((now - lastFpsUpdate) >= 3000) { // every 3 seconds
        fps = frameCount / ((now - lastFpsUpdate) / 1000);

        frameCount = 0;
        lastFpsUpdate = now;

        setState(() {}); // trigger UI update
      }
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
      backgroundColor: const Color(0xFFFFFFE0), // Classic C64 blue
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
                  }),
              Text("FPS: ${fps.toStringAsFixed(1)}")
            ],
          ),

          const SizedBox(
            width: 600,
            height: 426,
            child: HtmlElementView(viewType: 'emulator-canvas'),
          ),
          // EmulatorControls(),
        ],
      ),
    );
  }
}