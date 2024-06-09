part of 'gather_image_bloc.dart';

abstract class GatherImageEvent {}

class UpdateLabel extends GatherImageEvent {
  final String label;
  UpdateLabel({required this.label});
}
