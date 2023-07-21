import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/state/state.dart';
import 'package:my_train_clock/ui/widgets.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          WorkoutBloc(context.read<SettingsBloc>().state),
      child: _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      appbar: const CustomNavigationBar(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                return state.maybeMap(
                  running: (value) => _WorkoutInformationWidget(
                    set: value.currentSet,
                    round: value.currentRound,
                  ),
                  paused: (value) => _WorkoutInformationWidget(
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
                  BlocBuilder<WorkoutBloc, WorkoutState>(
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
                    stream: context.read<WorkoutBloc>().time,
                    builder: (context, snap) {
                      final value = snap.data ?? const Duration();

                      return Text(
                        value.inSeconds.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<WorkoutBloc, WorkoutState>(
                    builder: (context, state) {
                      final bloc = context.read<WorkoutBloc>();

                      return state.maybeMap(
                        running: (_) => _TimerButton(
                          icon: Icons.pause,
                          onTap: () => bloc.add(const WorkoutEvent.pause()),
                        ),
                        paused: (_) => _TimerButton(
                          icon: Icons.play_arrow,
                          onTap: () => bloc.add(const WorkoutEvent.proceed()),
                        ),
                        orElse: () => _TimerButton(
                          icon: Icons.play_arrow,
                          onTap: () => bloc.add(const WorkoutEvent.start()),
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

class _WorkoutInformationWidget extends StatelessWidget {
  final int set;
  final int round;

  const _WorkoutInformationWidget({required this.set, required this.round});

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
