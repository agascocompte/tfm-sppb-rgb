import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'gather_image_event.dart';
part 'gather_image_state.dart';

@injectable
class GatherImageBloc extends Bloc<GatherImageEvent, GatherImageState> {
  GatherImageBloc() : super(GatherImageInitial()) {}
}
