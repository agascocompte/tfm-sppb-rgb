import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter_vision/flutter_vision.dart';
import 'package:sppb_rgb/models/segmentator/segmentator.dart';

class Yolo8VisionSegmentator extends Segmentator {
  FlutterVision? vision;

  Yolo8VisionSegmentator() {
    vision = FlutterVision();
  }

  @override
  Future<void> loadModel() async {
    await vision?.loadYoloModel(
      labels: 'assets/yolo8/labels.txt',
      modelPath: 'assets/yolo8/yolov8n-seg.tflite',
      modelVersion: "yolov8seg",
      quantization: true,
      numThreads: 8,
      useGpu: true,
    );
    isLoaded = true;
  }

  @override
  Future<List<Map<String, dynamic>>?> processImage(img.Image file) async {
    Uint8List bytes = Uint8List.fromList(img.encodePng(file));

    try {
      final result = await vision?.yoloOnImage(
        bytesList: bytes,
        imageHeight: file.height,
        imageWidth: file.width,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.5,
      );
      return result;
    } catch (e) {
      return Future.value([
        {'error': 'Platform down'}
      ]);
    }
  }

  @override
  void close() {
    vision?.closeYoloModel();
  }
}
