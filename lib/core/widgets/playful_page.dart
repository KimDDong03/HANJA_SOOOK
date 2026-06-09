import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class PlayfulPage extends StatelessWidget {
  const PlayfulPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.leading,
    this.trailing,
    this.showMascot = false,
    this.showHeader = true,
    this.compactHeader = false,
    this.scrollable = true,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 28),
    this.physics,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;
  final bool showMascot;
  final bool showHeader;
  final bool compactHeader;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final content = [
      if (showHeader) ...[
        _PlayfulHeader(
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          showMascot: showMascot,
          compact: compactHeader,
        ),
        SizedBox(height: compactHeader ? 10 : 18),
      ],
      ...children,
    ];
    return const _PageBackground(child: SizedBox.expand()).withContent(
      SafeArea(
        child: scrollable
            ? ListView(padding: padding, physics: physics, children: content)
            : Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content,
                ),
              ),
      ),
    );
  }
}

class PlayfulPanel extends StatelessWidget {
  const PlayfulPanel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class PlayfulStat extends StatelessWidget {
  const PlayfulStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayfulActionTile extends StatelessWidget {
  const PlayfulActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Material(
      color: isEnabled ? color : AppColors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isEnabled
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayfulHeader extends StatelessWidget {
  const _PlayfulHeader({
    required this.title,
    required this.subtitle,
    required this.showMascot,
    required this.compact,
    this.leading,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showMascot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final hasSubtitle = subtitle.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(6, compact ? 8 : 18, 6, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ] else if (canPop) ...[
            _BackBubble(onTap: () => Navigator.maybePop(context)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.headlineSmall
                              : Theme.of(context).textTheme.headlineMedium)
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                ),
                if (hasSubtitle) ...[
                  SizedBox(height: compact ? 3 : 6),
                  Text(
                    subtitle,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.bodyLarge)
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                ],
              ],
            ),
          ),
          if (showMascot)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/hanja_mascot.png',
                width: compact ? 68 : 86,
                height: compact ? 68 : 86,
                fit: BoxFit.cover,
              ),
            )
          else
            ?trailing,
        ],
      ),
    );
  }
}

class _BackBubble extends StatelessWidget {
  const _BackBubble({required this.onTap});

  static const _label = '뒤로가기';

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: IconButton(
        onPressed: onTap,
        tooltip: _label,
        icon: const Icon(Icons.arrow_back, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground({required this.child});

  final Widget child;

  Widget withContent(Widget content) {
    return Stack(children: [this, content]);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFAFAFA), Color(0xFFFDF5F7)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _HanjaPattern()),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _HanjaPattern extends CustomPainter {
  const _HanjaPattern();

  static const _characters = [
    '儒',
    '侍',
    '孝',
    '書',
    '來',
    '葉',
    '東',
    '學',
    '善',
    '義',
    '禮',
    '智',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    var index = 0;
    for (var y = 18.0; y < size.height; y += 70) {
      for (var x = 18.0; x < size.width; x += 86) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _characters[index % _characters.length],
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.07),
              fontFamily: AppFonts.hanjaSerif,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x, y));
        index += 1;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
