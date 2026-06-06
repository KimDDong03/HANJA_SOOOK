import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/core/audio/app_audio_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const audioChannel = MethodChannel('hanjasoook/audio');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, null);
  });

  testWidgets('preloads stroke sound effect', (tester) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          calls.add(call);
          return null;
        });

    final controller = AppAudioController(isEnabled: true);
    addTearDown(controller.dispose);

    await controller.preload();

    expect(calls.map((call) => call.method), ['preloadSfx', 'preloadSfx']);
    expect(
      calls.first.arguments,
      containsPair('asset', 'assets/audio/sfx/brush_01_b.mp3'),
    );
    expect(
      calls.last.arguments,
      containsPair('asset', 'assets/audio/sfx/button_tap.ogg'),
    );
  });

  testWidgets('plays stroke sound with the selected feedback volume', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          calls.add(call);
          return null;
        });

    final controller = AppAudioController(isEnabled: true);
    addTearDown(controller.dispose);

    await controller.playStrokeTexture();

    expect(calls.single.method, 'playSfx');
    expect(
      calls.single.arguments,
      containsPair('asset', 'assets/audio/sfx/brush_01_b.mp3'),
    );
    expect(calls.single.arguments, containsPair('volume', 0.75));
  });

  testWidgets('plays button tap sound with the selected tap asset', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          calls.add(call);
          return null;
        });

    final controller = AppAudioController(isEnabled: true);
    addTearDown(controller.dispose);

    await controller.playButtonTap();

    expect(calls.single.method, 'playSfx');
    expect(
      calls.single.arguments,
      containsPair('asset', 'assets/audio/sfx/button_tap.ogg'),
    );
    expect(calls.single.arguments, containsPair('volume', 0.20));
  });

  testWidgets(
    'stops background music when app is backgrounded and restores it',
    (tester) async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            calls.add(call);
            return null;
          });

      final controller = AppAudioController(isEnabled: true);
      addTearDown(controller.dispose);

      await controller.setMusicTrack(AppMusicTrack.activity);

      expect(calls.single.method, 'playMusic');
      expect(
        calls.single.arguments,
        containsPair('asset', 'assets/audio/music/activity_background.mp3'),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await _pumpAudioMicrotasks(tester);

      expect(
        calls.map((call) => call.method),
        containsAllInOrder(['playMusic', 'stopStrokeSfx', 'stopMusic']),
      );

      calls.clear();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _pumpAudioMicrotasks(tester);

      expect(calls.single.method, 'playMusic');
      expect(
        calls.single.arguments,
        containsPair('asset', 'assets/audio/music/activity_background.mp3'),
      );
    },
  );
}

Future<void> _pumpAudioMicrotasks(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}
