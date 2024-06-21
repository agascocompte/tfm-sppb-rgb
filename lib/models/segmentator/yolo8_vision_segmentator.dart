import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  Future<List<Map<String, dynamic>>?> processImage(XFile file) async {
    Uint8List bytes = await file.readAsBytes();

    final image = await decodeImageFromList(bytes);

    try {
      final result = await vision?.yoloOnImage(
        bytesList: bytes,
        imageHeight: image.height,
        imageWidth: image.width,
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
