// events
// - start - начало упражения - запускает таймер на работу
// - pause - приостановить упражнение - паузит таймер
// - finish - закончить упражнение - вообще заканчивает тренировку
// - rest - отдых - запускает таймер для отдыха
// - continue - продолжить - продолжает таймер

// state
// - unknown
// - resting - time
// - working - time
// - paused - time

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

part 'training_bloc.freezed.dart';

@freezed
class TrainingEvent with _$TrainingEvent {
  const TrainingEvent._();

  @literal
  const factory TrainingEvent.start() = _StartEvent;

  @literal
  const factory TrainingEvent.pause() = _PauseEvent;

  @literal
  const factory TrainingEvent.finish() = _FinishEvent;

  @literal
  const factory TrainingEvent.rest() = _RestEvent;

  @literal
  const factory TrainingEvent.proceed() = _ProceedEvent;
}

@freezed
class TrainingState with _$TrainingState {
  const TrainingState._();

  const factory TrainingState.unknown() = _UnknownState;

  const factory TrainingState.resting() = _RestingState;

  const factory TrainingState.working() = _WorkingState;

  const factory TrainingState.paused() = _PausedState; // save prev state
}

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  late final StopWatchTimer _timer;

  final workTime = 30;
  final restTime = 10;

  TrainingBloc(): super(const TrainingState.unknown()) {
    on<_StartEvent>((_, emit) => _start(emit));
    on<_PauseEvent>((_, emit) => _pause(emit));
    on<_ProceedEvent>((_, emit) => _continue(emit));
    on<_FinishEvent>((_, emit) => _finish(emit));

    _timer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: 30 * 1000,
      onChange: (value) {
        final shouldChangeState = value == 0 ;
        if (shouldChangeState) {
          state.whenOrNull(
            working: () {
              _timer.onResetTimer();
              _timer.setPresetTime(mSec: 11 * 1000, add: false);
              _timer.onStartTimer();
              emit(const TrainingState.resting());
            },
            resting: () {
              _timer.onResetTimer();
              _timer.setPresetTime(mSec: 31 * 1000, add: false);
              _timer.onStartTimer();
              emit(const TrainingState.working());
            },

          );
        }
      },
    );
  }

  Stream<int> get time => _timer.rawTime;

  void _start(Emitter<TrainingState> emitter) {
    _timer.onStartTimer();
    emitter(const TrainingState.working());
  }

  void _finish(Emitter<TrainingState> emitter) {
    _timer.onResetTimer();
    emitter(const TrainingState.unknown());
  }

  void _pause(Emitter<TrainingState> emitter) {
    _timer.onStopTimer();
    emitter(const TrainingState.paused());
  }

  void _continue(Emitter<TrainingState> emitter) {
    _timer.onStartTimer();
    emitter(const TrainingState.working());
  }

  @override
  Future<void> close() {
    _timer.dispose();
    return super.close();
  }
}