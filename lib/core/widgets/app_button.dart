import 'package:flutter/material.dart';

enum AppButtonVariant {
  filled,
  outlined,
  text,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = _AppButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
    );

    return switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };
  }
}

class _AppButtonContent extends StatelessWidget {
  const _AppButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
