import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/pages/label_images/bloc/label_images_bloc.dart';
import 'package:sppb_rgb/pages/label_images/widgets/label_images_appbar.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class LabelImagesPage extends StatelessWidget {
  const LabelImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LabelImagesAppBar(),
      body: BlocBuilder<LabelImagesBloc, LabelImagesState>(
        builder: (context, state) {
          return Stack(
            children: [
              CameraView(
                onCapture: state is UpdateCountDown
                    ? () {}
                    : () => context
                        .read<LabelImagesBloc>()
                        .add(StartCountDown(countDown: 10)),
              ),
              if (state is UpdateCountDown)
                Center(
                  child: Text(
                    state.stateData.countDown.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
