part of 'yolo8_seg_test_bloc.dart';

abstract class Yolo8SegTestEvent {}

class LoadSegModels extends Yolo8SegTestEvent {}

class ProcessImage extends Yolo8SegTestEvent {
  final XFile image;
  ProcessImage({required this.image});
}

class ProcessSegmentedImage extends Yolo8SegTestEvent {}
