import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/pages/image_detail/image_detail.dart';
import 'package:sppb_rgb/pages/label_images/label_images.dart';
import 'package:sppb_rgb/pages/home/home.dart';
import 'package:sppb_rgb/pages/view_captured_images/view_captured_images.dart';
import 'package:sppb_rgb/pages/yolo8_det_test.dart/yolo8_det_test.dart';
import 'package:sppb_rgb/pages/yolo8_seg_test/yolo8_seg_test.dart';

class AppRouter {
  static const String homeRoute = "/home";
  static const String gatherImageRoute = "/label-images";
  static const String viewCapturedImages = "/view-captured-images";
  static const String imageDetail = "/image-detail";
  static const String testYolo8Seg = "/test-yolo8-seg";
  static const String testYolo8Det = "/test-yolo8-det";

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
      GoRoute(
        path: "/view-captured-images",
        name: viewCapturedImages,
        builder: (BuildContext context, GoRouterState state) {
          return ViewCapturedImagesPage(
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: "/image-detail",
        name: imageDetail,
        builder: (BuildContext context, GoRouterState state) {
          return ImageDetailPage(
            key: state.pageKey,
            image: state.extra as File,
          );
        },
      ),
      GoRoute(
        path: "/test-yolo8-seg",
        name: testYolo8Seg,
        builder: (BuildContext context, GoRouterState state) {
          return Yolo8SegTestPage(
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: "/test-yolo8-det",
        name: testYolo8Det,
        builder: (BuildContext context, GoRouterState state) {
          return Yolo8DetTestPage(
            key: state.pageKey,
          );
        },
      ),
    ],
  );
}
