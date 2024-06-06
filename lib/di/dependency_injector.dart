import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:sppb_rgb/di/dependency_injector.config.dart';

final sl = GetIt.instance;

@InjectableInit(asExtension: true)
Future<void> configureDependencies(String environment) async {
  sl.init(environment: environment);
}

// flutter packages pub run build_runner watch