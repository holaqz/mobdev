import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'models/product.dart';
import 'models/favorites.dart';
import 'screens/home_page.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://oyecfepknlsdaxlyloya.supabase.co');
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95ZWNmZXBrbmxzZGF4bHlsb3lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1NjA3OTMsImV4cCI6MjA4MjEzNjc5M30.qR1iIlSmpQFuUBu_hHEjvs4yOZI8U2jKbBR89vS_t58',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasEnv = _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
  SupabaseClient? client;
  if (hasEnv) {
    debugPrint('✅ Supabase env loaded');
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    client = Supabase.instance.client;
  } else {
    debugPrint(
      '❌ Supabase env not provided (SUPABASE_URL / SUPABASE_ANON_KEY)',
    );
  }
  final prefs = await SharedPreferences.getInstance();
  final repository = ProductRepository(client);
  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => FavoritesModel(prefs)),
      ],
      child: const CalorieGuideApp(),
    ),
  );
}

class CalorieGuideApp extends StatelessWidget {
  const CalorieGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final whiteColor = const Color(0xFFFFFFFF);
    final greenAccent = const Color(0xFF4CAF50);
    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Справочник продуктов',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: whiteColor,
        scaffoldBackgroundColor: whiteColor,
        colorScheme: ColorScheme.light(
          primary: whiteColor,
          secondary: greenAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF000000),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
