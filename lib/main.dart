import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/di/dependency_injector.dart';
import 'package:sppb_rgb/pages/label_images/bloc/label_images_bloc.dart';
import 'package:sppb_rgb/pages/view_captured_images/bloc/view_captured_images_bloc.dart';
import 'package:sppb_rgb/pages/yolo8_test/bloc/yolo8_test_bloc.dart';
import 'package:sppb_rgb/router/router.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled = true;
  configureDependencies('dev');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
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
            create: (context) => sl<Yolo8TestBloc>()..add(LoadModels())),
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
