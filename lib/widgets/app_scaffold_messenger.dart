import 'package:flutter/material.dart';

class AppScaffoldMessenger {
  static void showSuccessScaffold(BuildContext context, String message) {
    showSnackBar(context, message, Colors.green);
  }

  static void showWarningScaffold(BuildContext context, String message) {
    showSnackBar(context, message, Colors.orange);
  }

  static void showSnackBar(BuildContext context, String message, Color color) {
    final overlay = Overlay.of(context);

    const snackBarHeight = 50.0;
    const duration = Duration(milliseconds: 250);

    double bottomPosition = 0;
    double opacity = 0.0;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottomPosition,
        left: 0,
        right: 0,
        child: Material(
          elevation: 6.0,
          child: AnimatedOpacity(
            duration: duration,
            opacity: opacity,
            child: Container(
              color: color,
              height: snackBarHeight,
              child: Center(child: Text(message)),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(Duration.zero, () {
      bottomPosition = 0;
      opacity = 1.0;
      entry.markNeedsBuild();

      Future.delayed(const Duration(seconds: 3) + duration, () {
        bottomPosition = -snackBarHeight;
        opacity = 0.0;
        entry.markNeedsBuild();

        Future.delayed(duration, () {
          entry.remove();
        });
      });
    });
  }
}
