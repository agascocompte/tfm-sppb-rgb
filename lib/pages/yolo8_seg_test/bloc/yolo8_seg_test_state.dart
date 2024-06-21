part of 'yolo8_seg_test_bloc.dart';

class Yolo8SegTestStateData {
  final Classifier? classifier;
  final Segmentator? segmentator;
  final String label;
  final List<Map<String, dynamic>> segmentatorResults;
  final XFile? capturedImage;
  final int imageWidth;
  final int imageHeight;
  final GlobalKey previewContainer = GlobalKey();

  Yolo8SegTestStateData({
    this.label = "No data",
    this.classifier,
    this.segmentator,
    this.segmentatorResults = const [],
    this.capturedImage,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  Yolo8SegTestStateData copyWith({
    Classifier? classifier,
    Segmentator? segmentator,
    String? label,
    List<Map<String, dynamic>>? segmentatorResults,
    XFile? capturedImage,
    int? imageWidth,
    int? imageHeight,
  }) {
    return Yolo8SegTestStateData(
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

abstract class Yolo8SegTestState {
  final Yolo8SegTestStateData stateData;

  Yolo8SegTestState({required this.stateData});
}

final class Yolo8SegTestInitial extends Yolo8SegTestState {
  Yolo8SegTestInitial() : super(stateData: Yolo8SegTestStateData());
}

class ModelsLoaded extends Yolo8SegTestState {
  ModelsLoaded(Yolo8SegTestStateData stateData) : super(stateData: stateData);
}

class CapturedImageUpdate extends Yolo8SegTestState {
  CapturedImageUpdate(Yolo8SegTestStateData stateData)
      : super(stateData: stateData);
}

class SegmentationFailed extends Yolo8SegTestState {
  SegmentationFailed(Yolo8SegTestStateData stateData)
      : super(stateData: stateData);
}

class SegmentationResultsUpdated extends Yolo8SegTestState {
  SegmentationResultsUpdated(Yolo8SegTestStateData stateData)
      : super(stateData: stateData);
}

class PredictionSuccess extends Yolo8SegTestState {
  PredictionSuccess(Yolo8SegTestStateData stateData)
      : super(stateData: stateData);
}
