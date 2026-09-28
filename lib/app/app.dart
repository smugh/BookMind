import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/cover_screen.dart';

class BookMindApp extends StatelessWidget {
  const BookMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book&Mind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CoverScreen(),
    );
  }
}
