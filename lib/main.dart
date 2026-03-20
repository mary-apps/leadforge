import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app.dart';
import 'config/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found or could not be loaded: $e');
  }

  // Set system UI overlay style (status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
  );

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize RevenueCat
  await Purchases.setLogLevel(kReleaseMode ? LogLevel.warn : LogLevel.debug);
  final configuration = PurchasesConfiguration(AppConstants.revenueCatApiKey);
  await Purchases.setLogLevel(LogLevel.error);
  PurchasesConfiguration configuration;
  configuration = PurchasesConfiguration(AppConstants.revenueCatApiKey);
  await Purchases.configure(configuration);

  runApp(
    const ProviderScope(
      child: LeadForgeApp(),
    ),
  );
}
