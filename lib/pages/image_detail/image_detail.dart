import 'dart:io';

import 'package:flutter/material.dart';

class ImageDetailPage extends StatelessWidget {
  final File image;
  const ImageDetailPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(image.path.split('/').last)),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}
