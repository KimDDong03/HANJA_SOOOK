import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/env.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/future_features_panel.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/class_room.dart';
import '../../domain/models/hanja_character.dart';
import 'teacher_preview_controller.dart';

class TeacherPreviewScreen extends ConsumerStatefulWidget {
  const TeacherPreviewScreen({super.key});

  @override
  ConsumerState<TeacherPreviewScreen> createState() =>
      _TeacherPreviewScreenState();
}

class _TeacherPreviewScreenState extends ConsumerState<TeacherPreviewScreen> {
  late final TextEditingController _classNameController;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnv.isProduction) {
      return const Scaffold(
        body: FutureFeaturesPage(
          title: '선생님 반 관리',
          subtitle: '선생님용 반 관리 도구는 향후 업데이트에서 제공될 예정입니다',
        ),
      );
    }

    final state = ref.watch(teacherPreviewProvider);

    return Scaffold(
      body: state.when(
        data: (data) => PlayfulPage(
          title: '반 코드 관리',
          subtitle: '반을 만들고 학생에게 참여 코드를 공유해요',
          children: [
            _ClassCreatePanel(data: data, controller: _classNameController),
            if (data.message != null || data.errorMessage != null) ...[
              const SizedBox(height: 16),
              _FeedbackPanel(
                message: data.message,
                errorMessage: data.errorMessage,
              ),
            ],
            const SizedBox(height: 16),
            _ClassCodeListPanel(data: data),
            const SizedBox(height: 16),
            _TodayHanjaPanel(items: data.todayHanja),
            const SizedBox(height: 16),
            if (data.hasActualStudents) ...[
              _ActualStatusPanel(data: data),
              const SizedBox(height: 16),
              _ActualStudentResultPanel(students: data.studentSummaries),
            ] else ...[
              _ActualEmptyPanel(hasClass: data.classes.isNotEmpty),
              const SizedBox(height: 16),
              _SampleStatusPanel(data: data),
              const SizedBox(height: 16),
              _StudentResultPanel(students: data.sampleStudents),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('반 코드 관리를 불러오지 못했습니다.')),
      ),
    );
  }
}

class _ClassCreatePanel extends ConsumerWidget {
  const _ClassCreatePanel({required this.data, required this.controller});

  final TeacherPreviewState data;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPanel(
      color: const Color(0xFFA7F3D0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '내 반 만들기',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text('반 이름을 입력하면 학생들이 참여할 수 있는 반 코드가 만들어져요.'),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              labelText: '반 이름',
              hintText: '예: 3학년 1반',
            ),
            onChanged: ref
                .read(teacherPreviewProvider.notifier)
                .updateClassNameInput,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: data.classNameInput.trim().isEmpty
                ? null
                : () async {
                    await ref
                        .read(teacherPreviewProvider.notifier)
                        .createClass(data.classNameInput);
                    if (ref.read(teacherPreviewProvider).value?.message !=
                        null) {
                      controller.clear();
                    }
                  },
            icon: const Icon(Icons.add),
            label: const Text('반 코드 만들기'),
          ),
        ],
      ),
    );
  }
}

class _ClassCodeListPanel extends StatelessWidget {
  const _ClassCodeListPanel({required this.data});

  final TeacherPreviewState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: const Color(0xFFFFF0B8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '반 코드 보기',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (data.classes.isEmpty)
            const Text('아직 만든 반이 없습니다. 먼저 반 코드를 만들어주세요.')
          else
            for (final classRoom in data.classes) ...[
              _ClassCodeCard(
                classRoom: classRoom,
                memberCount: data.memberCountFor(classRoom.id),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ClassCodeCard extends StatelessWidget {
  const _ClassCodeCard({required this.classRoom, required this.memberCount});

  final ClassRoom classRoom;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    classRoom.className,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text('참여 학생 수 $memberCount명'),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              classRoom.classCode,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: classRoom.classCode)),
              icon: const Icon(Icons.copy),
              label: const Text('반 코드 복사'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayHanjaPanel extends StatelessWidget {
  const _TodayHanjaPanel({required this.items});

  final List<HanjaCharacter> items;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 학습 한자',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('오늘의 한자 데이터가 아직 없습니다.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in items)
                  Chip(
                    label: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.character,
                            style: const TextStyle(
                              fontFamily: AppFonts.hanjaSerif,
                            ),
                          ),
                          TextSpan(text: ' ${item.meaning}'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActualStatusPanel extends StatelessWidget {
  const _ActualStatusPanel({required this.data});

  final TeacherPreviewState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: const Color(0xFFA7F3D0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '실제 학생 현황',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.groups,
                label: '참여 학생',
                value: '${data.actualStudentCount}명',
                color: const Color(0xFFFFE066),
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.stars,
                label: '오늘 점수',
                value: '${data.actualTodayScore}점',
                color: const Color(0xFFBDE0FE),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.bolt,
                label: '오늘 XP',
                value: '${data.actualTodayXp} XP',
                color: const Color(0xFFFFC8DD),
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.grid_view,
                label: '판뒤집기',
                value: '${data.actualFlipBoardTiles}판',
                color: const Color(0xFFCDB4DB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActualEmptyPanel extends StatelessWidget {
  const _ActualEmptyPanel({required this.hasClass});

  final bool hasClass;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: const Color(0xFFE0F2FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '실제 학생 현황',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            hasClass
                ? '아직 참여한 학생이 없습니다. 반 코드를 공유하면 실제 기록으로 전환돼요.'
                : '반을 먼저 만들면 실제 참여 학생 기록이 여기에 표시돼요.',
          ),
        ],
      ),
    );
  }
}

class _SampleStatusPanel extends StatelessWidget {
  const _SampleStatusPanel({required this.data});

  final TeacherPreviewState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: const Color(0xFFBDE0FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '샘플 학습 현황',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.groups,
                label: '학생 수',
                value: '${data.studentCount}명',
                color: const Color(0xFFFFE066),
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.check_circle,
                label: '완료',
                value: '${data.completedCount}/${data.studentCount}',
                color: const Color(0xFFA7F3D0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.percent,
                label: '평균 정확도',
                value: '${data.averageAccuracy}%',
                color: const Color(0xFFFFC8DD),
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.brush,
                label: '쓰기 완료',
                value: '${data.writingCompleteCount}명',
                color: const Color(0xFFCDB4DB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActualStudentResultPanel extends StatelessWidget {
  const _ActualStudentResultPanel({required this.students});

  final List<TeacherPreviewStudentSummary> students;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '학생별 실제 기록',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final student in students) ...[
            _ActualStudentRow(student: student),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ActualStudentRow extends StatelessWidget {
  const _ActualStudentRow({required this.student});

  final TeacherPreviewStudentSummary student;

  @override
  Widget build(BuildContext context) {
    final initial = student.name.characters.isEmpty
        ? '?'
        : student.name.characters.first;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text(initial)),
        title: Text(student.name),
        subtitle: Text(
          student.hasChallenge
              ? '오늘 ${student.todayScore}점 · 오늘 XP ${student.todayEarnedXp}'
              : '오늘 기록 없음 · 누적 XP ${student.totalXp}',
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${student.totalXp} XP',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text('${student.flipBoardTiles}판'),
          ],
        ),
      ),
    );
  }
}

class _StudentResultPanel extends StatelessWidget {
  const _StudentResultPanel({required this.students});

  final List<TeacherPreviewStudent> students;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '학생별 샘플 결과',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final student in students) ...[
            _StudentRow(student: student),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});

  final TeacherPreviewStudent student;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text(student.name.characters.first)),
        title: Text(student.name),
        subtitle: Text(
          '${student.completedCount}/${student.totalCount} · 정확도 ${student.accuracy}%',
        ),
        trailing: Text(
          student.writingComplete ? '쓰기 완료' : '진행 중',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({this.message, this.errorMessage});

  final String? message;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    return PlayfulPanel(
      color: hasError ? const Color(0xFFFFD6A5) : const Color(0xFFD9F99D),
      child: Text(
        hasError ? errorMessage! : message!,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
