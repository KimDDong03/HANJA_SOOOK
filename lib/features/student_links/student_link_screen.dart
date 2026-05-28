import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'student_link_controller.dart';

class StudentLinkScreen extends ConsumerStatefulWidget {
  const StudentLinkScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('학생 연결 관리')),
      body: SafeArea(
        child: state.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('내 학생 연결 코드', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _StudentCodeCard(code: data.currentStudentCode),
              const SizedBox(height: 28),
              Text('보호자 연결', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '학생 연결 코드',
                ),
                onChanged: ref
                    .read(studentLinkProvider.notifier)
                    .updateInputCode,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: data.inputCode.trim().isEmpty
                    ? null
                    : () async {
                        await ref
                            .read(studentLinkProvider.notifier)
                            .connectWithCode(data.inputCode);
                        if (ref.read(studentLinkProvider).value?.message !=
                            null) {
                          _codeController.clear();
                        }
                      },
                child: const Text('학생 연결'),
              ),
              const SizedBox(height: 28),
              Text('반 참여', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _classCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '반 코드',
                ),
                onChanged: ref
                    .read(studentLinkProvider.notifier)
                    .updateClassInputCode,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: data.classInputCode.trim().isEmpty
                    ? null
                    : () async {
                        await ref
                            .read(studentLinkProvider.notifier)
                            .joinClassWithCode(data.classInputCode);
                        if (ref.read(studentLinkProvider).value?.message !=
                            null) {
                          _classCodeController.clear();
                        }
                      },
                child: const Text('반 참여'),
              ),
              if (data.message != null) ...[
                const SizedBox(height: 12),
                Text(data.message!, textAlign: TextAlign.center),
              ],
              if (data.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  data.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 28),
              Text('참여한 반', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (data.joinedClasses.isEmpty)
                const Text('아직 참여한 반이 없습니다.')
              else
                for (final classRoom in data.joinedClasses) ...[
                  Card(
                    child: ListTile(
                      title: Text(classRoom.className),
                      subtitle: Text(
                        '${classRoom.schoolName ?? '학교 미설정'} · ${classRoom.grade ?? '-'}학년',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 28),
              Text('연결된 학생', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (data.linkedStudents.isEmpty)
                const Text('아직 연결된 학생이 없습니다.')
              else
                for (final student in data.linkedStudents) ...[
                  Card(
                    child: ListTile(
                      title: Text(student.displayName),
                      subtitle: Text(
                        '${student.schoolName ?? '학교 미설정'} · ${student.grade ?? '-'}학년',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('학생 연결 정보를 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}

class _StudentCodeCard extends StatelessWidget {
  const _StudentCodeCard({required this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    final code = this.code;
    if (code == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('학생 정보 입력 후 연결 코드를 만들 수 있습니다.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText(code),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              child: const Text('코드 복사'),
            ),
          ],
        ),
      ),
    );
  }
}
