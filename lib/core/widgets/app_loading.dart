import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message = '불러오는 중이에요'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
