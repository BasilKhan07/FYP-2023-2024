import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:classification1/image_utils.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(entryPoint, _receivePort.sendPort,
        debugName: _debugName);
    _sendPort = await _receivePort.first;
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  static void entryPoint(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final InferenceModel isolateModel in port) {
    image_lib.Image? img;
    if (isolateModel.isCameraFrame()) {
      img = ImageUtils.convertCameraImage(isolateModel.cameraImage!);
    } else {
      img = isolateModel.image;
    }

    // Resize original image to match model shape.
    image_lib.Image imageInput = image_lib.copyResize(
      img!,
      width: isolateModel.inputShape[1],
      height: isolateModel.inputShape[2],
    );

    if (Platform.isAndroid && isolateModel.isCameraFrame()) {
      imageInput = image_lib.copyRotate(imageInput, angle: 90);
    }

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0]; // Normalize to float32
        },
      ),
    );

    // Set tensor input [1, 224, 224, 3]
    final input = [
      imageMatrix.map(
        (row) => row.map(
          (pixel) => pixel.map((channel) => channel.toDouble()).toList(),
        ).toList(),
      ).toList(),
    ];

    // Set tensor output [1, 19]
    final output = [List<double>.filled(isolateModel.outputShape[1], 0.0)];
    print(output);

    // Run inference
    Interpreter interpreter =
        Interpreter.fromAddress(isolateModel.interpreterAddress);
    interpreter.run(input, output);

    // Get first output tensor
    final result = output.first;
    print(result);

    // Set assessment map {label: score}
    var assessment = <String, double>{};
    for (var i = 0; i < result.length; i++) {
      // Set label: score
      assessment[isolateModel.labels[i]] = result[i];
    }

    isolateModel.responsePort.send(assessment);
  }
}

}

class InferenceModel {
  CameraImage? cameraImage;
  image_lib.Image? image;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(this.cameraImage, this.image, this.interpreterAddress,
      this.labels, this.inputShape, this.outputShape);

  // check if it is camera frame or still image
  bool isCameraFrame() {
    return cameraImage != null;
  }
}