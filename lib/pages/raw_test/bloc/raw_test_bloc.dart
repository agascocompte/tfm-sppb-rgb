import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sppb_rgb/models/classifier/classifier.dart';

import 'package:sppb_rgb/models/classifier/mobile_net_v3_small_classifier.dart';
import 'package:sppb_rgb/models/isolate_data.dart';
import 'package:sppb_rgb/utils/isolate_utils.dart';

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

    IsolateUtils isolateUtils = IsolateUtils();
    await isolateUtils.start();

    emit(ModelLoaded(state.stateData.copyWith(
      isolateUtils: isolateUtils,
      classifier: classifier,
    )));
  }

  FutureOr<void> _processImage(
      ProcessImage event, Emitter<RawTestState> emit) async {
    ReceivePort responsePort = ReceivePort();
    final isolateData = IsolateData(
      cameraImage: event.image,
      classifier: state.stateData.classifier!,
      responsePort: responsePort.sendPort,
    );

    state.stateData.isolateUtils!.sendPort.send(isolateData);

    var result = await responsePort.first;
    emit(PredictionSuccess(state.stateData.copyWith(
        label: result['label'] +
            " CLF: " +
            result['time'].toString() +
            " ms \n Probs: " +
            result['probabilities']
                .map((prob) => (prob * 100).toStringAsFixed(2))
                .join(", "))));
  }
}
