import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'provider/app_state_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try initializing Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Main: Firebase initialized successfully');
  } catch (e) {
    debugPrint('Main: Firebase initialization failed or was not configured ($e). Running in Mock DB mode.');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // --- Shared Input Decoration Theme Builder ---
  InputDecorationTheme _inputTheme(Color fill, Color border, Color focus) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: focus, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    return MaterialApp(
      title: 'ScoreRecord',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,

      // --- Dark Theme ---
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFF1E293B),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B).withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: _inputTheme(const Color(0xFF0F172A), const Color(0xFF334155), const Color(0xFF6366F1)),
      ),

      // --- Light Theme ---
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: const ColorScheme.light().copyWith(
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
          titleTextStyle: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: _inputTheme(const Color(0xFFE2E8F0), const Color(0xFFCBD5E1), const Color(0xFF6366F1)),
      ),

      home: const LoginScreen(),
    );
  }
}
