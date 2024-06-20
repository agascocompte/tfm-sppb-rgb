part of 'yolo8_test_bloc.dart';

abstract class Yolo8TestEvent {}

class LoadModels extends Yolo8TestEvent {}

class ProcessImage extends Yolo8TestEvent {
  final XFile image;
  ProcessImage({required this.image});
}

class ProcessSegmentedImage extends Yolo8TestEvent {}
