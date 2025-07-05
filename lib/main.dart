import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/providers/task_provider.dart';
import 'package:weekly_task_planner/providers/theme_provider.dart';
import 'package:weekly_task_planner/screens/weekly_planner_screen.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const WeeklyPlannerApp(),
    ),
  );
}

class WeeklyPlannerApp extends StatelessWidget {
  const WeeklyPlannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.teal,
            primary: Colors.teal,
            secondary: Colors.amber,
            surface: Colors.grey[50]!,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
            primary: Colors.teal[300]!,
            secondary: Colors.amber[300]!,
            surface: Colors.grey[900]!,
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weekly Task Planner',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: Colors.black.withAlpha((0.1 * 255).toInt()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              surfaceTintColor: Colors.white,
            ),
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme.copyWith(
                    headlineSmall: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                    titleLarge: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    bodyMedium: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    bodySmall: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.black.withAlpha((0.2 * 255).toInt()),
                backgroundColor: lightColorScheme.primary,
                foregroundColor: lightColorScheme.onPrimary,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: lightColorScheme.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: lightColorScheme.onSurface,
              ),
              iconTheme: IconThemeData(
                color: lightColorScheme.onSurface,
                size: 28,
              ),
            ),
            scaffoldBackgroundColor: lightColorScheme.surface,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: Colors.black.withAlpha((0.3 * 255).toInt()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              surfaceTintColor: Colors.grey[850],
            ),
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme.copyWith(
                    headlineSmall: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                    titleLarge: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    bodyMedium: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    bodySmall: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.black.withAlpha((0.2 * 255).toInt()),
                backgroundColor: darkColorScheme.primary,
                foregroundColor: darkColorScheme.onPrimary,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: darkColorScheme.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: darkColorScheme.onSurface,
              ),
              iconTheme: IconThemeData(
                color: darkColorScheme.onSurface,
                size: 28,
              ),
            ),
            scaffoldBackgroundColor: darkColorScheme.surface,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
          ],
          home: const WeeklyPlannerScreen(),
        );
      },
    );
  }
}