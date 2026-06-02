import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/class_room.dart';
import 'student_link_controller.dart';

class StudentLinkScreen extends ConsumerStatefulWidget {
  const StudentLinkScreen({super.key, this.role = 'student'});

  final String role;

  @override
  ConsumerState<StudentLinkScreen> createState() => _StudentLinkScreenState();
}

class _StudentLinkScreenState extends ConsumerState<StudentLinkScreen> {
  late final TextEditingController _codeController;
  late final TextEditingController _classCodeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _classCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentLinkProvider);
    final role = _normalizeRole(widget.role);

    return Scaffold(
      body: state.when(
        data: (data) {
          final children = _childrenForRole(context, ref, data, role);
          return PlayfulPage(
            title: _titleForRole(role),
            subtitle: _subtitleForRole(role),
            children: [
              ...children,
              if (data.message != null || data.errorMessage != null) ...[
                if (children.isNotEmpty) const SizedBox(height: 16),
                _FeedbackPanel(
                  message: data.message,
                  errorMessage: data.errorMessage,
                  showRankingAction: role == 'student',
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('학생 연결 정보를 불러오지 못했습니다.')),
      ),
    );
  }

  List<Widget> _childrenForRole(
    BuildContext context,
    WidgetRef ref,
    StudentLinkState data,
    String role,
  ) {
    if (role == 'parent') {
      return [
        _GuardianLinkPanel(
          data: data,
          controller: _codeController,
          onConnect: () async {
            await ref
                .read(studentLinkProvider.notifier)
                .connectWithCode(data.inputCode);
            final latest = ref.read(studentLinkProvider).value;
            if (latest?.message != null) {
              _codeController.clear();
            }
          },
          onChanged: ref.read(studentLinkProvider.notifier).updateInputCode,
        ),
        const SizedBox(height: 16),
        _LinkedStudentsPanel(data: data),
      ];
    }

    if (role == 'teacher') {
      return [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '선생님은 반 코드 관리에서 학생 참여를 관리해요.',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.push(RoutePaths.teacherPreview),
                icon: const Icon(Icons.school),
                label: const Text('반 코드 관리로 이동'),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      _StudentCodePanel(code: data.currentStudentCode),
      const SizedBox(height: 16),
      _ClassJoinPanel(
        data: data,
        controller: _classCodeController,
        onJoin: () async {
          await ref
              .read(studentLinkProvider.notifier)
              .joinClassWithCode(data.classInputCode);
          final latest = ref.read(studentLinkProvider).value;
          if (latest?.message != null) {
            _classCodeController.clear();
          }
        },
        onChanged: ref.read(studentLinkProvider.notifier).updateClassInputCode,
      ),
      const SizedBox(height: 16),
      _JoinedClassesPanel(classes: data.joinedClasses),
    ];
  }

  String _normalizeRole(String value) {
    return switch (value) {
      'parent' => 'parent',
      'teacher' => 'teacher',
      _ => 'student',
    };
  }

  String _titleForRole(String role) {
    return switch (role) {
      'parent' => '학생 연결',
      'teacher' => '반 연결 관리',
      _ => '학습 연결',
    };
  }

  String _subtitleForRole(String role) {
    return switch (role) {
      'parent' => '학생 연결 코드로 아이를 연결해요',
      'teacher' => '선생님 도구에서 반 코드를 관리해요',
      _ => '내 학생 연결 코드와 참여한 반을 관리해요',
    };
  }
}

class _ClassJoinPanel extends StatelessWidget {
  const _ClassJoinPanel({
    required this.data,
    required this.controller,
    required this.onJoin,
    required this.onChanged,
  });

  final StudentLinkState data;
  final TextEditingController controller;
  final VoidCallback onJoin;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: const Color(0xFFA7F3D0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '반 코드로 참여하기',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text('선생님이 알려준 반 코드를 복사해 붙여넣거나 직접 입력해요.'),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              labelText: '반 코드',
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              if (data.classInputCode.trim().isEmpty) {
                _showSnack(context, '반 코드를 입력해주세요.');
                return;
              }
              onJoin();
            },
            icon: const Icon(Icons.meeting_room),
            label: const Text('반 참여'),
          ),
        ],
      ),
    );
  }
}

class _JoinedClassesPanel extends StatelessWidget {
  const _JoinedClassesPanel({required this.classes});

  final List<ClassRoom> classes;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: const Color(0xFFFFF0B8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참여한 반',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (classes.isEmpty)
            const Text('아직 참여한 반이 없습니다. 선생님에게 받은 반 코드를 입력해요.')
          else
            for (final classRoom in classes) ...[
              _InfoRow(
                icon: Icons.groups,
                title: classRoom.className,
                subtitle:
                    '${classRoom.schoolName ?? '학교 미설정'} · ${classRoom.grade ?? '-'}학년',
              ),
              const SizedBox(height: 8),
            ],
          if (classes.isNotEmpty) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.push(RoutePaths.classRanking),
              icon: const Icon(Icons.leaderboard),
              label: const Text('랭킹 보기'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  context.push(RoutePaths.competitiveFlipBoardLobby),
              icon: const Icon(Icons.dashboard_customize),
              label: const Text('경쟁 판뒤집기'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuardianLinkPanel extends StatelessWidget {
  const _GuardianLinkPanel({
    required this.data,
    required this.controller,
    required this.onConnect,
    required this.onChanged,
  });

  final StudentLinkState data;
  final TextEditingController controller;
  final VoidCallback onConnect;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '보호자 연결',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text('학생 화면의 내 학생 연결 코드를 복사해 붙여넣거나 직접 입력해요.'),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '학생 연결 코드',
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              if (data.inputCode.trim().isEmpty) {
                _showSnack(context, '학생 연결 코드를 입력해주세요.');
                return;
              }
              onConnect();
            },
            icon: const Icon(Icons.link),
            label: const Text('학생 연결'),
          ),
        ],
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class _StudentCodePanel extends StatelessWidget {
  const _StudentCodePanel({required this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    final code = this.code;
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '내 학생 연결 코드',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (code == null)
            const Text('학생 정보 입력 후 연결 코드를 만들 수 있습니다.')
          else ...[
            SelectableText(code),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              icon: const Icon(Icons.copy),
              label: const Text('코드 복사'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkedStudentsPanel extends StatelessWidget {
  const _LinkedStudentsPanel({required this.data});

  final StudentLinkState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '연결된 학생',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (data.linkedStudents.isEmpty)
            const Text('아직 연결된 학생이 없습니다.')
          else
            for (final student in data.linkedStudents) ...[
              _InfoRow(
                icon: Icons.person,
                title: student.displayName,
                subtitle:
                    '${student.schoolName ?? '학교 미설정'} · ${student.grade ?? '-'}학년',
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 8),
          const Text('연결 학생의 실시간 반 랭킹 확인은 서버 동기화가 필요한 2차 기능입니다.'),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.showRankingAction,
    this.message,
    this.errorMessage,
  });

  final String? message;
  final String? errorMessage;
  final bool showRankingAction;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    return PlayfulPanel(
      color: hasError ? const Color(0xFFFFD6A5) : const Color(0xFFBDE0FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hasError ? errorMessage! : message!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (!hasError && showRankingAction) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push(RoutePaths.classRanking),
              icon: const Icon(Icons.leaderboard),
              label: const Text('반 랭킹 보기'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
