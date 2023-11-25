import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:workout_timer/state/state.dart';
import 'package:workout_timer/helpers/timer.dart';

import 'workout_timer.dart';

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
  doing('Go');

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

  const factory WorkoutState.finished() = _FinishedState;
}

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  late final WorkoutTimer _timer;

  final SettingsData settings;

  WorkoutBloc(this.settings) : super(const WorkoutState.beginning()) {
    on<_StartEvent>(_start);
    on<_PauseEvent>(_pause);
    on<_ProceedEvent>(_continue);
    on<_FinishEvent>(_finish);
    on<_RestEvent>(_rest);
    on<_WorkEvent>(_work);

    var timer = DefaultWorkoutDecorator(
      WorkoutTimerImpl(
        onStop: _changeRunningState,
      ),
    );

    // TODO: set flag for switching type
    // timer = VibrationDecorator(timer);
    timer = AudioDecorator(timer);

    _timer = timer;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      add(const WorkoutEvent.start());
    });
  }

  Stream<Duration> get time => _timer.time;

  Stream<WatchTimerState> get timerState => _timer.timerState;

  void _changeRunningState() {
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
  }

  Future<void> _start(_StartEvent event, Emitter<WorkoutState> emitter) async {
    const type = WorkoutType.doing;
    emitter(WorkoutState.running(
      currentSet: 1,
      currentRound: 1,
      type: type,
    ));

    _timer.run(settings.timeWork, type);
  }

  Future<void> _finish(
    _FinishEvent event,
    Emitter<WorkoutState> emitter,
  ) async {
    emitter(const WorkoutState.finished());
    _timer.stop();
  }

  Future<void> _pause(_PauseEvent event, Emitter<WorkoutState> emitter) async {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        _timer.pause();
      },
      orElse: () {},
    );
  }

  Future<void> _continue(
    _ProceedEvent event,
    Emitter<WorkoutState> emitter,
  ) async {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        _timer.proceed();
      },
      orElse: () {},
    );
  }

  Future<void> _rest(_RestEvent event, Emitter<WorkoutState> emitter) async {
    await state.maybeWhen(
      running: (currentSet, currentRound, type) async {
        final isLastRound = currentRound == settings.countRounds;
        final isLastSet = currentSet == settings.countSets;
        final isFinishWorkout = isLastRound && isLastSet;

        if (isFinishWorkout) {
          emitter(const WorkoutState.finished());
          return;
        }

        const nextType = WorkoutType.resting;

        emitter(WorkoutState.running(
          currentSet: currentSet,
          currentRound: currentRound,
          type: nextType,
        ));
        _timer.run(settings.timeRest, nextType);
      },
      orElse: () async {},
    );
  }

  Future<void> _work(_WorkEvent event, Emitter<WorkoutState> emitter) async {
    await state.maybeWhen(
      running: (currentSet, currentRound, type) async {
        final isLastSet = currentSet == settings.countSets;

        final set = isLastSet ? 1 : ++currentSet;
        final round = isLastSet ? ++currentRound : currentRound;

        const nextType = WorkoutType.doing;

        emitter(WorkoutState.running(
          currentSet: set,
          currentRound: round,
          type: nextType,
        ));
        _timer.run(settings.timeWork, nextType);
      },
      orElse: () async {},
    );
  }

  @override
  Future<void> close() {
    _timer.dispose();
    return super.close();
  }
}
