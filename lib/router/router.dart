import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/pages/gather_image.dart/gather_image.dart';
import 'package:sppb_rgb/pages/home/home.dart';

class AppRouter {
  static const String homeRoute = "/home";
  static const String gatherImageRoute = "/gather-image";

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
        path: "/gather-image",
        name: gatherImageRoute,
        builder: (BuildContext context, GoRouterState state) {
          return GatherImagePage(
            key: state.pageKey,
          );
        },
      ),
    ],
  );
}
