import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/state/state.dart';
import 'package:my_train_clock/ui/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      appbar: CustomNavigationBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Center(
              child: TextWidget(
                'Workout\nTimer',
                size: TextSize.s40,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Button('Start', onPressed: () {
            Navigator.pushNamed(context, '/workout');
          }),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    BottomSheetModal(
      appbar: const BottomSheetNavigationBar(
        trailing: 'Close',
      ),
      shrink: true,
      child: _SettingsContentSheet(),
    ).show(context);
  }
}

class _SettingsContentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsData>(builder: (context, state) {
      return ReactiveFormBuilder(
        form: () {
          return FormGroup({
            'countSets': FormControl<int>(
              value: state.countSets,
            ),
            'countRounds': FormControl<int>(
              value: state.countRounds,
            ),
            'timeRest': FormControl<int>(
              value: state.timeRest.inSeconds,
            ),
            'timeWork': FormControl<int>(
              value: state.timeWork.inSeconds,
            ),
          });
        },
        builder: (
          context,
          FormGroup formGroup,
          Widget? child,
        ) {
          return Column(
            children: [
              ReactiveTextField(
                formControlName: 'countSets',
                decoration: const InputDecoration(
                  labelText: 'Sets count',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'countRounds',
                decoration: const InputDecoration(
                  labelText: 'Rounds count',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'timeWork',
                decoration: const InputDecoration(
                  labelText: 'Exercise time (sec)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'timeRest',
                decoration: const InputDecoration(
                  labelText: 'Rest time (sec)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 48),
              Button(
                'Save',
                onPressed: () => _save(context, formGroup),
                type: ButtonType.filled,
              ),
            ],
          );
        },
      );
    });
  }

  void _save(BuildContext context, FormGroup formGroup) {
    final workTime = formGroup.control('timeWork').value;
    final restTime = formGroup.control('timeRest').value;

    final bloc = context.read<SettingsBloc>();
    bloc.add(
      SettingsEvent.update(
        data: SettingsData.fromJson(
          {
            ...formGroup.value,
            'timeWork': Duration.microsecondsPerSecond * workTime,
            'timeRest': Duration.microsecondsPerSecond * restTime,
          },
        ),
      ),
    );

    Navigator.pop(context);
  }
}
