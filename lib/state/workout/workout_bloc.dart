import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:workout_timer/state/state.dart';
import 'package:workout_timer/helpers/timer.dart';
import 'package:vibration/vibration.dart';

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

const delayBetweenRunningState = Duration(seconds: 2);

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  late final WatchTimer _timer;

  final SettingsData settings;

  WorkoutBloc(this.settings) : super(const WorkoutState.beginning()) {
    on<_StartEvent>(_start);
    on<_PauseEvent>(_pause);
    on<_ProceedEvent>(_continue);
    on<_FinishEvent>(_finish);
    on<_RestEvent>(_rest);
    on<_WorkEvent>(_work);

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

    add(const WorkoutEvent.start());
  }

  Stream<Duration> get time => _timer.time;

  Stream<WatchTimerState> get timerState => _timer.state;

  Future<void> _start(_StartEvent event, Emitter<WorkoutState> emitter) async {
    emitter(WorkoutState.running(
      currentSet: 1,
      currentRound: 1,
      type: WorkoutType.doing,
    ));
    _timer.setTime(settings.timeWork);
    _timer.start();
  }

  Future<void> _finish(
    _FinishEvent event,
    Emitter<WorkoutState> emitter,
  ) async {
    emitter(const WorkoutState.finished());
    _timer.stop();
    _timer.setTime(settings.timeWork);
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
        _timer.start();
      },
      orElse: () {},
    );
  }

  Future<void> _rest(_RestEvent event, Emitter<WorkoutState> emitter) async {
    await state.maybeWhen(
      running: (currentSet, currentRound, type) async {
        await _announceStateChange();

        await Future.delayed(delayBetweenRunningState);

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
      orElse: () async {},
    );
  }

  Future<void> _work(_WorkEvent event, Emitter<WorkoutState> emitter) async {
    await state.maybeWhen(
      running: (currentSet, currentRound, type) async {
        await _announceStateChange();

        await Future.delayed(delayBetweenRunningState);

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
      orElse: () async {},
    );
  }

  Future<void> _announceStateChange() async {
    final hasVibrator = (await Vibration.hasVibrator()) ?? false;

    if (!hasVibrator) {
      return;
    }

    // wait 250ms, vibrate 500ms, wait 250ms, vibrate 500ms)
    Vibration.vibrate(pattern: [250, 500, 250, 500]);
  }

  @override
  Future<void> close() {
    _timer.dispose();
    return super.close();
  }
}
