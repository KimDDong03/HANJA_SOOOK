import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/learning_environment_settings.dart';
import '../../features/settings/learning_environment_controller.dart';

final appAudioControllerProvider = Provider<AppAudioController>((ref) {
  final isEnabled = Platform.environment['FLUTTER_TEST'] != 'true';
  final controller = AppAudioController(isEnabled: isEnabled);
  if (isEnabled) {
    ref.listen(learningEnvironmentControllerProvider, (_, next) {
      final settings = next.asData?.value;
      if (settings != null) {
        unawaited(controller.applySettings(settings));
      }
    }, fireImmediately: true);
  }
  ref.onDispose(controller.dispose);
  return controller;
});

enum AppMusicTrack { none, home, activity }

class AppAudioController {
  AppAudioController({required bool isEnabled}) : this._(isEnabled);

  AppAudioController._(this._isEnabled);

  static const MethodChannel _channel = MethodChannel('hanjasoook/audio');

  final bool _isEnabled;

  AppMusicTrack _currentTrack = AppMusicTrack.none;
  LearningEnvironmentSettings _settings = const LearningEnvironmentSettings();

  Future<void> setMusicTrack(AppMusicTrack track) async {
    if (_currentTrack == track) {
      return;
    }

    _currentTrack = track;

    await _safeAudioCall(() async {
      if (track == AppMusicTrack.none || !_settings.backgroundMusicEnabled) {
        await _channel.invokeMethod<void>('stopMusic');
        return;
      }

      await _channel.invokeMethod<void>('playMusic', {
        'asset': _assetForTrack(track),
        'volume': 0.75,
      });
    });
  }

  Future<void> playSuccess() async {
    if (!_settings.soundEffectsEnabled) {
      return;
    }
    await _safeAudioCall(() async {
      await _channel.invokeMethod<void>('playSfx', {
        'asset': 'assets/audio/sfx/success_chime.mp3',
        'volume': 1.0,
      });
    });
  }

  Future<void> playStrokeTexture() async {
    if (!_settings.soundEffectsEnabled || !_settings.strokeSoundEnabled) {
      return;
    }
    await _safeAudioCall(() async {
      await _channel.invokeMethod<void>('playSfx', {
        'asset': 'assets/audio/sfx/stroke_texture_pencil_fast.mp3',
        'volume': 1.0,
      });
    });
  }

  Future<void> dispose() async {
    await _safeAudioCall(() => _channel.invokeMethod<void>('dispose'));
  }

  Future<void> applySettings(LearningEnvironmentSettings settings) async {
    _settings = settings;
    if (!settings.backgroundMusicEnabled) {
      await _safeAudioCall(() => _channel.invokeMethod<void>('stopMusic'));
      return;
    }
    final track = _currentTrack;
    _currentTrack = AppMusicTrack.none;
    await setMusicTrack(track);
  }

  String _assetForTrack(AppMusicTrack track) {
    return switch (track) {
      AppMusicTrack.home => 'assets/audio/music/home_background.mp3',
      AppMusicTrack.activity => 'assets/audio/music/activity_background.mp3',
      AppMusicTrack.none => throw StateError('No asset for muted music track.'),
    };
  }

  Future<void> _safeAudioCall(Future<void> Function() call) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await call();
    } on Object catch (error) {
      assert(() {
        debugPrint('Audio playback skipped: $error');
        return true;
      }());
    }
  }
}
