import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/env.dart';

class SecureSupabaseSessionStorage extends LocalStorage {
  SecureSupabaseSessionStorage({
    String? appEnv,
    SupabaseSessionStorageBackend? backend,
    this.legacySessionFile,
    this.legacySharedSessionFile,
  }) : _appEnv = _normalizeAppEnv(appEnv ?? AppEnv.normalizedAppEnv),
       _backend = backend ?? const FlutterSecureSupabaseSessionStorageBackend();

  final String _appEnv;
  final SupabaseSessionStorageBackend _backend;
  final Future<File> Function()? legacySessionFile;
  final Future<File> Function()? legacySharedSessionFile;

  String get persistSessionKey => 'hanja_soook_supabase_session_$_appEnv';

  @override
  Future<void> initialize() async {
    await _migrateLegacySessionFile();
  }

  @override
  Future<String?> accessToken() {
    return _backend.read(key: persistSessionKey);
  }

  @override
  Future<bool> hasAccessToken() {
    return _backend.containsKey(key: persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _backend.write(key: persistSessionKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() {
    return _backend.delete(key: persistSessionKey);
  }

  Future<void> _migrateLegacySessionFile() async {
    final fileProvider =
        legacySessionFile ??
        () => SecureSupabaseSessionStorage.legacySessionFileForEnv(_appEnv);
    final file = await fileProvider();
    if (!file.existsSync()) {
      await _deleteOldSharedLegacyFile();
      return;
    }

    try {
      final sessionJson = await file.readAsString();
      if (sessionJson.trim().isNotEmpty &&
          !await _backend.containsKey(key: persistSessionKey)) {
        await persistSession(sessionJson);
      }
      await file.delete();
    } catch (_) {
      // Keep the legacy file if migration failed so a later app launch can retry.
    }
    await _deleteOldSharedLegacyFile();
  }

  Future<void> _deleteOldSharedLegacyFile() async {
    final fileProvider =
        legacySharedSessionFile ??
        () => SecureSupabaseSessionStorage.legacySessionFileForEnv(null);
    final oldFile = await fileProvider();
    if (oldFile.existsSync()) {
      await oldFile.delete().catchError((_) => oldFile);
    }
  }

  static Future<File> legacySessionFileForEnv(String? appEnv) async {
    final directory = await getApplicationSupportDirectory();
    final fileName = appEnv == null
        ? 'supabase_session.json'
        : 'supabase_session_$appEnv.json';
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }
}

abstract class SupabaseSessionStorageBackend {
  const SupabaseSessionStorageBackend();

  Future<String?> read({required String key});

  Future<bool> containsKey({required String key});

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}

class FlutterSecureSupabaseSessionStorageBackend
    extends SupabaseSessionStorageBackend {
  const FlutterSecureSupabaseSessionStorageBackend([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<bool> containsKey({required String key}) {
    return _storage.containsKey(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }
}

String _normalizeAppEnv(String appEnv) {
  final normalized = appEnv.trim().toLowerCase();
  return normalized.isEmpty ? 'demo' : normalized;
}
