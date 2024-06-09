part of 'label_images_bloc.dart';

abstract class LabelImagesEvent {}

class UpdateLabel extends LabelImagesEvent {
  final String label;
  UpdateLabel({required this.label});
}

class StartCountDown extends LabelImagesEvent {
  final int countDown;
  StartCountDown({required this.countDown});
}
