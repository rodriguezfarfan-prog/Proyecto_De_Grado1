import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'di/injection_container.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ProviderScope(child: FinUpApp()));
}

class FinUpApp extends StatelessWidget {
  const FinUpApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinUp',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}