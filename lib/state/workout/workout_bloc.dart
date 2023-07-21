import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:my_train_clock/state/state.dart';
import 'package:my_train_clock/helpers/timer.dart';

part 'workout_bloc.freezed.dart';

@freezed
class WorkoutEvent with _$WorkoutEvent {
  const WorkoutEvent._();

  @literal
  const factory WorkoutEvent.start() = _StartEvent;

  @literal
  const factory WorkoutEvent.pause() = _PauseEvent;

  @literal
  const factory WorkoutEvent.finish() = _FinishEvent;

  @literal
  const factory WorkoutEvent.rest() = _RestEvent;

  @literal
  const factory WorkoutEvent.work() = _WorkEvent;

  @literal
  const factory WorkoutEvent.proceed() = _ProceedEvent;
}

enum WorkoutType {
  resting('Rest'),
  doing('Work');

  const WorkoutType(this.name);

  final String name;
}

@freezed
class WorkoutState with _$WorkoutState {
  const WorkoutState._();

  const factory WorkoutState.beginning() = _BeginningState;

  @Assert('currentSet > 0')
  @Assert('currentRound > 0')
  factory WorkoutState.running({
    required int currentSet,
    required int currentRound,
    @Default(WorkoutType.doing) WorkoutType type,
  }) = _RunningState;

  @Assert('currentSet > 0')
  @Assert('currentRound > 0')
  factory WorkoutState.paused({
    required int currentSet,
    required int currentRound,
    required WorkoutType type,
  }) = _PausedState;

  const factory WorkoutState.finished() = _FinishedState;
}

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  late final WatchTimer _timer;

  final SettingsData settings;

  WorkoutBloc(this.settings) : super(const WorkoutState.beginning()) {
    on<_StartEvent>((_, emit) => _start(emit));
    on<_PauseEvent>((_, emit) => _pause(emit));
    on<_ProceedEvent>((_, emit) => _continue(emit));
    on<_FinishEvent>((_, emit) => _finish(emit));
    on<_RestEvent>((_, emit) => _rest(emit));
    on<_WorkEvent>((_, emit) => _work(emit));

    _timer = WatchTimer(
      time: settings.timeWork,
      onStop: () {
        final shouldChangeState = state.maybeWhen(
          running: (_, __, ___) => true,
          orElse: () => false,
        );
        if (shouldChangeState) {
          state.whenOrNull(
            running: (_, __, type) {
              final action = type == WorkoutType.doing
                  ? WorkoutEvent.rest
                  : WorkoutEvent.work;
              add(action());
            },
          );
        }
      },
    );
  }

  Stream<Duration> get time => _timer.time;

  void _start(Emitter<WorkoutState> emitter) {
    emitter(WorkoutState.running(
      currentSet: 1,
      currentRound: 1,
      type: WorkoutType.doing,
    ));
    _timer.setTime(settings.timeWork);
    _timer.start();
  }

  void _finish(Emitter<WorkoutState> emitter) {
    emitter(const WorkoutState.finished());
    _timer.stop();
    _timer.setTime(settings.timeWork);
  }

  void _pause(Emitter<WorkoutState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        emitter(WorkoutState.paused(
          currentSet: currentSet,
          currentRound: currentRound,
          type: type,
        ));
        _timer.pause();
      },
      orElse: () {},
    );
  }

  void _continue(Emitter<WorkoutState> emitter) {
    state.maybeWhen(
      paused: (currentSet, currentRound, type) {
        emitter(WorkoutState.running(
          currentSet: currentSet,
          currentRound: currentRound,
          type: type,
        ));
        _timer.start();
      },
      orElse: () {},
    );
  }

  void _rest(Emitter<WorkoutState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        final isLastRound = currentRound == settings.countRounds;
        final isLastSet = currentSet == settings.countSets;
        final isFinishWorkout = isLastRound && isLastSet;

        if (isFinishWorkout) {
          emitter(const WorkoutState.finished());
          return;
        }

        emitter(WorkoutState.running(
          currentSet: currentSet,
          currentRound: currentRound,
          type: WorkoutType.resting,
        ));

        _timer.setTime(settings.timeRest);
        _timer.restart();
      },
      orElse: () {},
    );
  }

  void _work(Emitter<WorkoutState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        final isLastSet = currentSet == settings.countSets;

        final set = isLastSet ? 1 : ++currentSet;
        final round = isLastSet ? ++currentRound : currentRound;

        emitter(WorkoutState.running(
          currentSet: set,
          currentRound: round,
          type: WorkoutType.doing,
        ));
        _timer.setTime(settings.timeWork);
        _timer.restart();
      },
      orElse: () {},
    );
  }

  @override
  Future<void> close() {
    _timer.dispose();
    return super.close();
  }
}
