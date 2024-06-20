import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:sppb_rgb/models/segmentator/segmentator.dart';

class Yolo8VisionSegmentator extends Segmentator {
  FlutterVision? vision;
  Stopwatch? stopwatch;

  Yolo8VisionSegmentator() {
    stopwatch = Stopwatch();
    vision = FlutterVision();
  }

  @override
  Future<void> loadModel() async {
    await vision?.loadYoloModel(
      labels: 'assets/yolo8/labels.txt',
      modelPath: 'assets/yolo8/yolov8n-seg.tflite',
      modelVersion: "yolov8seg",
      quantization: false,
      numThreads: 4,
      useGpu: true,
    );
    isLoaded = true;
  }

  @override
  Future<List<Map<String, dynamic>>?> processImage(XFile file) async {
    stopwatch!.reset();
    stopwatch!.start();
    print("-------------------------->");
    print(stopwatch!.elapsedMilliseconds);
    Uint8List bytes = await file.readAsBytes();

    final image = await decodeImageFromList(bytes);
    final result = await vision?.yoloOnImage(
      bytesList: bytes,
      imageHeight: image.height,
      imageWidth: image.width,
      iouThreshold: 0.8,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );

    stopwatch!.stop();
    timeSpent = stopwatch!.elapsedMilliseconds;
    print("-------------------------->");

    print(stopwatch!.elapsedMilliseconds);
    return result;
  }

  @override
  void close() {
    vision?.closeYoloModel();
  }
}
