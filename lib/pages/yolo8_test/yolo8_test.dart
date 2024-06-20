import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:sppb_rgb/models/polygon_painter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Yolo8TestPage extends StatefulWidget {
  const Yolo8TestPage({Key? key}) : super(key: key);

  @override
  _Yolo8TestPageState createState() => _Yolo8TestPageState();
}

class _Yolo8TestPageState extends State<Yolo8TestPage> {
  List<String> labels = [
    "feet-together",
    "semi-tandem",
    "tandem",
    "no-balance"
  ];
  FlutterVision? vision;
  CameraController? controller;
  List<Map<String, dynamic>>? yoloResults;
  XFile? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = false;
  bool isPredictorModelLoaded = false;
  bool isDetecting = false;
  GlobalKey previewContainer = GlobalKey();
  Interpreter? _interpreter;
  String label = "No data";
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    initCamera();
    loadYoloModel();
    loadClassifierModel();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    vision?.closeYoloModel();
    _interpreter?.close();
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

  Future<void> loadClassifierModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/models/vit_model_optimized.tflite');
    isPredictorModelLoaded = true;
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
    stopwatch.start();
    Uint8List bytes = await file.readAsBytes();

    try {
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
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        label = "YOLO vision out";
      });
      reinitializeVision();
    }
  }

  void reinitializeVision() async {
    if (vision != null) {
      await vision?.closeYoloModel();
    }
    vision = FlutterVision();
    await loadYoloModel();
    // Re-initialize other components if necessary
  }

  void updateAndProcess(result) {
    setState(() {
      yoloResults =
          result; // Suponiendo que 'result' es lo que recibes del modelo.
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      processSegmentedImage();
    });
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
    if (!isLoaded || !isPredictorModelLoaded) {
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
          // if (imageFile != null)
          //   Positioned.fill(
          //     child: Image.file(
          //       File(imageFile!.path),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
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
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              height: 40,
              width: 360,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
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

// Redimensiona la imagen a 224x224
    img.Image resizedImage =
        img.copyResize(originalImage, width: 128, height: 256);

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
    var result = await predict(halfImage);
    print(result);

    if (result != null && result.isNotEmpty) {
      List<double> probabilities =
          result[0]; // Aquí capturas la primera fila de la salida
      int highestProbIndex = probabilities.indexOf(
          probabilities.reduce(max)); // Encuentra el índice del valor más alto
      setState(() {
        stopwatch.stop();
        label = labels[highestProbIndex] +
            " in " +
            stopwatch.elapsedMilliseconds.toString() +
            " ms";
        stopwatch.reset();
      });
    } else {
      setState(() {
        label = "Prediction failed";
      });
    }
  }

  Future<List<dynamic>?> predict(img.Image image) async {
    List<dynamic>? output;

    try {
      var input = imageToByteListInt32(image);
      var inputTensor = input.reshape([
        1,
        224,
        224,
        3
      ]); // Cambio para ajustar al formato de entrada [batch, height, width, channels]
      output = List.generate(
          1,
          (_) => List.filled(
              4, 0.0)); // Preparar el buffer de salida para 4 clases

      _interpreter!.run(inputTensor, output);
    } catch (e) {
      print("Error during prediction: $e");
      return null;
    }

    return output;
  }

  Int32List imageToByteListInt32(img.Image image) {
    img.Image resized = img.copyResize(image, width: 224, height: 224);
    var convertedBytes = Float32List(1 * 224 * 224 * 3);
    var buffer = Int32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int i = 0; i < 224; i++) {
      for (int j = 0; j < 224; j++) {
        var pixel = resized.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r
            .toInt(); // Asignar el valor directo si decides no normalizar
        buffer[pixelIndex++] = pixel.g.toInt();
        buffer[pixelIndex++] = pixel.b.toInt();
      }
    }
    return buffer;
  }
}
