import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/pages/label_images/bloc/label_images_bloc.dart';
import 'package:sppb_rgb/pages/label_images/widgets/label_images_appbar.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class LabelImagesPage extends StatelessWidget {
  const LabelImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LabelImagesAppBar(),
      body: BlocConsumer<LabelImagesBloc, LabelImagesState>(
        listener: (context, state) {
          if (state is CountDownFinished) {
            context.read<CameraViewBloc>().add(BeginImageCapture(
                label: state.stateData.label, capturingTime: 30));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              CameraView(
                viewCapturedImages: true,
                onCapture: state is UpdateCountDown
                    ? () {}
                    : () => context
                        .read<LabelImagesBloc>()
                        .add(StartCountDown(countDown: 5)),
              ),
              if (state is UpdateCountDown)
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      state.stateData.countDown == 0
                          ? 'GO'
                          : state.stateData.countDown.toString(),
                      key: ValueKey<int>(state.stateData.countDown),
                      style: const TextStyle(
                        fontSize: 120,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
