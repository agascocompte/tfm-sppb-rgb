import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'view_captured_images_event.dart';
part 'view_captured_images_state.dart';

@injectable
class ViewCapturedImagesBloc
    extends Bloc<ViewCapturedImagesEvent, ViewCapturedImagesState> {
  ViewCapturedImagesBloc() : super(ViewCapturedImagesInitial()) {
    on<LoadImages>(_onLoadImages);
    on<DeleteImage>(_onDeleteImage);
    on<DeleteFolder>(_onDeleteFolder);
    on<ShareImages>(_onShareImages);
  }

  FutureOr<void> _onLoadImages(
      LoadImages event, Emitter<ViewCapturedImagesState> emit) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      emit(ImageOperationFailure(state.stateData,
          error: "Failed to access external storage"));
      return;
    }

    final labels = ["feet-together", "semi-tandem", "tandem", "no-balance"];
    final Map<String, List<File>> imagesByLabel = {};

    for (final label in labels) {
      final dir = Directory('${directory.path}/$label');
      if (await dir.exists()) {
        final images = dir.listSync().whereType<File>().toList();
        imagesByLabel[label] = images;
      } else {
        imagesByLabel[label] = [];
      }
    }

    emit(ImagesLoaded(state.stateData.copyWith(images: imagesByLabel)));
  }

  FutureOr<void> _onDeleteImage(
      DeleteImage event, Emitter<ViewCapturedImagesState> emit) async {
    try {
      await event.image.delete();
      emit(ImageOperationSuccess(state.stateData));
    } catch (e) {
      emit(ImageOperationFailure(state.stateData,
          error: "Failed to delete image"));
    }
  }

  FutureOr<void> _onDeleteFolder(
      DeleteFolder event, Emitter<ViewCapturedImagesState> emit) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      emit(ImageOperationFailure(state.stateData,
          error: "Failed to access external storage"));
      return;
    }

    try {
      final dir = Directory('${directory.path}/${event.folderPath}');
      if (await dir.exists()) {
        final contents = dir.listSync();
        for (var entity in contents) {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
        emit(ImageOperationSuccess(state.stateData));
      }
    } catch (e) {
      emit(ImageOperationFailure(state.stateData,
          error: "Failed to delete folder contents"));
    }
  }

  FutureOr<void> _onShareImages(
      ShareImages event, Emitter<ViewCapturedImagesState> emit) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      emit(ImageOperationFailure(state.stateData,
          error: "Failed to access external storage"));
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final zipFile = File('${tempDir.path}/shared_images.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);

      for (final label in event.labels) {
        final dir = Directory('${directory.path}/$label');
        if (await dir.exists()) {
          final images = dir.listSync().whereType<File>().toList();
          for (final image in images) {
            final relativePath = image.path.replaceFirst(directory.path, '');
            encoder.addFile(image, relativePath);
          }
        }
      }

      encoder.close();
      Share.shareXFiles([XFile(zipFile.path)], text: 'Shared Images');
      emit(ImageOperationSuccess(state.stateData));
    } catch (e) {
      emit(ImageOperationFailure(state.stateData,
          error: "Failed to share images"));
    }
  }
}
