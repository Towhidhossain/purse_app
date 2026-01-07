import 'package:flutter/material.dart';


 const _seed = Color(0xFF0D7A5F);

    final _lightScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );


final appThemeData =  ThemeData(
          useMaterial3: true,
          colorScheme: _lightScheme,
          splashFactory: InkSparkle.splashFactory,
          scaffoldBackgroundColor: _lightScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: _lightScheme.surface,
            foregroundColor: _lightScheme.onSurface,
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
            color: _lightScheme.surface,
            surfaceTintColor: _lightScheme.surfaceTint,
            elevation: 2,
            shadowColor: _lightScheme.shadow.withOpacity(0.1),
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
              side: BorderSide(color: _lightScheme.outlineVariant),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _lightScheme.surfaceVariant.withOpacity(0.4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _lightScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _lightScheme.primary, width: 1.4),
            ),
          ),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            horizontalTitleGap: 12,
            dense: false,
          ),
        );