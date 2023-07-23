import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_train_clock/pages/welcome_screen.dart';

import 'helpers/themes.dart';
import 'state/state.dart';
import 'pages/workout_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SettingsBloc(),
      child: _App(),
    );
  }
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      theme: lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/workout': (context) => const WorkoutScreen(),
      },
    );
  }
}
