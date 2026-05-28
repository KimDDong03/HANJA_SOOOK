import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/school_repository_provider.dart';
import '../../domain/models/app_user_profile.dart';

final currentProfileProvider =
    NotifierProvider<CurrentProfileController, AppUserProfile?>(
      CurrentProfileController.new,
    );

class CurrentProfileController extends Notifier<AppUserProfile?> {
  @override
  AppUserProfile? build() => null;

  void setProfile(AppUserProfile profile) {
    state = profile;
  }

  Future<bool> restoreFromCurrentSession() async {
    final profile = await ref.read(schoolRepositoryProvider).getCurrentProfile();
    if (profile == null) {
      return false;
    }
    state = profile;
    return true;
  }
}
