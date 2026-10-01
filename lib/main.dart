import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DbSpeakApp());
}

class DbSpeakApp extends StatefulWidget {
  const DbSpeakApp({super.key});

  @override
  State<DbSpeakApp> createState() => _DbSpeakAppState();
}

class _DbSpeakAppState extends State<DbSpeakApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        // If system, invert according to current platform brightness
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _themeMode =
            brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F46E5); // Indigo
    const secondaryColor = Color(0xFF06B6D4); // Cyan

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: Color(0xFF1E293B),
      ),
    );

    final isCurrentlyDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    return MaterialApp(
      title: 'dbSpeak',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: isCurrentlyDark,
      ),
    );
  }
}
