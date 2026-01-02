import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turf_booking/core/router/router.dart';
import 'package:turf_booking/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TurfCommandApp()));
}

class TurfCommandApp extends StatelessWidget {
  const TurfCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TurfCommand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
