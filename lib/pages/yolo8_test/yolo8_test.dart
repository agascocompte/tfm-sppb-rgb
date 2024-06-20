import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:sppb_rgb/models/classifier/classifier.dart';
import 'package:sppb_rgb/models/classifier/vit_classifier.dart';
import 'package:sppb_rgb/models/polygon_painter.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class Yolo8TestPage extends StatefulWidget {
  const Yolo8TestPage({Key? key}) : super(key: key);

  @override
  _Yolo8TestPageState createState() => _Yolo8TestPageState();
}

class _Yolo8TestPageState extends State<Yolo8TestPage> {
  FlutterVision? vision;
  List<Map<String, dynamic>>? yoloResults;
  XFile? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = false;
  GlobalKey previewContainer = GlobalKey();
  Classifier? classifier;
  String label = "No data";
  Stopwatch stopwatch = Stopwatch();
  String yoloTime = "";

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    loadYoloModel();
    classifier =
        ViTClassifier(modelPath: 'assets/models/vit_model_optimized.tflite');
  }

  @override
  void dispose() {
    super.dispose();
    vision?.closeYoloModel();
    classifier?.close();
  }

  Future<void> loadYoloModel() async {
    await vision?.loadYoloModel(
      labels: 'assets/yolo8/labels.txt',
      modelPath: 'assets/yolo8/yolov8n-seg.tflite',
      modelVersion: "yolov8seg",
      quantization: false,
      numThreads: 4,
      useGpu: true,
    );
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> processImage(XFile file) async {
    stopwatch.start();
    Uint8List bytes = await file.readAsBytes();

    final image = await decodeImageFromList(bytes);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await vision?.yoloOnImage(
      bytesList: bytes,
      imageHeight: image.height,
      imageWidth: image.width,
      iouThreshold: 0.8,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );
    if (result != null && result.isNotEmpty) {
      updateAndProcess(result);
    } else {
      setState(() {
        label = "No segmentation found";
        stopwatch.stop();
        stopwatch.reset();
      });
    }
  }

  void updateAndProcess(result) {
    setState(() {
      yoloResults =
          result; // Suponiendo que 'result' es lo que recibes del modelo.
      yoloTime = stopwatch.elapsedMilliseconds.toString();
      stopwatch.reset();
      stopwatch.start();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      processSegmentedImage();
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
    if (!isLoaded || !(classifier?.isLoaded ?? true)) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOLOv8 Segmentation"),
      ),
      body: BlocListener<CameraViewBloc, CameraViewState>(
        listener: (context, state) {
          if (state is PictureCaptured) {
            setState(() {
              imageFile = state.picture;
            });
            processImage(state.picture);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraView(
              onCapture: () =>
                  context.read<CameraViewBloc>().add(TakePicture()),
            ),
            ...displayBoxesAroundRecognizedObjects(size),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                height: 100,
                width: 360,
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
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

// Redimensiona la imagen a 224x224
    img.Image resizedImage =
        img.copyResize(originalImage, width: 224, height: 448);

    // Calcula la altura de la mitad inferior
    int startY = resizedImage.height ~/ 2;
    int height = resizedImage.height - startY;

    // Recorta la mitad inferior
    img.Image halfImage = img.copyCrop(resizedImage,
        x: 0, y: startY, width: resizedImage.width, height: height);

    print("Image prepared. Predicting...");
    // Guarda la imagen final
    // String dir = (await getTemporaryDirectory()).path;
    // String filename = "$dir/screenshot.png";
    // File finalImageFile = File(filename);
    // await finalImageFile.writeAsBytes(img.encodePng(halfImage));

    // print("Imagen final guardada en: $filename");

    Map<String, dynamic> result = classifier!.predict(halfImage);

    setState(() {
      label = result['label'] +
          " YOLO: " +
          yoloTime +
          " ms CLF: " +
          classifier!.timeSpent.toString() +
          " ms TOTAL: " +
          (int.parse(yoloTime) + classifier!.timeSpent).toString() +
          " ms";
    });
    stopwatch.stop();
    stopwatch.reset();
    print(result);
  }
}
