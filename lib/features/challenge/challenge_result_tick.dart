import 'package:flutter_riverpod/flutter_riverpod.dart';

final challengeResultTickProvider = NotifierProvider<ChallengeResultTick, int>(
  ChallengeResultTick.new,
);

class ChallengeResultTick extends Notifier<int> {
  @override
  int build() => 0;

  void increase() {
    state += 1;
  }
}
