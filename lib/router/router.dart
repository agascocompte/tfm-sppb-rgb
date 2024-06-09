import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/pages/label_images/label_images.dart';
import 'package:sppb_rgb/pages/home/home.dart';

class AppRouter {
  static const String homeRoute = "/home";
  static const String gatherImageRoute = "/label-images";

  static GoRouter router = GoRouter(
    initialLocation: homeRoute,
    routes: <GoRoute>[
      GoRoute(
        path: "/home",
        name: homeRoute,
        builder: (BuildContext context, GoRouterState state) {
          return HomePage(
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: "/label-images",
        name: gatherImageRoute,
        builder: (BuildContext context, GoRouterState state) {
          return LabelImagesPage(
            key: state.pageKey,
          );
        },
      ),
    ],
  );
}
