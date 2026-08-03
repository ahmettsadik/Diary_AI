import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/background_task_handler.dart';
import 'screens/main_navigation.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'weekly-insights-1',
    'generateWeeklyInsights',
    frequency: const Duration(days: 7),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Intelligent Diary',
      themeMode: themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF164F16),
          primary: const Color(0xFF164F16),
          surface: Colors.white,
          secondary: const Color(0xFFD4A373),
          onPrimary: Colors.white,
          onSurface: const Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF164F16),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFF164F16).withOpacity(0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF164F16));
            }
            return const IconThemeData();
          }),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.lora(),
          bodyMedium: GoogleFonts.lora(),
          titleLarge: GoogleFonts.lora(),
          labelSmall: GoogleFonts.lora(),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121412),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A373),
          brightness: Brightness.dark,
          primary: const Color(0xFFD4A373),
          surface: const Color(0xFF1C1F1C),
        ),
        useMaterial3: true,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD4A373),
          foregroundColor: Color(0xFF121412),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFFD4A373).withOpacity(0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFFD4A373));
            }
            return const IconThemeData();
          }),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C1F1C),
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.lora(),
          bodyMedium: GoogleFonts.lora(),
          titleLarge: GoogleFonts.lora(),
          labelSmall: GoogleFonts.lora(),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
