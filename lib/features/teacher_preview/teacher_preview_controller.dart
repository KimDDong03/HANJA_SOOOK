import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/class_room_repository_provider.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../domain/models/class_room.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/services/class_code_service.dart';
import '../auth/current_profile_controller.dart';

final teacherPreviewProvider =
    AsyncNotifierProvider<TeacherPreviewController, TeacherPreviewState>(
      TeacherPreviewController.new,
    );

class TeacherPreviewController extends AsyncNotifier<TeacherPreviewState> {
  final ClassCodeService _classCodeService = const ClassCodeService();

  @override
  Future<TeacherPreviewState> build() async {
    final profile = ref.watch(currentProfileProvider);
    final grade = profile?.grade;
    final todayHanja = await ref
        .watch(contentRepositoryProvider)
        .getTodayHanjaSet(grade: grade, limit: AppConstants.dailyHanjaCount);
    final classes = await ref.watch(classRoomRepositoryProvider).getClasses();

    return TeacherPreviewState(
      className: '${profile?.schoolName ?? '서울새솔초등학교'} ${grade ?? 3}학년 1반',
      todayHanja: todayHanja,
      sampleStudents: _sampleStudents,
      classes: classes,
    );
  }

  Future<void> createClass(String className) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    try {
      final classRoom = _classCodeService.createClass(
        className: className,
        teacherProfile: ref.read(currentProfileProvider),
        createdAt: DateTime.now(),
      );
      await ref.read(classRoomRepositoryProvider).saveClass(classRoom);
      final classes = await ref.read(classRoomRepositoryProvider).getClasses();
      state = AsyncData(
        current.copyWith(
          classes: classes,
          classNameInput: '',
          message: '${classRoom.className} 반을 개설했습니다.',
          errorMessage: null,
        ),
      );
    } on FormatException {
      state = AsyncData(
        current.copyWith(errorMessage: '반 이름을 입력해주세요.', message: null),
      );
    }
  }

  void updateClassNameInput(String value) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        classNameInput: value,
        message: null,
        errorMessage: null,
      ),
    );
  }
}

class TeacherPreviewState {
  const TeacherPreviewState({
    required this.className,
    required this.todayHanja,
    required this.sampleStudents,
    required this.classes,
    this.classNameInput = '',
    this.message,
    this.errorMessage,
  });

  final String className;
  final List<HanjaCharacter> todayHanja;
  final List<TeacherPreviewStudent> sampleStudents;
  final List<ClassRoom> classes;
  final String classNameInput;
  final String? message;
  final String? errorMessage;

  int get studentCount => sampleStudents.length;

  int get completedCount {
    return sampleStudents.where((student) => student.isComplete).length;
  }

  int get writingCompleteCount {
    return sampleStudents.where((student) => student.writingComplete).length;
  }

  int get averageAccuracy {
    if (sampleStudents.isEmpty) {
      return 0;
    }
    final total = sampleStudents.fold<int>(
      0,
      (sum, student) => sum + student.accuracy,
    );
    return (total / sampleStudents.length).round();
  }

  String get assignmentTitle {
    final first = todayHanja.isEmpty ? null : todayHanja.first;
    return first?.unitName ?? '오늘의 한자';
  }

  TeacherPreviewState copyWith({
    String? className,
    List<HanjaCharacter>? todayHanja,
    List<TeacherPreviewStudent>? sampleStudents,
    List<ClassRoom>? classes,
    String? classNameInput,
    Object? message = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return TeacherPreviewState(
      className: className ?? this.className,
      todayHanja: todayHanja ?? this.todayHanja,
      sampleStudents: sampleStudents ?? this.sampleStudents,
      classes: classes ?? this.classes,
      classNameInput: classNameInput ?? this.classNameInput,
      message: message == _sentinel ? this.message : message as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class TeacherPreviewStudent {
  const TeacherPreviewStudent({
    required this.name,
    required this.completedCount,
    required this.totalCount,
    required this.accuracy,
    required this.score,
    required this.writingComplete,
  });

  final String name;
  final int completedCount;
  final int totalCount;
  final int accuracy;
  final int score;
  final bool writingComplete;

  bool get isComplete => completedCount >= totalCount;
}

const _sampleStudents = [
  TeacherPreviewStudent(
    name: '김하준',
    completedCount: 5,
    totalCount: 5,
    accuracy: 96,
    score: 5,
    writingComplete: true,
  ),
  TeacherPreviewStudent(
    name: '이서윤',
    completedCount: 5,
    totalCount: 5,
    accuracy: 92,
    score: 4,
    writingComplete: true,
  ),
  TeacherPreviewStudent(
    name: '박도윤',
    completedCount: 4,
    totalCount: 5,
    accuracy: 84,
    score: 4,
    writingComplete: true,
  ),
  TeacherPreviewStudent(
    name: '최지우',
    completedCount: 3,
    totalCount: 5,
    accuracy: 78,
    score: 3,
    writingComplete: false,
  ),
  TeacherPreviewStudent(
    name: '정민준',
    completedCount: 2,
    totalCount: 5,
    accuracy: 64,
    score: 2,
    writingComplete: false,
  ),
];

const _sentinel = Object();
