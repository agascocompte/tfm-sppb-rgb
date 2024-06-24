import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/pages/raw_test/bloc/raw_test_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class RawTestPage extends StatelessWidget {
  const RawTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraViewBloc, CameraViewState>(
      listener: (context, state) async {
        if (state is PictureCaptured) {
          context
              .read<CameraViewBloc>()
              .add(UpdateIsImageProcessing(isImageProcessing: true));
          context.read<RawTestBloc>().add(ProcessImage(image: state.picture));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Raw prediction example"),
        ),
        body:
            BlocConsumer<RawTestBloc, RawTestState>(listener: (context, state) {
          if (state is PredictionSuccess) {
            context
                .read<CameraViewBloc>()
                .add(UpdateIsImageProcessing(isImageProcessing: false));
          }
        }, builder: (context, state) {
          return ((state.stateData.classifier?.isLoaded ?? false))
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraView(
                      onCapture: () => context
                          .read<CameraViewBloc>()
                          .add(BeginImageStreaming()),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        height: 100,
                        width: 360,
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Text(
                            state.stateData.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text("Models not loaded, waiting for them"),
                );
        }),
      ),
    );
  }
}
