import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/state/settings/settings.dart';
import 'package:my_train_clock/state/training/training.dart';
import 'package:my_train_clock/ui/widgets.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TrainingBloc(),
      child: _TrainingScreenContent(),
    );
  }
}

class _TrainingScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      body: Column(
        children: [
          const SizedBox(height: 20),
          BlocBuilder<SettingsBloc, SettingsData>(
            builder: (context, state) => Row(
              children: [
                Text(
                  'Sets: 1/${state.countSets}',
                  style: const TextStyle(fontSize: 20),
                ),
                const Spacer(),
                Text(
                  'Rounds: 1/${state.countRounds}',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<TrainingBloc, TrainingState>(
                  builder: (context, state) {
                    final label = state.maybeWhen(
                      resting: () => 'Rest',
                      orElse: () => 'Work',
                    );
                    return Text(
                      label,
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                StreamBuilder(
                    stream: context.read<TrainingBloc>().time,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data ?? 0;
                      final displayTime = StopWatchTimer.getDisplayTime(
                        value,
                        hours: false,
                        milliSecond: false,
                      );

                      return Text(
                        displayTime,
                        style: const TextStyle(
                          fontSize: 48,
                        ),
                      );
                    }),
                const SizedBox(height: 20),
                BlocBuilder<TrainingBloc, TrainingState>(
                  builder: (context, state) {
                    final bloc = context.read<TrainingBloc>();

                    return state.when(
                      unknown: () => _TimerButton(
                        icon: Icons.play_arrow,
                        onTap: () => bloc.add(const TrainingEvent.start()),
                      ),
                      resting: () => _TimerButton(
                        icon: Icons.pause,
                        onTap: () => bloc.add(const TrainingEvent.pause()),
                      ),
                      working: () => _TimerButton(
                        icon: Icons.pause,
                        onTap: () => bloc.add(const TrainingEvent.pause()),
                      ),
                      paused: () => _TimerButton(
                        icon: Icons.play_arrow,
                        onTap: () => bloc.add(const TrainingEvent.proceed()),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final Function onTap;
  final IconData icon;

  const _TimerButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 64,
      onPressed: () => onTap(),
      icon: Icon(icon, size: 64),
    );
  }
}
