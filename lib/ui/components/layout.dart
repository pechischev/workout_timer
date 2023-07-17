import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final PreferredSizeWidget? appbar;
  final EdgeInsetsGeometry padding;
  final Widget body;

  const Layout({
    super.key,
    required this.body,
    this.appbar,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbar,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: body,
          ),
        ),
      ),
    );
  }
}
