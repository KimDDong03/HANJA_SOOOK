import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final state = ref.watch(teacherPreviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('교사 미리보기')),
      body: SafeArea(
        child: state.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const _PreviewBanner(),
              const SizedBox(height: 20),
              Text(
                data.className,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                data.assignmentTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _ClassCreateSection(data: data, controller: _classNameController),
              const SizedBox(height: 20),
              _TodayHanjaBand(items: data.todayHanja),
              const SizedBox(height: 20),
              _SummaryGrid(data: data),
              const SizedBox(height: 24),
              Text('학생별 결과', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _StudentResultTable(students: data.sampleStudents),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('교사 미리보기를 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}

class _ClassCreateSection extends ConsumerWidget {
  const _ClassCreateSection({required this.data, required this.controller});

  final TeacherPreviewState data;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('반 개설', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: '반 이름',
          ),
          onChanged: ref
              .read(teacherPreviewProvider.notifier)
              .updateClassNameInput,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: data.classNameInput.trim().isEmpty
              ? null
              : () async {
                  await ref
                      .read(teacherPreviewProvider.notifier)
                      .createClass(data.classNameInput);
                  if (ref.read(teacherPreviewProvider).value?.message != null) {
                    controller.clear();
                  }
                },
          child: const Text('반 코드 만들기'),
        ),
        if (data.message != null) ...[
          const SizedBox(height: 12),
          Text(data.message!),
        ],
        if (data.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            data.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        if (data.classes.isEmpty)
          const Text('아직 개설한 반이 없습니다.')
        else
          for (final classRoom in data.classes) ...[
            _ClassCodeCard(classRoom: classRoom),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _ClassCodeCard extends StatelessWidget {
  const _ClassCodeCard({required this.classRoom});

  final ClassRoom classRoom;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              classRoom.className,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(classRoom.classCode),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: classRoom.classCode)),
              child: const Text('반 코드 복사'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          '샘플 미리보기 화면입니다. 실제 과제 저장이나 알림은 실행되지 않습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _TodayHanjaBand extends StatelessWidget {
  const _TodayHanjaBand({required this.items});

  final List<HanjaCharacter> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('오늘의 한자 데이터가 아직 없습니다.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('진행 중 과제', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              Chip(label: Text('${item.character} ${item.meaning}')),
          ],
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.data});

  final TeacherPreviewState data;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.35,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _SummaryTile(label: '학생 수', value: '${data.studentCount}명'),
        _SummaryTile(
          label: '완료',
          value: '${data.completedCount}/${data.studentCount}',
        ),
        _SummaryTile(label: '평균 정확도', value: '${data.averageAccuracy}%'),
        _SummaryTile(label: '쓰기 완료', value: '${data.writingCompleteCount}명'),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _StudentResultTable extends StatelessWidget {
  const _StudentResultTable({required this.students});

  final List<TeacherPreviewStudent> students;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('이름')),
          DataColumn(label: Text('완료')),
          DataColumn(label: Text('정확도')),
          DataColumn(label: Text('점수')),
          DataColumn(label: Text('쓰기')),
        ],
        rows: [
          for (final student in students)
            DataRow(
              cells: [
                DataCell(Text(student.name)),
                DataCell(
                  Text('${student.completedCount}/${student.totalCount}'),
                ),
                DataCell(Text('${student.accuracy}%')),
                DataCell(Text('${student.score}점')),
                DataCell(Text(student.writingComplete ? '완료' : '진행 중')),
              ],
            ),
        ],
      ),
    );
  }
}
