import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'label_images_event.dart';
part 'label_images_state.dart';

@injectable
class LabelImagesBloc extends Bloc<LabelImagesEvent, LabelImagesState> {
  LabelImagesBloc() : super(LabelImagesInitial()) {
    on<UpdateLabel>(_updateLabel);
    on<StartCountDown>(_startCountDown);
  }

  FutureOr<void> _updateLabel(
      UpdateLabel event, Emitter<LabelImagesState> emit) {
    emit(LabelUpdated(state.stateData.copyWith(label: event.label)));
  }

  Future<void> _startCountDown(
      StartCountDown event, Emitter<LabelImagesState> emit) async {
    emit(UpdateCountDown(state.stateData.copyWith(countDown: event.countDown)));
    await for (final countdown in _countDownStream(event.countDown)) {
      if (countdown < 0) {
        emit(CountDownFinished(state.stateData.copyWith(countDown: -1)));
      } else {
        emit(UpdateCountDown(state.stateData.copyWith(countDown: countdown)));
      }
    }
  }

  Stream<int> _countDownStream(int start) async* {
    int countDown = start;
    while (countDown >= 0) {
      await Future.delayed(const Duration(seconds: 1));
      countDown--;
      yield countDown;
    }
    yield -1;
  }
}
