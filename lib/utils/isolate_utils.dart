import 'dart:isolate';

import 'package:sppb_rgb/models/isolate_data.dart';
import 'package:sppb_rgb/utils/image_utils.dart';
import 'package:image/image.dart' as img;

class IsolateUtils {
  static const String debugName = "InferenceIsolate";

  late Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: debugName,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      final convertedImage =
          ImageUtils.convertYUV420ToImage(isolateData.cameraImage);
      img.Image resizedImage =
          img.copyResize(convertedImage, width: 224, height: 448);

      int startY = resizedImage.height ~/ 2;
      int height = resizedImage.height - startY;

      // Recorta la mitad inferior
      img.Image halfImage = img.copyCrop(resizedImage,
          x: 0, y: startY, width: resizedImage.width, height: height);

      Map<String, dynamic> result = isolateData.classifier.predict(halfImage);
      result.putIfAbsent('time', () => isolateData.classifier.timeSpent);
      isolateData.responsePort.send(result);
    }
  }

  void dispose() {
    _isolate.kill();
  }

  // _saveImage(image, name) async {
  //   String dir = (await getTemporaryDirectory()).path;
  //   String filename = "$dir/$name.png";
  //   File finalImageFile = File(filename);
  //   await finalImageFile.writeAsBytes(img.encodePng(image));

  //   print("Imagen final guardada en: $filename");
  // }
}
