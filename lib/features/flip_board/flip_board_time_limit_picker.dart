import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

Future<int?> showFlipBoardTimeLimitPicker(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            for (final seconds
                in AppConstants.flipBoardTimeLimitOptionsSeconds) ...[
              _TimeLimitOption(
                seconds: seconds,
                onTap: () => Navigator.of(context).pop(seconds),
              ),
              if (seconds != AppConstants.flipBoardTimeLimitOptionsSeconds.last)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    ),
  );
}

class FlipBoardTimeLimitSelector extends StatelessWidget {
  const FlipBoardTimeLimitSelector({
    super.key,
    required this.selectedSeconds,
    required this.onChanged,
  });

  final int selectedSeconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      selected: {selectedSeconds},
      onSelectionChanged: (values) => onChanged(values.single),
      segments: [
        for (final seconds in AppConstants.flipBoardTimeLimitOptionsSeconds)
          ButtonSegment<int>(
            value: seconds,
            icon: Icon(_iconFor(seconds)),
            label: Text(flipBoardTimeLimitLabel(seconds)),
          ),
      ],
    );
  }
}

String flipBoardTimeLimitLabel(int seconds) {
  if (seconds == 60) {
    return '1분';
  }
  return '$seconds초';
}

String flipBoardTimeLimitDescription(int seconds) {
  if (seconds == 60) {
    return '여유 있게 많이 뒤집기';
  }
  return '짧게 집중해서 빠르게 뒤집기';
}

class _TimeLimitOption extends StatelessWidget {
  const _TimeLimitOption({required this.seconds, required this.onTap});

  final int seconds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seconds == 60 ? AppColors.blue : AppColors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(_iconFor(seconds), color: AppColors.textPrimary, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flipBoardTimeLimitLabel(seconds),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      flipBoardTimeLimitDescription(seconds),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(int seconds) {
  return seconds == 60 ? Icons.hourglass_bottom : Icons.timer;
}
