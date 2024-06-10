part of 'view_captured_images_bloc.dart';

abstract class ViewCapturedImagesEvent {}

class LoadImages extends ViewCapturedImagesEvent {}

class DeleteImage extends ViewCapturedImagesEvent {
  final File image;
  DeleteImage(this.image);
}

class DeleteFolder extends ViewCapturedImagesEvent {
  final String folderPath;
  DeleteFolder(this.folderPath);
}

class ShareImages extends ViewCapturedImagesEvent {
  final List<String> labels;
  ShareImages(this.labels);
}
