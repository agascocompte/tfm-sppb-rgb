part of 'yolo8_test_bloc.dart';

class Yolo8TestStateData {
  final Classifier? classifier;
  final Segmentator? segmentator;
  final String label;
  final List<Map<String, dynamic>> segmentatorResults;
  final XFile? capturedImage;
  final int imageWidth;
  final int imageHeight;
  final GlobalKey previewContainer = GlobalKey();

  Yolo8TestStateData({
    this.label = "No data",
    this.classifier,
    this.segmentator,
    this.segmentatorResults = const [],
    this.capturedImage,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  Yolo8TestStateData copyWith({
    Classifier? classifier,
    Segmentator? segmentator,
    String? label,
    List<Map<String, dynamic>>? segmentatorResults,
    XFile? capturedImage,
    int? imageWidth,
    int? imageHeight,
  }) {
    return Yolo8TestStateData(
      classifier: classifier ?? this.classifier,
      segmentator: segmentator ?? this.segmentator,
      label: label ?? this.label,
      segmentatorResults: segmentatorResults ?? this.segmentatorResults,
      capturedImage: capturedImage ?? this.capturedImage,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }
}

abstract class Yolo8TestState {
  final Yolo8TestStateData stateData;

  Yolo8TestState({required this.stateData});
}

final class Yolo8TestInitial extends Yolo8TestState {
  Yolo8TestInitial() : super(stateData: Yolo8TestStateData());
}

class ModelsLoaded extends Yolo8TestState {
  ModelsLoaded(Yolo8TestStateData stateData) : super(stateData: stateData);
}

class CapturedImageUpdate extends Yolo8TestState {
  CapturedImageUpdate(Yolo8TestStateData stateData)
      : super(stateData: stateData);
}

class SegmentationFailed extends Yolo8TestState {
  SegmentationFailed(Yolo8TestStateData stateData)
      : super(stateData: stateData);
}

class SegmentationResultsUpdated extends Yolo8TestState {
  SegmentationResultsUpdated(Yolo8TestStateData stateData)
      : super(stateData: stateData);
}

class PredictionSuccess extends Yolo8TestState {
  PredictionSuccess(Yolo8TestStateData stateData) : super(stateData: stateData);
}
