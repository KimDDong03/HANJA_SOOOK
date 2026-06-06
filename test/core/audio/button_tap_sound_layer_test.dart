import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/core/audio/app_audio_controller.dart';
import 'package:hanja_soook/core/audio/button_tap_sound_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const audioChannel = MethodChannel('hanjasoook/audio');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, null);
  });

  testWidgets('plays button tap sound after completed button tap', (
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appAudioControllerProvider.overrideWithValue(controller)],
        child: AppButtonTapSoundLayer(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: FilledButton(onPressed: _noop, child: Text('누르기')),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('누르기')),
    );
    await tester.pump();

    expect(calls, isEmpty);
    await gesture.up();
    await tester.pump();

    expect(calls.single.method, 'playSfx');
    expect(
      calls.single.arguments,
      containsPair('asset', 'assets/audio/sfx/button_tap.ogg'),
    );
  });

  testWidgets('does not play button tap sound when button press becomes drag', (
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appAudioControllerProvider.overrideWithValue(controller)],
        child: AppButtonTapSoundLayer(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: FilledButton(onPressed: _noop, child: Text('누르기')),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('누르기')),
    );
    await gesture.moveBy(const Offset(0, 60));
    await gesture.up();
    await tester.pump();

    expect(calls, isEmpty);
  });

  testWidgets('does not play button tap sound for plain gesture areas', (
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appAudioControllerProvider.overrideWithValue(controller)],
        child: AppButtonTapSoundLayer(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: GestureDetector(
                  key: ValueKey('plain-gesture-area'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _noop,
                  child: SizedBox(width: 120, height: 120),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('plain-gesture-area')));
    await tester.pump();

    expect(calls, isEmpty);
  });
}

void _noop() {}
