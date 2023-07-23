import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/helpers/timer.dart';
import 'package:my_train_clock/state/state.dart';
import 'package:my_train_clock/ui/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          WorkoutBloc(context.read<SettingsBloc>().state),
      child: Layout(
        appbar: const CustomNavigationBar(),
        body: BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, state) {
            return state.maybeMap(
              running: (value) => _WorkoutRunning(
                currentSet: value.currentSet,
                currentRound: value.currentRound,
                type: value.type,
              ),
              finished: (value) => _WorkoutFinished(),
              orElse: () => Container(),
            );
          },
        ),
      ),
    );
  }
}

/// screen states

// TODO: refactoring
class _WorkoutRunning extends StatelessWidget {
  final int currentSet;
  final int currentRound;
  final WorkoutType type;

  const _WorkoutRunning({
    required this.currentSet,
    required this.currentRound,
    required this.type,
  });

  final double diagramSize = 240;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  type.name.toUpperCase(),
                  size: TextSize.s48,
                  weight: TextWeight.semibold,
                ),
                const SizedBox(height: 48),
                StreamBuilder(
                  stream: context.read<WorkoutBloc>().time,
                  builder: (context, snap) {
                    final settingsState = context.watch<SettingsBloc>().state;
                    final time = snap.data ?? const Duration();
                    final isDoing = type == WorkoutType.doing;
                    final allTime = isDoing
                        ? settingsState.timeWork
                        : settingsState.timeRest;

                    final percent = 1 - (time.inSeconds / allTime.inSeconds);

                    return SizedBox(
                      height: diagramSize,
                      child: CircularPercentIndicator(
                        radius: diagramSize / 2,
                        lineWidth: 8.0,
                        percent: percent,
                        animation: true,
                        animateFromLastPercent: true,
                        progressColor: isDoing ? Colors.green : Colors.blue,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget(
                              time.inSeconds.toString(),
                              size: TextSize.s40,
                            ),
                            const SizedBox(height: 20),
                            TextWidget(
                              'Sets $currentSet of ${settingsState.countSets}',
                            ),
                            const SizedBox(height: 4),
                            TextWidget(
                              'Rounds $currentRound of ${settingsState.countRounds}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                _WorkoutTimerButton(),
              ],
            ),
          ),
          Button(
            'Finish',
            onPressed: () => _finishWorkout(context),
          ),
        ],
      ),
    );
  }

  void _finishWorkout(BuildContext context) async {
    context.read<WorkoutBloc>().add(const WorkoutEvent.pause());

    showDialog<bool>(
      context: context,
      builder: (_) => _FinishAgreementDialog(
        onAgree: () {
          context.read<WorkoutBloc>().add(const WorkoutEvent.finish());
          Navigator.pop(context);
        },
        onDisagree: () {
          context.read<WorkoutBloc>().add(const WorkoutEvent.proceed());
        },
      ),
    );
  }
}

class _WorkoutFinished extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: TextWidget(
        "Congratulations!\nYou've finished your workout",
        size: TextSize.s24,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// widgets

class _FinishAgreementDialog extends StatelessWidget {
  final Function() onAgree;
  final Function() onDisagree;

  const _FinishAgreementDialog({
    required this.onAgree,
    required this.onDisagree,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you really finish your workout?'),
      actions: <Widget>[
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
            onDisagree();
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop();
            onAgree();
          },
        ),
      ],
    );
  }
}

class _WorkoutTimerButton extends StatelessWidget {
  final icons = {
    WatchTimerState.running: Icons.pause,
    WatchTimerState.paused: Icons.play_arrow
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<WorkoutBloc>().timerState,
      builder: (context, snap) {
        final bloc = context.watch<WorkoutBloc>();
        final isTimerRunning = snap.data == WatchTimerState.running;

        final icon = icons.putIfAbsent(
            snap.data ?? WatchTimerState.running, () => Icons.pause);

        return IconButton(
          iconSize: 64,
          onPressed: () {
            final action = isTimerRunning
                ? const WorkoutEvent.pause()
                : const WorkoutEvent.proceed();
            bloc.add(action);
          },
          icon: Icon(icon, size: 64),
        );
      },
    );
  }
}
