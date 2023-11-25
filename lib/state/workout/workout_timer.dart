import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:workout_timer/helpers/timer.dart';

abstract class WorkoutTimer {
  void pause();

  void proceed();

  void stop();

  void run(Duration time);

  void dispose();

  Stream<Duration> get time;

  Stream<WatchTimerState> get timerState;
}

class WorkoutTimerImpl implements WorkoutTimer {
  late WatchTimer _timer;

  final delayForRun = const Duration(seconds: 4);
  final delayForStop = const Duration(seconds: 2);

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
  void run(Duration time) {
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
  void run(Duration time) {
    _wrappee.run(time);
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
  void run(Duration time) async {
    await _vibrate();
    super.run(time);
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
