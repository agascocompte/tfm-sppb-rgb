import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:sppb_rgb/models/classifier/classifier.dart';

class IsolateData {
  CameraImage cameraImage;
  SendPort responsePort;
  Classifier classifier;

  IsolateData({
    required this.cameraImage,
    required this.responsePort,
    required this.classifier,
  });
}
