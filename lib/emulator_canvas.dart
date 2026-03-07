import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'dart:typed_data' as type_data;

class EmulatorCanvas {
  late final html.CanvasElement canvas;
  late final html.CanvasRenderingContext2D ctx;
  late final html.ImageData imageData;
  late final type_data.Uint8ClampedList buffer;
  late final type_data.Uint32List framebuffer32;

  final int width;
  final int height;
  int inc = 0;

  EmulatorCanvas(this.width, this.height) {
    canvas = html.CanvasElement(width: width, height: height);
    ctx = canvas.context2D;

    imageData = ctx.createImageData(width, height);
    buffer = imageData.data;
    framebuffer32 = buffer.buffer.asUint32List();

    // Register with Flutter
    ui.platformViewRegistry.registerViewFactory(
      'emulator-canvas',
          (int viewId) => canvas,
    );
  }

  type_data.Uint32List getFrameBuffer() {
    return framebuffer32;
  }

  void renderFrame() {
    ctx.putImageData(imageData, 0, 0);
  }
}
