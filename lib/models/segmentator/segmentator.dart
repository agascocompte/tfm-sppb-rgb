import 'package:camera/camera.dart';

abstract class Segmentator {
  bool isLoaded = false;
  int timeSpent = 0;

  Future<void> loadModel();
  Future<List<Map<String, dynamic>>?> processImage(XFile file);
  void close();
}
