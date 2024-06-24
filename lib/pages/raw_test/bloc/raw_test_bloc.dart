import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sppb_rgb/models/classifier/classifier.dart';

import 'package:image/image.dart' as img;
import 'package:sppb_rgb/models/classifier/mobile_net_v3_small_classifier.dart';
import 'package:sppb_rgb/utils/image_utils.dart';

part 'raw_test_event.dart';
part 'raw_test_state.dart';

@injectable
class RawTestBloc extends Bloc<RawTestEvent, RawTestState> {
  RawTestBloc() : super(RawTestInitial()) {
    on<LoadModel>(_loadModel);
    on<ProcessImage>(_processImage);
  }

  FutureOr<void> _loadModel(
      RawTestEvent event, Emitter<RawTestState> emit) async {
    Classifier classifier =
        MobileNetV3SmallClassifier(modelName: 'mobile_net_v3_small_raw_opt');

    await Future.wait([
      classifier.loadModel(),
    ]);

    emit(ModelLoaded(state.stateData.copyWith(
      classifier: classifier,
    )));
  }

  FutureOr<void> _processImage(
      ProcessImage event, Emitter<RawTestState> emit) async {
    img.Image image = ImageUtils.convertYUV420ToImage(event.image);

    img.Image resizedImage = img.copyResize(image, width: 224, height: 448);

    _saveImage(resizedImage, 'raw_resized');
    // Calcula la altura de la mitad inferior
    int startY = resizedImage.height ~/ 2;
    int height = resizedImage.height - startY;

    // Recorta la mitad inferior
    img.Image halfImage = img.copyCrop(resizedImage,
        x: 0, y: startY, width: resizedImage.width, height: height);

    print("Image prepared. Predicting...");
    _saveImage(halfImage, 'raw_half');

    Map<String, dynamic> result =
        state.stateData.classifier!.predict(halfImage);

    emit(PredictionSuccess(state.stateData.copyWith(
        label: result['label'] +
            " CLF: " +
            state.stateData.classifier!.timeSpent.toString() +
            " ms ")));
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
