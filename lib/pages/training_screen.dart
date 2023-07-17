import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/state/settings/settings.dart';
import 'package:my_train_clock/ui/widgets.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

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
                const Text(
                  'WORK',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '00:30',
                  style: TextStyle(
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  iconSize: 64,
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow, size: 64),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
