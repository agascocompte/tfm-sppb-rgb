import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/di/dependency_injector.dart';
import 'package:sppb_rgb/pages/label_images/bloc/label_images_bloc.dart';
import 'package:sppb_rgb/pages/raw_test/bloc/raw_test_bloc.dart';
import 'package:sppb_rgb/pages/view_captured_images/bloc/view_captured_images_bloc.dart';
import 'package:sppb_rgb/pages/yolo8_det_test.dart/bloc/yolo8_det_test_bloc.dart';
import 'package:sppb_rgb/pages/yolo8_seg_test/bloc/yolo8_seg_test_bloc.dart';
import 'package:sppb_rgb/router/router.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled = true;
  configureDependencies('dev');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                sl<CameraViewBloc>()..add(InitializeCameras())),
        BlocProvider(create: (context) => sl<LabelImagesBloc>()),
        BlocProvider(create: (context) => sl<ViewCapturedImagesBloc>()),
        BlocProvider(
            create: (context) => sl<Yolo8SegTestBloc>()..add(LoadSegModels())),
        BlocProvider(
            create: (context) => sl<Yolo8DetTestBloc>()..add(LoadDetModels())),
        BlocProvider(create: (context) => sl<RawTestBloc>()..add(LoadModel())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'SPPB Tests',
        routeInformationParser: AppRouter.router.routeInformationParser,
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        routerDelegate: AppRouter.router.routerDelegate,
        locale: const Locale.fromSubtags(languageCode: 'es'),
      ),
    );
  }
}
