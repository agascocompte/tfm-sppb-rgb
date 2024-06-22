import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sppb_rgb/models/classifier/classifier.dart';
import 'package:sppb_rgb/models/classifier/mobile_net_v3_small_classifier.dart';
import 'package:sppb_rgb/models/segmentator/segmentator.dart';
import 'package:sppb_rgb/models/segmentator/yolo8_vision_segmentator.dart';

// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

part 'yolo8_seg_test_event.dart';
part 'yolo8_seg_test_state.dart';

@injectable
class Yolo8SegTestBloc extends Bloc<Yolo8SegTestEvent, Yolo8SegTestState> {
  Yolo8SegTestBloc() : super(Yolo8SegTestInitial()) {
    on<LoadSegModels>(_loadModels);
    on<ProcessImage>(_processImage);
    on<ProcessSegmentedImage>(_processSegmentedImage);
  }

  FutureOr<void> _loadModels(
      Yolo8SegTestEvent event, Emitter<Yolo8SegTestState> emit) async {
    Classifier classifier =
        MobileNetV3SmallClassifier(modelName: 'mobile_net_v3_small_opt');
    Segmentator segmentator = Yolo8VisionSegmentator();

    await Future.wait([
      classifier.loadModel(),
      segmentator.loadModel(),
    ]);

    emit(ModelsLoaded(state.stateData.copyWith(
      classifier: classifier,
      segmentator: segmentator,
    )));
  }

  FutureOr<void> _processImage(
      ProcessImage event, Emitter<Yolo8SegTestState> emit) async {
    Uint8List bytes = await event.image.readAsBytes();
    final image = await decodeImageFromList(bytes);
    emit(CapturedImageUpdate(state.stateData.copyWith(
      capturedImage: event.image,
      imageWidth: image.width,
      imageHeight: image.height,
    )));

    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    var result = await state.stateData.segmentator!.processImage(event.image);
    if (result != null && result.isNotEmpty) {
      if (result[0].keys.contains('error')) {
        emit(SegmentationFailed(
            state.stateData.copyWith(label: result[0]['error'])));
      }
      emit(SegmentationResultsUpdated(state.stateData.copyWith(
        segmentatorResults: result,
      )));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        stopwatch.stop();
        state.stateData.segmentator!.timeSpent = stopwatch.elapsedMilliseconds;
        add(ProcessSegmentedImage());
      });
    } else {
      emit(SegmentationFailed(
          state.stateData.copyWith(label: "No segmentation found")));
    }
  }

  FutureOr<void> _processSegmentedImage(
      ProcessSegmentedImage event, Emitter<Yolo8SegTestState> emit) async {
    RenderRepaintBoundary boundary =
        state.stateData.previewContainer.currentContext?.findRenderObject()
            as RenderRepaintBoundary;

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
    _saveImage(halfImage);

    Map<String, dynamic> result =
        state.stateData.classifier!.predict(halfImage);

    emit(PredictionSuccess(state.stateData.copyWith(
        label: result['label'] +
            " YOLO: " +
            state.stateData.segmentator!.timeSpent.toString() +
            " ms CLF: " +
            state.stateData.classifier!.timeSpent.toString() +
            " ms TOTAL: " +
            (state.stateData.segmentator!.timeSpent +
                    state.stateData.classifier!.timeSpent)
                .toString() +
            " ms")));
    print(result);
  }

  _saveImage(image) async {
    String dir = (await getTemporaryDirectory()).path;
    String filename = "$dir/screenshot.png";
    File finalImageFile = File(filename);
    await finalImageFile.writeAsBytes(img.encodePng(image));

    print("Imagen final guardada en: $filename");
  }
}
