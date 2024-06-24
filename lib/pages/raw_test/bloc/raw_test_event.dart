part of 'raw_test_bloc.dart';

abstract class RawTestEvent {}

class LoadModel extends RawTestEvent {}

class ProcessImage extends RawTestEvent {
  final CameraImage image;
  ProcessImage({required this.image});
}
