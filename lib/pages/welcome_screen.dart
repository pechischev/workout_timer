import 'package:flutter/material.dart';
import 'package:my_train_clock/ui/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      appbar: CustomNavigationBar(
        title: '',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
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
}
