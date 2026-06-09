import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/playful_page.dart';

class SessionRewardPanel extends StatelessWidget {
  const SessionRewardPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.stats,
    required this.actions,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<SessionRewardStat> stats;
  final List<Widget> actions;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 56, color: iconColor),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < stats.length; index += 2) ...[
            Row(
              children: [
                stats[index].toWidget(),
                const SizedBox(width: 10),
                if (index + 1 < stats.length)
                  stats[index + 1].toWidget()
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          for (var index = 0; index < actions.length; index += 1) ...[
            if (index > 0) const SizedBox(height: 10),
            actions[index],
          ],
        ],
      ),
    );
  }
}

class SessionRewardStat {
  const SessionRewardStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  Widget toWidget() {
    return PlayfulStat(icon: icon, label: label, value: value, color: color);
  }
}

String sessionStarsText({required int successCount, required int totalCount}) {
  if (totalCount <= 0 || successCount <= 0) {
    return '별 없음';
  }
  final ratio = successCount / totalCount;
  final stars = ratio >= 0.9
      ? 3
      : ratio >= 0.7
      ? 2
      : 1;
  return List.filled(stars, '★').join();
}
