import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/pages/label_images/bloc/label_images_bloc.dart';

class LabelImagesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LabelImagesAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Label images'),
      leading: IconButton(
          onPressed: () => context.pop(context),
          icon: const Icon(Icons.arrow_back_outlined)),
      actions: [
        PopupMenuButton<String>(
          onSelected: (label) {
            context.read<LabelImagesBloc>().add(UpdateLabel(label: label));
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: "feet-together",
                child: Row(
                  children: [
                    Image.asset('assets/images/feet-together.png',
                        width: 64, height: 64),
                    const SizedBox(width: 8),
                    const Text('Pies juntos'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "semi-tandem",
                child: Row(
                  children: [
                    Image.asset('assets/images/semi-tandem.png',
                        width: 64, height: 64),
                    const SizedBox(width: 8),
                    const Text('Semi-tándem'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "tandem",
                child: Row(
                  children: [
                    Image.asset('assets/images/tandem.png',
                        width: 64, height: 64),
                    const SizedBox(width: 8),
                    const Text('Tándem'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "no-balance",
                child: Row(
                  children: [
                    Image.asset('assets/images/no-balance.png',
                        width: 64, height: 64),
                    const SizedBox(width: 8),
                    const Text('Sin equilibrio'),
                  ],
                ),
              ),
            ];
          },
          icon: BlocBuilder<LabelImagesBloc, LabelImagesState>(
              builder: (context, state) {
            return Image.asset('assets/images/${state.stateData.label}.png',
                width: 64, height: 64);
          }),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
