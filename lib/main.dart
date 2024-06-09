import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/di/dependency_injector.dart';
import 'package:sppb_rgb/pages/gather_image.dart/bloc/gather_image_bloc.dart';
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
        BlocProvider(create: (context) => sl<GatherImageBloc>()),
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
