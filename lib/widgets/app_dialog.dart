import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/pages/view_captured_images/bloc/view_captured_images_bloc.dart';

class AppDialog {
  static void showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final labels = ["feet-together", "semi-tandem", "tandem", "no-balance"];
        final selectedLabels = <String>{};
        return AlertDialog(
          title: const Text('Select the folders to share'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: labels.map((label) {
                  return CheckboxListTile(
                    title: Text(label),
                    value: selectedLabels.contains(label),
                    onChanged: (selected) {
                      setState(() {
                        if (selected!) {
                          selectedLabels.add(label);
                        } else {
                          selectedLabels.remove(label);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Share'),
              onPressed: () {
                context
                    .read<ViewCapturedImagesBloc>()
                    .add(ShareImages(selectedLabels.toList()));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static void warnDeleteFolderDialog(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete folder content'),
          content:
              Text('Are you sure to delete all the files from $label folder?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                context.read<ViewCapturedImagesBloc>().add(DeleteFolder(label));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
