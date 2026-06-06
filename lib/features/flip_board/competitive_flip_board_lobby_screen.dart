import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/env.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/future_features_panel.dart';
import '../../core/widgets/playful_page.dart';
import '../student_links/student_link_controller.dart';
import 'flip_board_time_limit_picker.dart';

class CompetitiveFlipBoardLobbyScreen extends ConsumerStatefulWidget {
  const CompetitiveFlipBoardLobbyScreen({super.key});

  @override
  ConsumerState<CompetitiveFlipBoardLobbyScreen> createState() =>
      _CompetitiveFlipBoardLobbyScreenState();
}

class _CompetitiveFlipBoardLobbyScreenState
    extends ConsumerState<CompetitiveFlipBoardLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  String? _roomCode;
  bool _isReady = false;
  int _timeLimitSeconds = AppConstants.flipBoardTimeLimitSeconds;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnv.isProduction) {
      return const Scaffold(
        body: FutureFeaturesPage(
          title: '친구와 함께하는 대결',
          subtitle: '경쟁 판뒤집기는 향후 업데이트에서 제공될 예정입니다',
        ),
      );
    }

    final asyncState = ref.watch(studentLinkProvider);

    return Scaffold(
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('반 정보를 불러오지 못했습니다.')),
        data: (state) {
          final joinedClass = state.joinedClasses.firstOrNull;
          if (joinedClass == null) {
            return PlayfulPage(
              title: '경쟁 판뒤집기',
              subtitle: '반 코드 참여 후 친구와 대결해요',
              children: [
                PlayfulPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.meeting_room,
                        size: 52,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '참여한 반이 필요해요',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            context.push(RoutePaths.studentLinksFor('student')),
                        icon: const Icon(Icons.login),
                        label: const Text('반 코드로 참여하기'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return PlayfulPage(
            title: '경쟁 판뒤집기',
            subtitle: '${joinedClass.className} 대결방',
            children: [
              PlayfulPanel(
                color: AppColors.mint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '방 만들기',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _createRoom,
                      icon: const Icon(Icons.add_box),
                      label: const Text('새 방 만들기'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PlayfulPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '제한시간',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      flipBoardTimeLimitDescription(_timeLimitSeconds),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FlipBoardTimeLimitSelector(
                      selectedSeconds: _timeLimitSeconds,
                      onChanged: (seconds) =>
                          setState(() => _timeLimitSeconds = seconds),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PlayfulPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '코드로 입장',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _roomCodeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: '방 코드',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _joinRoom,
                      icon: const Icon(Icons.login),
                      label: const Text('방 입장'),
                    ),
                  ],
                ),
              ),
              if (_roomCode != null) ...[
                const SizedBox(height: 14),
                _WaitingRoomPanel(
                  roomCode: _roomCode!,
                  isReady: _isReady,
                  onCopy: () =>
                      Clipboard.setData(ClipboardData(text: _roomCode!)),
                  onReady: () => setState(() => _isReady = true),
                  onStart: _isReady
                      ? () => context.go(
                          RoutePaths.competitiveFlipBoardMatch(
                            _roomCode!,
                            timeLimitSeconds: _timeLimitSeconds,
                          ),
                        )
                      : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _createRoom() {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final code = List.generate(
      6,
      (_) => letters[random.nextInt(letters.length)],
    ).join();
    setState(() {
      _roomCode = code;
      _isReady = false;
      _roomCodeController.text = code;
    });
  }

  void _joinRoom() {
    final code = _roomCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방 코드를 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _roomCode = code;
      _isReady = false;
      _roomCodeController.text = code;
    });
  }
}

class _WaitingRoomPanel extends StatelessWidget {
  const _WaitingRoomPanel({
    required this.roomCode,
    required this.isReady,
    required this.onCopy,
    required this.onReady,
    required this.onStart,
  });

  final String roomCode;
  final bool isReady;
  final VoidCallback onCopy;
  final VoidCallback onReady;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: AppColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '대기방',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(
                isReady ? Icons.check_circle : Icons.hourglass_top,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      roomCode,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy),
                    tooltip: '방 코드 복사',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isReady ? null : onReady,
                  icon: const Icon(Icons.check),
                  label: Text(isReady ? '준비 완료' : '준비'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('시작'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
