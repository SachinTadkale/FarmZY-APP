import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/settings/providers/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:farmzy/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:farmzy/core/network/dio_provider.dart';
import 'core/app.dart';

Future<void> _runDiagnostics(ProviderContainer container) async {
  print("🧪 RUNNING NETWORK DIAGNOSTICS...");
  
  // 1. DNS Test
  try {
    final host = Uri.parse(AppConfig.baseUrl).host;
    print("📡 Testing DNS for $host...");
    final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 10));
    print("🌐 DNS OK: $host → ${result.map((e) => e.address).join(', ')}");
  } catch (e) {
    print("❌ DNS FAILED or TIMEOUT: $e");
  }

  final dio = container.read(dioProvider);

  // 2. Raw Backend Root Test
  try {
    print("📡 Testing Backend Root Connectivity...");
    final res = await dio.get("/").timeout(const Duration(seconds: 15));
    print("✅ Backend Root Status: ${res.statusCode}");
  } catch (e) {
    print("❌ Backend Root FAILED: $e");
  }

  // 3. Health Check Test
  try {
    print("📡 Testing Health Check...");
    final res = await dio.get("/health").timeout(const Duration(seconds: 15));
    print("✅ Health Check Status: ${res.statusCode}");
  } catch (e) {
    print("❌ Health Check FAILED: $e");
  }

  // 4. HTTPS/SSL Test
  try {
    print("📡 Testing HTTPS Handshake (Google)...");
    final res = await Dio().get("https://google.com").timeout(const Duration(seconds: 10));
    print("✅ HTTPS OK: ${res.statusCode}");
  } catch (e) {
    print("❌ HTTPS FAILED: $e");
  }
  
  print("🧪 DIAGNOSTICS COMPLETE");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 REQUIRED for easy_localization
  await EasyLocalization.ensureInitialized();

  const String env = String.fromEnvironment('ENV', defaultValue: '');
  String envFile = ".env";
  
  if (env == 'dev') {
    envFile = ".env.dev";
  } else if (env == 'staging') {
    envFile = ".env.staging";
  } else if (env == 'prod') {
    envFile = ".env.prod";
  } else {
    envFile = kReleaseMode ? ".env.prod" : ".env.dev";
  }
  
  try {
    await dotenv.load(fileName: envFile);
  } catch (e) {
    if (kDebugMode) {
      print("⚠️ FAILED TO LOAD ENV '$envFile', FALLING BACK TO '.env': $e");
    }
    await dotenv.load(fileName: ".env");
  }

  // Debug verification logs
  if (kDebugMode) {
    print("🌍 BASE URL: ${AppConfig.baseUrl}");
  }

  final container = ProviderContainer();
  await container.read(settingsControllerProvider.notifier).init();

  if (kDebugMode) {
    // Run diagnostics in the background to avoid blocking the UI (black screen)
    unawaited(_runDiagnostics(container));
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: UncontrolledProviderScope(
        container: container,
        child: const FarmZY(),
      ),
    ),
  );
}
