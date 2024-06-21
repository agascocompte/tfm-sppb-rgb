import 'dart:math';
import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:sppb_rgb/models/classifier/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MobileNetV3SmallClassifier extends Classifier {
  Stopwatch? stopwatch;

  MobileNetV3SmallClassifier() {
    stopwatch = Stopwatch();
  }
  @override
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset(
        'assets/models/mobile_net_v3_small_opt.tflite');
    isLoaded = true;
  }

  @override
  Map<String, dynamic> predict(img.Image image) {
    stopwatch!.reset();
    stopwatch!.start();

    List<dynamic>? output;

    try {
      var input = _imageToByteListInt32(image);
      var inputTensor = input.reshape([
        1,
        224,
        224,
        3
      ]); // Cambio para ajustar al formato de entrada [batch, height, width, channels]
      output = List.generate(1, (_) => List.filled(4, 0.0));

      interpreter!.run(inputTensor, output);
    } catch (e) {
      print(e);
      return {'error': e};
    }

    if (output.isEmpty) return {'error': 'Empty output'};

    List<double> probabilities = output[0];
    int highestProbIndex = probabilities.indexOf(probabilities.reduce(max));
    String label = labels[highestProbIndex];
    stopwatch!.stop();
    timeSpent = stopwatch!.elapsedMilliseconds;
    return {'label': label, 'probabilities': probabilities};
  }

  Int32List _imageToByteListInt32(img.Image image) {
    var convertedBytes = Float32List(1 * 224 * 224 * 3);
    var buffer = Int32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int i = 0; i < 224; i++) {
      for (int j = 0; j < 224; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r.toInt();
        buffer[pixelIndex++] = pixel.g.toInt();
        buffer[pixelIndex++] = pixel.b.toInt();
      }
    }
    return buffer;
  }

  @override
  void close() {
    interpreter?.close();
  }
}
