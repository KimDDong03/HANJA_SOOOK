import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/startup_error_app.dart';
import 'core/errors/app_exception.dart';
import 'data/supabase/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeSupabase();
    runApp(const ProviderScope(child: HanjaSoookApp()));
  } on AppException catch (error) {
    runApp(StartupErrorApp(message: error.userMessage));
  }
}
