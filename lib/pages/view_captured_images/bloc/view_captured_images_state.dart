part of 'view_captured_images_bloc.dart';

class ViewCapturedImagesStateData {
  final Map<String, List<File>> images;

  ViewCapturedImagesStateData({
    this.images = const {},
  });

  ViewCapturedImagesStateData copyWith({
    Map<String, List<File>>? images,
  }) {
    return ViewCapturedImagesStateData(
      images: images ?? this.images,
    );
  }
}

abstract class ViewCapturedImagesState {
  final ViewCapturedImagesStateData stateData;

  ViewCapturedImagesState({required this.stateData});
}

class ViewCapturedImagesInitial extends ViewCapturedImagesState {
  ViewCapturedImagesInitial() : super(stateData: ViewCapturedImagesStateData());
}

class ImagesLoaded extends ViewCapturedImagesState {
  ImagesLoaded(ViewCapturedImagesStateData stateData)
      : super(stateData: stateData);
}

class ImageOperationSuccess extends ViewCapturedImagesState {
  ImageOperationSuccess(ViewCapturedImagesStateData stateData)
      : super(stateData: stateData);
}

class ImageOperationFailure extends ViewCapturedImagesState {
  final String error;
  ImageOperationFailure(ViewCapturedImagesStateData stateData,
      {required this.error})
      : super(stateData: stateData);
}
