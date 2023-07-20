import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/state/settings/settings.dart';
import 'package:my_train_clock/state/training/training.dart';
import 'package:my_train_clock/ui/widgets.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          TrainingBloc(context.read<SettingsBloc>().state),
      child: _TrainingScreenContent(),
    );
  }
}

class _TrainingScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            BlocBuilder<TrainingBloc, TrainingState>(
              builder: (context, state) {
                return state.maybeMap(
                  running: (value) => _TrainingInformationWidget(
                    set: value.currentSet,
                    round: value.currentRound,
                  ),
                  paused: (value) => _TrainingInformationWidget(
                    set: value.currentSet,
                    round: value.currentRound,
                  ),
                  orElse: () => const SizedBox(height: 23),
                );
              },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocBuilder<TrainingBloc, TrainingState>(
                    builder: (context, state) {
                      final label = state.maybeMap(
                        running: (value) => value.type.name,
                        paused: (value) => value.type.name,
                        orElse: () => 'Start training',
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

                      return Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<TrainingBloc, TrainingState>(
                    builder: (context, state) {
                      final bloc = context.read<TrainingBloc>();

                      return state.maybeMap(
                        running: (_) => _TimerButton(
                          icon: Icons.pause,
                          onTap: () => bloc.add(const TrainingEvent.pause()),
                        ),
                        paused: (_) => _TimerButton(
                          icon: Icons.play_arrow,
                          onTap: () => bloc.add(const TrainingEvent.proceed()),
                        ),
                        orElse: () => _TimerButton(
                          icon: Icons.play_arrow,
                          onTap: () => bloc.add(const TrainingEvent.start()),
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TrainingInformationWidget extends StatelessWidget {
  final int set;
  final int round;

  const _TrainingInformationWidget({required this.set, required this.round});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;

    return Row(
      children: [
        Text(
          'Sets: $set/${settingsState.countSets}',
          style: const TextStyle(fontSize: 20),
        ),
        const Spacer(),
        Text(
          'Rounds: $round/${settingsState.countRounds}',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}

class _TimerButton extends StatelessWidget {
  final Function onTap;
  final IconData icon;

  const _TimerButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 64,
      onPressed: () => onTap(),
      icon: Icon(icon, size: 64),
    );
  }
}
