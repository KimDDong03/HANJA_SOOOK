import 'package:flutter/material.dart';

import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title = '문제가 발생했어요',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                AppButton(
                  label: '다시 시도',
                  onPressed: onRetry,
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
