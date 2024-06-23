import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sppb_rgb/models/classifier/classifier.dart';
import 'package:sppb_rgb/models/classifier/mobile_net_v3_small_classifier.dart';
import 'package:sppb_rgb/models/segmentator/segmentator.dart';
import 'package:sppb_rgb/models/segmentator/yolo8_vision_detector.dart';

// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:sppb_rgb/utils/image_utils.dart';

part 'yolo8_det_test_event.dart';
part 'yolo8_det_test_state.dart';

@injectable
class Yolo8DetTestBloc extends Bloc<Yolo8DetTestEvent, Yolo8DetTestState> {
  Yolo8DetTestBloc() : super(Yolo8DetTestInitial()) {
    on<LoadDetModels>(_loadModels);
    on<ProcessImage>(_processImage);
    on<ProcessDetectedImage>(_processDetectedImage);
  }

  FutureOr<void> _loadModels(
      Yolo8DetTestEvent event, Emitter<Yolo8DetTestState> emit) async {
    Classifier classifier = MobileNetV3SmallClassifier(
        modelName: 'mobile_net_v3_small_opt_bbox_opt');
    Segmentator detector = Yolo8VisionDetector();

    await Future.wait([
      classifier.loadModel(),
      detector.loadModel(),
    ]);

    emit(ModelsLoaded(state.stateData.copyWith(
      classifier: classifier,
      detector: detector,
    )));
  }

  FutureOr<void> _processImage(
      ProcessImage event, Emitter<Yolo8DetTestState> emit) async {
    img.Image image = ImageUtils.convertYUV420ToImage(event.image);
    _saveImage(image, 'YUV');
    emit(CapturedImageUpdate(state.stateData.copyWith(
      capturedImage: image,
      imageWidth: image.width,
      imageHeight: image.height,
    )));

    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    var result = await state.stateData.detector!.processImage(image);
    if (result != null && result.isNotEmpty) {
      if (result[0].keys.contains('error')) {
        emit(DetectionFailed(
            state.stateData.copyWith(label: result[0]['error'])));
      }
      emit(DetectionResultsUpdated(state.stateData.copyWith(
        detectorResults: result,
      )));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        stopwatch.stop();
        state.stateData.detector!.timeSpent = stopwatch.elapsedMilliseconds;
        add(ProcessDetectedImage(size: event.size));
      });
    } else {
      emit(DetectionFailed(
          state.stateData.copyWith(label: "No segmentation found")));
    }
  }

  FutureOr<void> _processDetectedImage(
      ProcessDetectedImage event, Emitter<Yolo8DetTestState> emit) async {
    double scaleX = (event.size.width) / state.stateData.imageWidth;
    double scaleY = (event.size.height) / state.stateData.imageHeight;

    int left = (state.stateData.detectorResults[0]["box"][0] * scaleX).toInt();
    int top = (state.stateData.detectorResults[0]["box"][1] * scaleY).toInt();
    int width = ((state.stateData.detectorResults[0]["box"][2] -
                state.stateData.detectorResults[0]["box"][0]) *
            scaleX)
        .toInt();
    int height = ((state.stateData.detectorResults[0]["box"][3] -
                state.stateData.detectorResults[0]["box"][1]) *
            scaleY)
        .toInt();

    // Recortar la imagen dentro de la bounding box
    img.Image croppedImage = img.copyCrop(state.stateData.capturedImage!,
        x: left, y: top, width: width, height: height);

    // Opcional: Redimensionar la imagen recortada si es necesario
    img.Image resizedCroppedImage =
        img.copyResize(croppedImage, width: 224, height: 448);

    // Calcula la altura de la mitad inferior
    int startY = resizedCroppedImage.height ~/ 2;
    height = resizedCroppedImage.height - startY;

    // Recorta la mitad inferior
    img.Image halfImage = img.copyCrop(resizedCroppedImage,
        x: 0, y: startY, width: resizedCroppedImage.width, height: height);

    print("Image prepared. Predicting...");
    _saveImage(halfImage, 'cropped');

    Map<String, dynamic> result =
        state.stateData.classifier!.predict(halfImage);

    emit(PredictionSuccess(state.stateData.copyWith(
        label: result['label'] +
            " YOLO: " +
            state.stateData.detector!.timeSpent.toString() +
            " ms CLF: " +
            state.stateData.classifier!.timeSpent.toString() +
            " ms TOTAL: " +
            (state.stateData.detector!.timeSpent +
                    state.stateData.classifier!.timeSpent)
                .toString() +
            " ms")));
    print(result);
  }

  _saveImage(image, name) async {
    String dir = (await getTemporaryDirectory()).path;
    String filename = "$dir/$name.png";
    File finalImageFile = File(filename);
    await finalImageFile.writeAsBytes(img.encodePng(image));

    print("Imagen final guardada en: $filename");
  }
}
