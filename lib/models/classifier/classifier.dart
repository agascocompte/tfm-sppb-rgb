// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class Classifier {
  final List<String> labels = [
    "feet-together",
    "semi-tandem",
    "tandem",
    "no-balance"
  ];
  Interpreter? interpreter;
  bool isLoaded = false;
  int timeSpent = 0;

  Future<void> loadModel();
  Map<String, dynamic> predict(img.Image image);
  void close();
}
