import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:my_train_clock/state/state.dart';
import 'package:my_train_clock/helpers/timer.dart';

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
  const factory TrainingEvent.work() = _WorkEvent;

  @literal
  const factory TrainingEvent.proceed() = _ProceedEvent;
}

enum TrainingType {
  resting('Rest'),
  doing('Work');

  const TrainingType(this.name);

  final String name;
}

@freezed
class TrainingState with _$TrainingState {
  const TrainingState._();

  const factory TrainingState.beginning() = _BeginningState;

  @Assert('currentSet > 0')
  @Assert('currentRound > 0')
  factory TrainingState.running({
    required int currentSet,
    required int currentRound,
    @Default(TrainingType.doing) TrainingType type,
  }) = _RunningState;

  @Assert('currentSet > 0')
  @Assert('currentRound > 0')
  factory TrainingState.paused({
    required int currentSet,
    required int currentRound,
    required TrainingType type,
  }) = _PausedState;

  const factory TrainingState.finished() = _FinishedState;
}

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  late final WatchTimer _timer;

  final SettingsData settings;

  TrainingBloc(this.settings) : super(const TrainingState.beginning()) {
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
              final action = type == TrainingType.doing
                  ? TrainingEvent.rest
                  : TrainingEvent.work;
              add(action());
            },
          );
        }
      },
    );
  }

  Stream<Duration> get time => _timer.time;

  void _start(Emitter<TrainingState> emitter) {
    emitter(TrainingState.running(
      currentSet: 1,
      currentRound: 1,
      type: TrainingType.doing,
    ));
    _timer.setTime(settings.timeWork);
    _timer.start();
  }

  void _finish(Emitter<TrainingState> emitter) {
    emitter(const TrainingState.finished());
    _timer.stop();
    _timer.setTime(settings.timeWork);
  }

  void _pause(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        emitter(TrainingState.paused(
          currentSet: currentSet,
          currentRound: currentRound,
          type: type,
        ));
        _timer.pause();
      },
      orElse: () {},
    );
  }

  void _continue(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      paused: (currentSet, currentRound, type) {
        emitter(TrainingState.running(
          currentSet: currentSet,
          currentRound: currentRound,
          type: type,
        ));
        _timer.start();
      },
      orElse: () {},
    );
  }

  void _rest(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        final isLastRound = currentRound == settings.countRounds;
        final isLastSet = currentSet == settings.countSets;
        final isFinishTraining = isLastRound && isLastSet;

        if (isFinishTraining) {
          emitter(const TrainingState.finished());
          return;
        }

        emitter(TrainingState.running(
          currentSet: currentSet,
          currentRound: currentRound,
          type: TrainingType.resting,
        ));

        _timer.setTime(settings.timeRest);
        _timer.restart();
      },
      orElse: () {},
    );
  }

  void _work(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        final isLastSet = currentSet == settings.countSets;

        final set = isLastSet ? 1 : ++currentSet;
        final round = isLastSet ? ++currentRound : currentRound;

        emitter(TrainingState.running(
          currentSet: set,
          currentRound: round,
          type: TrainingType.doing,
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
