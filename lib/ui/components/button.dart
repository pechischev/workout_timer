import 'package:flutter/material.dart';

enum ButtonType { text, filled }

class Button extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool disabled;
  final ButtonType type;

  const Button(
    this.title, {
    super.key,
    required this.onPressed,
    this.disabled = false,
    this.type = ButtonType.text,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ButtonType.filled) {
      return FilledButton(
        onPressed: disabled ? null : onPressed,
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.resolveWith(
              (states) => const Size.fromHeight(50)),
        ),
        child: _ButtonText(title),
      );
    }

    return TextButton(
      onPressed: disabled ? null : onPressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.resolveWith(
            (states) => const Size.fromHeight(50)),
      ),
      child: _ButtonText(title),
    );
  }
}

class _ButtonText extends StatelessWidget {
  final String title;

  const _ButtonText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20),
    );
  }
}
