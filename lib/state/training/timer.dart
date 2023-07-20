import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class WatchTimer {
  final Function(Duration)? onChange;
  final VoidCallback? onStop;

  Timer? _timer;
  Duration _time = const Duration();
  Duration _startTime = const Duration();
  Duration _stopTime = const Duration();

  final PublishSubject<Duration> _elapsedTime = PublishSubject<Duration>();
  final BehaviorSubject<Duration> _timeController =
      BehaviorSubject<Duration>.seeded(const Duration());

  WatchTimer({
    Duration time = const Duration(),
    this.onChange,
    this.onStop,
  }) {
    _time = time;
    _timeController.add(time);
    _elapsedTime.listen((value) {
      _timeController.add(value);
      if (onChange != null) {
        onChange!(value);
      }
    });
  }

  ValueStream<Duration> get time => _timeController;

  bool get isRunning => _timer != null && _timer!.isActive;

  Duration get _currentTime =>
      Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

  void setTime(Duration time) {
    _time = time;
  }

  void start() {
    if (!isRunning) {
      _startTime = _currentTime;
      _timer = Timer.periodic(const Duration(milliseconds: 1), (Timer timer) {
        final passedTime = _currentTime - _startTime + _stopTime;
        final leftTime = max(
          (_time - passedTime).inMilliseconds,
          0,
        );
        _elapsedTime.add(Duration(milliseconds: leftTime));
        if (leftTime == 0) {
          stop();
        }
      });
    }
  }

  void pause() {
    if (!isRunning) {
      return;
    }

    _timer!.cancel();
    _timer = null;
    _stopTime = _currentTime - _startTime;
  }

  void stop() {
    if (!isRunning) {
      return;
    }

    _timer!.cancel();
    _timer = null;

    if (onStop != null) {
      onStop!();
    }

    _startTime = const Duration();
    _stopTime = const Duration();
    _elapsedTime.add(_time);
  }

  void restart() {
    if (isRunning) {
      stop();
    }

    start();
  }

  Future<void> dispose() async {
    if (_elapsedTime.isClosed) {
      throw Exception(
        'This instance is already disposed. Please re-create WatchTimer instance.',
      );
    }

    final timer = _timer;
    if (timer != null && timer.isActive) {
      timer.cancel();
    }

    await Future.wait<void>([
      _elapsedTime.close(),
      _timeController.close(),
    ]);
  }
}
