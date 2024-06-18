import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class Yolo8TestPage extends StatefulWidget {
  const Yolo8TestPage({Key? key}) : super(key: key);

  @override
  _Yolo8TestPageState createState() => _Yolo8TestPageState();
}

class _Yolo8TestPageState extends State<Yolo8TestPage> {
  late FlutterVision vision;
  CameraController? controller;
  List<Map<String, dynamic>>? yoloResults;
  XFile? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = false;
  bool isDetecting = false;
  GlobalKey previewContainer = GlobalKey();

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    initCamera();
    loadYoloModel();
  }

  @override
  void dispose() {
    controller?.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  void initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller?.initialize();
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
      labels: 'assets/yolo8/labels.txt',
      modelPath: 'assets/yolo8/yolov8n-seg.tflite',
      modelVersion: "yolov8seg",
      quantization: false,
      numThreads: 2,
      useGpu: true,
    );
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }
    if (controller!.value.isTakingPicture) {
      return;
    }
    try {
      XFile file = await controller!.takePicture();
      setState(() {
        imageFile = file;
      });
      processImage(file);
    } catch (e) {
      print(e);
    }
  }

  Future<void> processImage(XFile file) async {
    Uint8List bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await vision.yoloOnImage(
      bytesList: bytes,
      imageHeight: image.height,
      imageWidth: image.width,
      iouThreshold: 0.8,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  void resetView() {
    setState(() {
      imageFile = null;
      yoloResults = null;
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults == null || yoloResults!.isEmpty) return [];

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight - 80) / 3;

    return yoloResults!.map((result) {
      return RepaintBoundary(
        key: previewContainer,
        child: Stack(
          children: [
            Positioned(
              left: result["box"][1] * factorX,
              top: result["box"][0] * factorY + pady,
              width: (result["box"][3] - result["box"][1]) * factorX,
              height: (result["box"][2] - result["box"][0]) * factorY,
              child: Container(
                color: Colors.black,
              ),
            ),
            Positioned(
                left: result["box"][1] * factorX,
                top: result["box"][0] * factorY + pady,
                width: (result["box"][3] - result["box"][1]) * factorX,
                height: (result["box"][2] - result["box"][0]) * factorY,
                child: CustomPaint(
                  painter: PolygonPainter(
                      points: (result["polygons"] as List<dynamic>).map((e) {
                        Map<String, double> xy = Map<String, double>.from(e);
                        xy['x'] = (xy['x'] as double) * factorX;
                        xy['y'] = (xy['y'] as double) * factorY;
                        return xy;
                      }).toList(),
                      offset: (result["box"][3] - result["box"][1]) * factorX),
                )),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOLOv8 Segmentation"),
        actions: [
          if (imageFile != null &&
              yoloResults != null &&
              yoloResults!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.crop),
              onPressed: () => processSegmentedImage(),
            ),
          if (imageFile != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: resetView,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null) CameraPreview(controller!),
          if (imageFile != null)
            Positioned.fill(
              child: Image.file(
                File(imageFile!.path),
                fit: BoxFit.cover,
              ),
            ),
          ...displayBoxesAroundRecognizedObjects(size),
          Positioned(
            bottom: 75,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 5,
                  color: Colors.white,
                  style: BorderStyle.solid,
                ),
              ),
              child: IconButton(
                onPressed: takePicture,
                icon: const Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
                iconSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void processSegmentedImage() async {
    RenderRepaintBoundary boundary = previewContainer.currentContext!
        .findRenderObject() as RenderRepaintBoundary;

    // Capturar imagen bbox y segmentación
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Decodifica la imagen capturada
    img.Image originalImage = img.decodeImage(pngBytes)!;

    // Redimensiona la imagen a 128x256
    img.Image resizedImage =
        img.copyResize(originalImage, width: 128, height: 256);

    // Calcula la altura de la mitad inferior
    int startY = resizedImage.height ~/ 2;
    int height = resizedImage.height - startY;

    // Recorta la mitad inferior
    img.Image halfImage = img.copyCrop(resizedImage,
        x: 0, y: startY, width: resizedImage.width, height: height);

    // Guarda la imagen final
    String dir = (await getTemporaryDirectory()).path;
    String filename = "$dir/screenshot.png";
    File finalImageFile = File(filename);
    await finalImageFile.writeAsBytes(img.encodePng(halfImage));

    print("Imagen final guardada en: $filename");
  }
}

class PolygonPainter extends CustomPainter {
  final List<Map<String, double>> points;
  final double offset;

  PolygonPainter({
    required this.points,
    this.offset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 255, 0)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(-points[0]['y']! + offset, points[0]['x']!);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(-points[i]['y']! + offset, points[i]['x']!);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
