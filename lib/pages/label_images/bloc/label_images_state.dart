part of 'label_images_bloc.dart';

class LabelImagesStateData {
  String label;
  int countDown;

  LabelImagesStateData({
    this.label = "feet-together",
    this.countDown = -1,
  });

  LabelImagesStateData copyWith({
    String? label,
    int? countDown,
    bool? capturingImages,
  }) {
    return LabelImagesStateData(
      label: label ?? this.label,
      countDown: countDown ?? this.countDown,
    );
  }
}

abstract class LabelImagesState {
  final LabelImagesStateData stateData;

  LabelImagesState({required this.stateData});
}

class LabelImagesInitial extends LabelImagesState {
  LabelImagesInitial() : super(stateData: LabelImagesStateData());
}

class LabelUpdated extends LabelImagesState {
  LabelUpdated(LabelImagesStateData stateData) : super(stateData: stateData);
}

class UpdateCountDown extends LabelImagesState {
  UpdateCountDown(LabelImagesStateData stateData) : super(stateData: stateData);
}

class CountDownFinished extends LabelImagesState {
  CountDownFinished(LabelImagesStateData stateData)
      : super(stateData: stateData);
}
