import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/class_room_repository_provider.dart';
import '../../data/repositories/student_link_repository_provider.dart';
import '../../domain/models/class_room.dart';
import '../../domain/models/student_link.dart';
import '../../domain/services/class_code_service.dart';
import '../../domain/services/class_participation_service.dart';
import '../../domain/services/student_link_code_service.dart';
import '../auth/current_profile_controller.dart';

const guardianRelationType = 'guardian';

final studentLinkProvider =
    AsyncNotifierProvider<StudentLinkController, StudentLinkState>(
      StudentLinkController.new,
    );

class StudentLinkController extends AsyncNotifier<StudentLinkState> {
  final StudentLinkCodeService _codeService = const StudentLinkCodeService();
  final ClassCodeService _classCodeService = const ClassCodeService();
  final ClassParticipationService _classParticipationService =
      const ClassParticipationService();

  @override
  Future<StudentLinkState> build() async {
    final profile = ref.watch(currentProfileProvider);
    final links = await ref
        .watch(studentLinkRepositoryProvider)
        .getStudentLinks(relationType: guardianRelationType);
    final joinedClasses = <ClassRoom>[];
    if (profile != null) {
      joinedClasses.addAll(
        await _classParticipationService.getJoinedClasses(
          classRepository: ref.watch(classRoomRepositoryProvider),
          studentKey: profile.id,
        ),
      );
    }
    return StudentLinkState(
      currentStudentCode: profile == null
          ? null
          : _codeService.encodeProfile(profile),
      linkedStudents: links,
      joinedClasses: joinedClasses,
    );
  }

  Future<void> connectWithCode(String code) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    try {
      final link = _codeService.decode(
        code: code,
        relationType: guardianRelationType,
        linkedAt: DateTime.now(),
      );
      await ref.read(studentLinkRepositoryProvider).saveStudentLink(link);
      final links = await ref
          .read(studentLinkRepositoryProvider)
          .getStudentLinks(relationType: guardianRelationType);
      state = AsyncData(
        current.copyWith(
          linkedStudents: links,
          inputCode: '',
          message: '${link.displayName} 학생을 연결했습니다.',
          errorMessage: null,
        ),
      );
    } on FormatException {
      state = AsyncData(
        current.copyWith(errorMessage: '연결 코드를 다시 확인해주세요.', message: null),
      );
    }
  }

  void updateInputCode(String code) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(inputCode: code, errorMessage: null, message: null),
    );
  }

  Future<void> joinClassWithCode(String code) async {
    final current = state.value;
    final profile = ref.read(currentProfileProvider);
    if (current == null || profile == null) {
      return;
    }

    try {
      final member = _classCodeService.decodeMember(
        code: code,
        studentProfile: profile,
        joinedAt: DateTime.now(),
      );
      await ref.read(classRoomRepositoryProvider).saveClassMember(member);

      final joinedClasses = await _classParticipationService.getJoinedClasses(
        classRepository: ref.read(classRoomRepositoryProvider),
        studentKey: profile.id,
      );

      state = AsyncData(
        current.copyWith(
          joinedClasses: joinedClasses,
          classInputCode: '',
          message: '반에 참여했습니다.',
          errorMessage: null,
        ),
      );
    } on FormatException {
      state = AsyncData(
        current.copyWith(errorMessage: '반 코드를 다시 확인해주세요.', message: null),
      );
    }
  }

  void updateClassInputCode(String code) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(classInputCode: code, errorMessage: null, message: null),
    );
  }
}

class StudentLinkState {
  const StudentLinkState({
    required this.currentStudentCode,
    required this.linkedStudents,
    required this.joinedClasses,
    this.inputCode = '',
    this.classInputCode = '',
    this.message,
    this.errorMessage,
  });

  final String? currentStudentCode;
  final List<StudentLink> linkedStudents;
  final List<ClassRoom> joinedClasses;
  final String inputCode;
  final String classInputCode;
  final String? message;
  final String? errorMessage;

  StudentLinkState copyWith({
    String? currentStudentCode,
    List<StudentLink>? linkedStudents,
    List<ClassRoom>? joinedClasses,
    String? inputCode,
    String? classInputCode,
    Object? message = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return StudentLinkState(
      currentStudentCode: currentStudentCode ?? this.currentStudentCode,
      linkedStudents: linkedStudents ?? this.linkedStudents,
      joinedClasses: joinedClasses ?? this.joinedClasses,
      inputCode: inputCode ?? this.inputCode,
      classInputCode: classInputCode ?? this.classInputCode,
      message: message == _sentinel ? this.message : message as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();
