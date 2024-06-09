part of 'gather_image_bloc.dart';

class GatherImageStateData {
  String label;

  GatherImageStateData({
    this.label = "feet-together",
  });

  GatherImageStateData copyWith({
    String? label,
  }) {
    return GatherImageStateData(
      label: label ?? this.label,
    );
  }
}

abstract class GatherImageState {
  final GatherImageStateData stateData;

  GatherImageState({required this.stateData});
}

class GatherImageInitial extends GatherImageState {
  GatherImageInitial() : super(stateData: GatherImageStateData());
}

class LabelUpdated extends GatherImageState {
  LabelUpdated(GatherImageStateData stateData) : super(stateData: stateData);
}
