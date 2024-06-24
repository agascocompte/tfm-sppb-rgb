part of 'raw_test_bloc.dart';

class RawTestStateData {
  final IsolateUtils? isolateUtils;
  final Classifier? classifier;
  final String label;

  RawTestStateData({
    this.isolateUtils,
    this.classifier,
    this.label = "No data",
  });

  RawTestStateData copyWith({
    IsolateUtils? isolateUtils,
    Classifier? classifier,
    String? label,
  }) {
    return RawTestStateData(
      isolateUtils: isolateUtils ?? this.isolateUtils,
      classifier: classifier ?? this.classifier,
      label: label ?? this.label,
    );
  }
}

abstract class RawTestState {
  final RawTestStateData stateData;

  RawTestState({required this.stateData});
}

final class RawTestInitial extends RawTestState {
  RawTestInitial() : super(stateData: RawTestStateData());
}

class ModelLoaded extends RawTestState {
  ModelLoaded(RawTestStateData stateData) : super(stateData: stateData);
}

class CapturedImageUpdate extends RawTestState {
  CapturedImageUpdate(RawTestStateData stateData) : super(stateData: stateData);
}

class PredictionSuccess extends RawTestState {
  PredictionSuccess(RawTestStateData stateData) : super(stateData: stateData);
}
