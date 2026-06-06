import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/learning_environment_settings.dart';
import '../../features/settings/learning_environment_controller.dart';

final appAudioControllerProvider = Provider<AppAudioController>((ref) {
  final isEnabled = Platform.environment['FLUTTER_TEST'] != 'true';
  final controller = AppAudioController(isEnabled: isEnabled);
  if (isEnabled) {
    unawaited(controller.preload());
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

class AppAudioController with WidgetsBindingObserver {
  AppAudioController({required bool isEnabled}) : this._(isEnabled);

  AppAudioController._(this._isEnabled) {
    if (_isEnabled) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  static const MethodChannel _channel = MethodChannel('hanjasoook/audio');
  static const _strokeTextureAsset = 'assets/audio/sfx/brush_01_b.mp3';
  static const _buttonTapAsset = 'assets/audio/sfx/button_tap.ogg';
  static const _strokeFeedbackVolume = 0.75;
  static const _backgroundMusicVolume = 0.45;
  static const _buttonTapVolume = 0.20;

  final bool _isEnabled;

  AppMusicTrack _currentTrack = AppMusicTrack.none;
  AppMusicTrack _syncedTrack = AppMusicTrack.none;
  LearningEnvironmentSettings _settings = const LearningEnvironmentSettings();
  bool _isAppInBackground = false;

  Future<void> setMusicTrack(AppMusicTrack track) async {
    _currentTrack = track;
    await _syncMusic();
  }

  Future<void> preload() async {
    await _safeAudioCall(() async {
      await _channel.invokeMethod<void>('preloadSfx', {
        'asset': _strokeTextureAsset,
      });
      await _channel.invokeMethod<void>('preloadSfx', {
        'asset': _buttonTapAsset,
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isAppInBackground = switch (state) {
      AppLifecycleState.resumed => false,
      AppLifecycleState.inactive ||
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => true,
    };
    if (_isAppInBackground == isAppInBackground) {
      return;
    }

    _isAppInBackground = isAppInBackground;
    if (isAppInBackground) {
      _syncedTrack = AppMusicTrack.none;
      unawaited(_stopAudioForBackground());
      return;
    }

    unawaited(_syncMusic(force: true));
  }

  Future<void> playSuccess() async {
    if (_isAppInBackground || !_settings.soundEffectsEnabled) {
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
    if (_isAppInBackground ||
        !_settings.soundEffectsEnabled ||
        !_settings.strokeSoundEnabled) {
      return;
    }
    await _safeAudioCall(() async {
      await _channel.invokeMethod<void>('playSfx', {
        'asset': _strokeTextureAsset,
        'volume': _strokeFeedbackVolume,
      });
    });
  }

  Future<void> playButtonTap() async {
    if (_isAppInBackground || !_settings.soundEffectsEnabled) {
      return;
    }
    await _safeAudioCall(() async {
      await _channel.invokeMethod<void>('playSfx', {
        'asset': _buttonTapAsset,
        'volume': _buttonTapVolume,
      });
    });
  }

  Future<void> stopStrokeTexture() async {
    await _safeAudioCall(() => _channel.invokeMethod<void>('stopStrokeSfx'));
  }

  Future<void> dispose() async {
    if (_isEnabled) {
      WidgetsBinding.instance.removeObserver(this);
    }
    await _safeAudioCall(() => _channel.invokeMethod<void>('dispose'));
  }

  Future<void> applySettings(LearningEnvironmentSettings settings) async {
    _settings = settings;
    if (!settings.soundEffectsEnabled || !settings.strokeSoundEnabled) {
      await stopStrokeTexture();
    }
    await _syncMusic();
  }

  Future<void> _syncMusic({bool force = false}) async {
    if (_isAppInBackground ||
        _currentTrack == AppMusicTrack.none ||
        !_settings.backgroundMusicEnabled) {
      if (!force && _syncedTrack == AppMusicTrack.none) {
        return;
      }
      _syncedTrack = AppMusicTrack.none;
      await _safeAudioCall(() => _channel.invokeMethod<void>('stopMusic'));
      return;
    }

    if (!force && _syncedTrack == _currentTrack) {
      return;
    }

    final track = _currentTrack;
    await _safeAudioCall(() async {
      await _channel.invokeMethod<void>('playMusic', {
        'asset': _assetForTrack(track),
        'volume': _backgroundMusicVolume,
      });
    });
    _syncedTrack = track;
  }

  Future<void> _stopAudioForBackground() async {
    await stopStrokeTexture();
    await _safeAudioCall(() => _channel.invokeMethod<void>('stopMusic'));
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
