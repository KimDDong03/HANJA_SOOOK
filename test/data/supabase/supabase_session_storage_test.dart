import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/supabase/supabase_session_storage.dart';

void main() {
  group('SecureSupabaseSessionStorage', () {
    late Directory tempDir;
    late File legacyFile;
    late File sharedLegacyFile;
    late _MemorySessionStorageBackend backend;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'hanja_soook_session_storage_test_',
      );
      legacyFile = File('${tempDir.path}${Platform.pathSeparator}session.json');
      sharedLegacyFile = File(
        '${tempDir.path}${Platform.pathSeparator}shared_session.json',
      );
      backend = _MemorySessionStorageBackend();
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('uses normalized app env in secure storage key', () {
      final storage = SecureSupabaseSessionStorage(
        appEnv: ' Prod ',
        backend: backend,
        legacySessionFile: () async => legacyFile,
        legacySharedSessionFile: () async => sharedLegacyFile,
      );

      expect(storage.persistSessionKey, 'hanja_soook_supabase_session_prod');
    });

    test('persists and removes session through secure backend', () async {
      final storage = SecureSupabaseSessionStorage(
        appEnv: 'demo',
        backend: backend,
        legacySessionFile: () async => legacyFile,
        legacySharedSessionFile: () async => sharedLegacyFile,
      );

      await storage.persistSession('session-json');

      expect(await storage.hasAccessToken(), isTrue);
      expect(await storage.accessToken(), 'session-json');

      await storage.removePersistedSession();

      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.accessToken(), isNull);
    });

    test('migrates legacy session file into secure backend', () async {
      await legacyFile.writeAsString('legacy-session-json');
      await sharedLegacyFile.writeAsString('old-shared-session-json');
      final storage = SecureSupabaseSessionStorage(
        appEnv: 'demo',
        backend: backend,
        legacySessionFile: () async => legacyFile,
        legacySharedSessionFile: () async => sharedLegacyFile,
      );

      await storage.initialize();

      expect(await storage.accessToken(), 'legacy-session-json');
      expect(legacyFile.existsSync(), isFalse);
      expect(sharedLegacyFile.existsSync(), isFalse);
    });

    test(
      'does not overwrite an existing secure session during migration',
      () async {
        await legacyFile.writeAsString('legacy-session-json');
        final storage = SecureSupabaseSessionStorage(
          appEnv: 'demo',
          backend: backend,
          legacySessionFile: () async => legacyFile,
          legacySharedSessionFile: () async => sharedLegacyFile,
        );
        await storage.persistSession('secure-session-json');

        await storage.initialize();

        expect(await storage.accessToken(), 'secure-session-json');
        expect(legacyFile.existsSync(), isFalse);
      },
    );
  });
}

class _MemorySessionStorageBackend extends SupabaseSessionStorageBackend {
  final Map<String, String> values = {};

  @override
  Future<bool> containsKey({required String key}) async {
    return values.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
