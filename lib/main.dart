import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:career_path_finder/ui/welcome_screen.dart';
import 'package:career_path_finder/ui/home_screen.dart';
import 'package:career_path_finder/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(
    // ProviderScope allows us to use Riverpod everywhere in our app.
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Career Path Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1F4E5F),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFD7EEF4),
          onPrimaryContainer: Color(0xFF0D2E38),
          secondary: Color(0xFF2F855A),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFDDF4E7),
          onSecondaryContainer: Color(0xFF123822),
          tertiary: Color(0xFFC77800),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFFFE2B8),
          onTertiaryContainer: Color(0xFF3C2500),
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          surface: Color(0xFFF6F7F2),
          onSurface: Color(0xFF182024),
          surfaceContainerHighest: Color(0xFFE4E8E2),
          outline: Color(0xFF748084),
          outlineVariant: Color(0xFFC9D0CB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F2),
          foregroundColor: Color(0xFF182024),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFA6D8E5),
          onPrimary: Color(0xFF0D2E38),
          primaryContainer: Color(0xFF1F4E5F),
          onPrimaryContainer: Color(0xFFD7EEF4),
          secondary: Color(0xFF9BE2B8),
          onSecondary: Color(0xFF123822),
          secondaryContainer: Color(0xFF1F5C3B),
          onSecondaryContainer: Color(0xFFDDF4E7),
          surface: Color(0xFF101719),
          onSurface: Color(0xFFE4E8E2),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
        ),
      ),
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) =>
            user != null ? const HomeScreen() : const WelcomeScreen(),
        loading: () => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'SYNCING TRAJECTORY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Color(0xFFBA1A1A),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'System Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
