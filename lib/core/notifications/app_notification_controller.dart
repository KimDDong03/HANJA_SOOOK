import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appNotificationControllerProvider = Provider<AppNotificationController>((
  ref,
) {
  final isEnabled =
      Platform.environment['FLUTTER_TEST'] != 'true' && Platform.isAndroid;
  return AppNotificationController(isEnabled: isEnabled);
});

class AppNotificationController {
  const AppNotificationController({required bool isEnabled})
    : this._(isEnabled);

  const AppNotificationController._(this._isEnabled);

  static const MethodChannel _channel = MethodChannel(
    'hanjasoook/notifications',
  );

  final bool _isEnabled;

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_isEnabled) {
      return true;
    }

    try {
      final result = await _channel.invokeMethod<bool>(
        'scheduleDailyReminder',
        {'hour': hour, 'minute': minute},
      );
      return result ?? false;
    } on Object catch (error) {
      assert(() {
        debugPrint('Notification scheduling skipped: $error');
        return true;
      }());
      return false;
    }
  }

  Future<void> cancelDailyReminder() async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('cancelDailyReminder');
    } on Object catch (error) {
      assert(() {
        debugPrint('Notification cancel skipped: $error');
        return true;
      }());
    }
  }
}
