import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/localization/app_translations.dart';
import 'package:travel_app/app/localization/language_service.dart';
import 'package:travel_app/app/utils/app_identity.dart';
import 'package:travel_app/app/utils/app_update.dart';
import 'package:travel_app/presentation/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AppIdentity.install();
  var locale = await LanguageService.savedLocale();
  AppUpdate.watchResume();
  runApp(MyApp(locale: locale));
}


class MyApp extends StatelessWidget {
  const MyApp({required this.locale, super.key});
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SafarPlus',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: LanguageService.english,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 400),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.appColorPrimary,
          primary: AppColors.appColorPrimary,
          error: AppColors.red,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.appColorAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appColorPrimaryDark,
          foregroundColor: AppColors.appColorWhite,
          elevation: 0,
          centerTitle: false,
        ),
        // Portal-style bordered field boxes instead of the template's underlines.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.appColorWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB9C2D4), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB9C2D4), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.appColorPrimary, width: 2),
          ),
          labelStyle: const TextStyle(
              color: AppColors.appColorTextDarkGray, fontSize: 13),
          hintStyle: const TextStyle(color: AppColors.appColorHint),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appColorPrimary,
            foregroundColor: AppColors.appColorWhite,
            // Without this, icons inside buttons default to the primary
            // colour and vanish against the primary background.
            iconColor: AppColors.appColorWhite,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            textStyle: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.appColorWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.appColorSperator),
          ),
        ),
        dividerTheme:
            const DividerThemeData(color: AppColors.appColorSperator),
      ),
      // home: LoginScreen(),
      home: SplashScreen(),
    );
  }
}

