import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/router/admin_shell_screen.dart';
import 'package:laundry_ridge/app/theme/app_theme.dart';

class LaundryRidgeApp extends StatelessWidget {
  const LaundryRidgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harborridge Laundry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.createLightTheme(),
      darkTheme: AppTheme.createDarkTheme(),
      themeMode: ThemeMode.light,
      home: const AdminShellScreen(),
    );
  }
}
