import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/router/router.dart';
import 'package:sppb_rgb/widgets/app_scaffold_messenger.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';

class CameraView extends StatelessWidget {
  final Function() onCapture;
  final bool viewCapturedImages;

  const CameraView(
      {super.key, required this.onCapture, this.viewCapturedImages = false});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraViewBloc, CameraViewState>(
        listener: (context, state) {
      if (state is CameraError) {
        AppScaffoldMessenger.showWarningScaffold(context, state.error);
      } else if (state is GatheringImagesCompleted) {
        AppScaffoldMessenger.showSuccessScaffold(context, state.msg);
      }
    }, builder: (context, state) {
      return state.stateData.cameraController != null
          ? Column(
              children: [
                Expanded(
                  child: CameraPreview(
                    state.stateData.cameraController!,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (viewCapturedImages) ...[
                              FloatingActionButton(
                                heroTag: 'viewCapturedImages',
                                onPressed: () =>
                                    context.push(AppRouter.viewCapturedImages),
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                ),
                              ),
                            ] else ...[
                              const Opacity(
                                opacity: 0.0,
                                child: FloatingActionButton(
                                  heroTag: 'placeholder1',
                                  onPressed: null,
                                ),
                              ),
                            ],
                            FloatingActionButton(
                              heroTag: 'onCapture',
                              onPressed: onCapture,
                              child: Icon(
                                !state.stateData.isStreaming
                                    ? Icons.play_arrow_outlined
                                    : Icons.stop_outlined,
                                size: 50,
                              ),
                            ),
                            FloatingActionButton(
                              heroTag: 'switchCamera',
                              onPressed: () => context
                                  .read<CameraViewBloc>()
                                  .add(SwitchCamera()),
                              child: const Icon(
                                Icons.switch_camera,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: Text("Cámara no inicializada"));
    });
  }
}
