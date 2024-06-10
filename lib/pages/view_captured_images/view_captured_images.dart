import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sppb_rgb/pages/view_captured_images/bloc/view_captured_images_bloc.dart';
import 'package:sppb_rgb/router/router.dart';
import 'package:sppb_rgb/widgets/app_dialog.dart';
import 'package:sppb_rgb/widgets/app_scaffold_messenger.dart';

class ViewCapturedImagesPage extends StatelessWidget {
  const ViewCapturedImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => AppDialog.showShareDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ViewCapturedImagesBloc, ViewCapturedImagesState>(
        listener: (context, state) {
          if (state is ImageOperationFailure) {
            AppScaffoldMessenger.showWarningScaffold(context, state.error);
          }
        },
        builder: (context, state) {
          context.read<ViewCapturedImagesBloc>().add(LoadImages());
          if (state is ViewCapturedImagesInitial ||
              state is ImageOperationSuccess) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ImagesLoaded) {
            final imagesByLabel = state.stateData.images;
            return ListView(
              children: imagesByLabel.entries.map((entry) {
                final label = entry.key;
                final images = entry.value;
                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(label),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            AppDialog.warnDeleteFolderDialog(context, label),
                      ),
                    ],
                  ),
                  initiallyExpanded: true,
                  children: images.map((image) {
                    return ListTile(
                      leading: Image.file(
                        image,
                        width: 50,
                        height: 50,
                      ),
                      title: Text(image.path.split('/').last),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context
                              .read<ViewCapturedImagesBloc>()
                              .add(DeleteImage(image));
                        },
                      ),
                      onTap: () =>
                          context.push(AppRouter.imageDetail, extra: image),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('No images found'));
          }
        },
      ),
    );
  }
}
