import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/pages/gather_image.dart/bloc/gather_image_bloc.dart';
import 'package:sppb_rgb/router/router.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class GatherImagePage extends StatelessWidget {
  const GatherImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GatherImageBloc, GatherImageState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gather images'),
            backgroundColor: Colors.white70,
            leading: IconButton(
                onPressed: () => context.pop(context),
                icon: const Icon(Icons.arrow_back_outlined)),
            actions: const [],
          ),
          body: Stack(
            children: [
              CameraView(
                onCapture: () {},
              ),
              // Positioned(
              //   bottom: 16,
              //   left: 16,
              //   child: Row(
              //     children: [
              //       ElevatedButton(
              //         onPressed: () => context
              //             .read<GatherImageBloc>()
              //             .add(UpdateLabel(label: "feet-together")),
              //         child: const Text('Pies juntos'),
              //       ),
              //       const SizedBox(width: 16),
              //       ElevatedButton(
              //         onPressed: () => context
              //             .read<GatherImageBloc>()
              //             .add(UpdateLabel(label: "semi-tandem")),
              //         child: const Text('Semi-tándem'),
              //       ),
              //       const SizedBox(width: 16),
              //       ElevatedButton(
              //         onPressed: () => context
              //             .read<GatherImageBloc>()
              //             .add(UpdateLabel(label: "tandem")),
              //         child: const Text('Tándem'),
              //       ),
              //       const SizedBox(width: 16),
              //       ElevatedButton(
              //         onPressed: () => context
              //             .read<GatherImageBloc>()
              //             .add(UpdateLabel(label: "no-balance")),
              //         child: const Text('Sin equilibrio'),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
