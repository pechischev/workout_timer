import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:workout_timer/helpers/timer.dart';

import 'workout_bloc.dart';

abstract class WorkoutTimer {
  void pause();

  void proceed();

  void stop();

  void run(Duration time, WorkoutType type);

  void dispose();

  Stream<Duration> get time;

  Stream<WatchTimerState> get timerState;
}

class WorkoutTimerImpl implements WorkoutTimer {
  late WatchTimer _timer;

  final delayForRun = const Duration(seconds: 1);
  final delayForStop = const Duration(seconds: 1);

  WorkoutTimerImpl({VoidCallback? onStop}) {
    _timer = WatchTimer(onStop: onStop);
  }

  @override
  void pause() {
    _timer.pause();
  }

  @override
  void proceed() {
    _timer.start();
  }

  @override
  void run(Duration time, WorkoutType type) {
    _timer.setTime(time);
    Future.delayed(delayForRun, () => _timer.restart());
  }

  @override
  void stop() {
    Future.delayed(delayForStop, () => _timer.stop());
  }

  @override
  void dispose() {
    _timer.dispose();
  }

  @override
  Stream<Duration> get time => _timer.time;

  @override
  Stream<WatchTimerState> get timerState => _timer.state;
}

class DefaultWorkoutDecorator extends WorkoutTimer {
  final WorkoutTimer _wrappee;

  DefaultWorkoutDecorator(WorkoutTimer instance) : _wrappee = instance;

  @override
  void pause() {
    _wrappee.pause();
  }

  @override
  void proceed() {
    _wrappee.proceed();
  }

  @override
  void run(Duration time, WorkoutType type) {
    _wrappee.run(time, type);
  }

  @override
  void stop() {
    _wrappee.stop();
  }

  @override
  void dispose() {
    _wrappee.dispose();
  }

  @override
  Stream<Duration> get time => _wrappee.time;

  @override
  Stream<WatchTimerState> get timerState => _wrappee.timerState;
}

class VibrationDecorator extends DefaultWorkoutDecorator {
  VibrationDecorator(super.instance);

  @override
  void run(Duration time, WorkoutType type) async {
    await _vibrate();
    super.run(time, type);
  }

  @override
  void stop() async {
    await _vibrate();
    super.stop();
  }

  Future<void> _vibrate() async {
    final hasVibrator = (await Vibration.hasVibrator()) ?? false;

    if (!hasVibrator) {
      return;
    }

    Vibration.vibrate(duration: const Duration(seconds: 2).inMilliseconds);
  }

  @override
  void dispose() {
    Vibration.cancel();
    super.dispose();
  }
}

class AudioDecorator extends DefaultWorkoutDecorator {
  late final AudioPlayer startingPlayer;
  late final AudioPlayer stoppingPlayer;

  AudioDecorator(super.instance) {
    startingPlayer = AudioPlayer()..setAsset('assets/start.mp3');
    stoppingPlayer = AudioPlayer()..setAsset('assets/stop.mp3');
  }

  @override
  void run(Duration time, WorkoutType type) async {
    final player = type == WorkoutType.doing ? startingPlayer : stoppingPlayer;

    await player.seek(const Duration());
    await player.play();
    super.run(time, type);
    player.pause();
  }

  @override
  void stop() async {
    await stoppingPlayer.seek(const Duration());
    await stoppingPlayer.play();
    super.stop();
    stoppingPlayer.pause();
  }

  @override
  void dispose() {
    startingPlayer.dispose();
    stoppingPlayer.dispose();
    super.dispose();
  }
}
