part of 'yolo8_det_test_bloc.dart';

class Yolo8DetTestStateData {
  final Classifier? classifier;
  final Segmentator? detector;
  final String label;
  final List<Map<String, dynamic>> detectorResults;
  final XFile? capturedImage;
  final int imageWidth;
  final int imageHeight;

  Yolo8DetTestStateData({
    this.label = "No data",
    this.classifier,
    this.detector,
    this.detectorResults = const [],
    this.capturedImage,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  Yolo8DetTestStateData copyWith({
    Classifier? classifier,
    Segmentator? detector,
    String? label,
    List<Map<String, dynamic>>? detectorResults,
    XFile? capturedImage,
    int? imageWidth,
    int? imageHeight,
  }) {
    return Yolo8DetTestStateData(
      classifier: classifier ?? this.classifier,
      detector: detector ?? this.detector,
      label: label ?? this.label,
      detectorResults: detectorResults ?? this.detectorResults,
      capturedImage: capturedImage ?? this.capturedImage,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }
}

abstract class Yolo8DetTestState {
  final Yolo8DetTestStateData stateData;

  Yolo8DetTestState({required this.stateData});
}

final class Yolo8DetTestInitial extends Yolo8DetTestState {
  Yolo8DetTestInitial() : super(stateData: Yolo8DetTestStateData());
}

class ModelsLoaded extends Yolo8DetTestState {
  ModelsLoaded(Yolo8DetTestStateData stateData) : super(stateData: stateData);
}

class CapturedImageUpdate extends Yolo8DetTestState {
  CapturedImageUpdate(Yolo8DetTestStateData stateData)
      : super(stateData: stateData);
}

class DetectionFailed extends Yolo8DetTestState {
  DetectionFailed(Yolo8DetTestStateData stateData)
      : super(stateData: stateData);
}

class DetectionResultsUpdated extends Yolo8DetTestState {
  DetectionResultsUpdated(Yolo8DetTestStateData stateData)
      : super(stateData: stateData);
}

class PredictionSuccess extends Yolo8DetTestState {
  PredictionSuccess(Yolo8DetTestStateData stateData)
      : super(stateData: stateData);
}
