import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/constants/app_constants.dart';
import 'core/logging/sentry_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Client
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  } catch (e) {
    debugPrint('[Supabase] Init warning/error (e.g. offline): $e');
  }

  // Initialize Sentry telemetry and run app
  await SentryService.initialize(() {
    runApp(
      const ProviderScope(
        child: UgcultApp(),
      ),
    );
  });
}
