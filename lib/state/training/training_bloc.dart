import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_train_clock/state/settings/settings.dart';
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
  late final StopWatchTimer _timer;

  final SettingsData settings;

  TrainingBloc(this.settings) : super(const TrainingState.beginning()) {
    on<_StartEvent>((_, emit) => _start(emit));
    on<_PauseEvent>((_, emit) => _pause(emit));
    on<_ProceedEvent>((_, emit) => _continue(emit));
    on<_FinishEvent>((_, emit) => _finish(emit));
    on<_RestEvent>((_, emit) => _rest(emit));
    on<_WorkEvent>((_, emit) => _work(emit));

    _timer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      onChange: (value) {
        final shouldChangeState = value == 0 &&
            state.maybeWhen(
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

  Stream<int> get time => _timer.secondTime;

  void _start(Emitter<TrainingState> emitter) {
    add(const TrainingEvent.work());
  }

  void _finish(Emitter<TrainingState> emitter) {
    _timer.onResetTimer();
    emitter(const TrainingState.finished());
  }

  void _pause(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        _timer.onStopTimer();
        emitter(TrainingState.paused(
          currentSet: currentSet,
          currentRound: currentRound,
          type: type,
        ));
      },
      orElse: () {},
    );
  }

  void _continue(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      paused: (currentSet, currentRound, type) {
        _timer.onStartTimer();
        emitter(TrainingState.running(
          currentSet: currentSet,
          currentRound: currentRound,
          type: type,
        ));
      },
      orElse: () {},
    );
  }

  void _rest(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        _timer.onResetTimer();
        _timer.setPresetTime(mSec: settings.timeRest.inMilliseconds, add: false);
        _timer.onStartTimer();

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
      },
      orElse: () {},
    );
  }

  void _work(Emitter<TrainingState> emitter) {
    state.maybeWhen(
      running: (currentSet, currentRound, type) {
        _timer.onResetTimer();
        _timer.setPresetTime(mSec: settings.timeWork.inMilliseconds, add: false);
        _timer.onStartTimer();

        final isLastSet = currentSet == settings.countSets;

        final set = isLastSet ? 1 : ++currentSet;
        final round = isLastSet ? ++currentRound : currentRound;

        emitter(TrainingState.running(
          currentSet: set,
          currentRound: round,
          type: TrainingType.doing,
        ));
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
