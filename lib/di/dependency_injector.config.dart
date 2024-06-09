// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:sppb_rgb/pages/gather_image.dart/bloc/gather_image_bloc.dart'
    as _i3;
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart' as _i4;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.GatherImageBloc>(() => _i3.GatherImageBloc());
    gh.factory<_i4.CameraViewBloc>(() => _i4.CameraViewBloc());
    return this;
  }
}
