import 'package:image/image.dart' as img;

abstract class Segmentator {
  bool isLoaded = false;
  int timeSpent = 0;

  Future<void> loadModel();
  Future<List<Map<String, dynamic>>?> processImage(img.Image file);
  void close();
}
