import 'package:flutter/material.dart';


 const _seed = Color(0xFF0D7A5F);

    final _darkScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
final darkThemeData =  ThemeData(
          useMaterial3: true,
          colorScheme: _darkScheme,
          splashFactory: InkSparkle.splashFactory,
          scaffoldBackgroundColor: _darkScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: _darkScheme.surface,
            foregroundColor: _darkScheme.onSurface,
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
              TargetPlatform.windows: ZoomPageTransitionsBuilder(),
              TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
              TargetPlatform.linux: ZoomPageTransitionsBuilder(),
              TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
            },
          ),
          cardTheme: CardThemeData(
            color: _darkScheme.surface,
            surfaceTintColor: _darkScheme.surfaceTint,
            elevation: 2,
            shadowColor: _darkScheme.shadow.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              side: BorderSide(color: _darkScheme.outlineVariant),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _darkScheme.surfaceVariant.withOpacity(0.35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _darkScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _darkScheme.primary, width: 1.4),
            ),
          ),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            horizontalTitleGap: 12,
            dense: false,
          ),
        );