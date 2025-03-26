import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: Colors.white,
        valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}
