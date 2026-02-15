import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Future realistic initializations for FarmZy:

  // await Env.load();                 // API URLs
  // await TokenStorage.init();        // secure storage
  // await LoggerService.init();      // debugging
  // await DeviceInfoService.init();  // fraud/security later

  runApp(
    const ProviderScope(
      child: FarmZY(),
    ),
  );
}
