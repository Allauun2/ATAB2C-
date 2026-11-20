import 'package:flutter/material.dart';
// import 'package:get/get.dart';

/// SafarPlus design tokens, from the logo: navy 0B1B3F, blue 1565FF and cyan
/// 2BD4FF (the "Plus" on dark backgrounds). Layout and status colours are
/// inherited from the ATA agency app this one started from.
class AppColors {
  //APP Colors ---------------------------------------------------------------
  static const Color appColorPrimary = Color(0xFF1565FF); // SafarPlus blue

  static const Color appColorSplashBG = Color(0xFF0B1B3F); // SafarPlus navy
  static const Color appColorSecondary = Color(0xFF2BD4FF); // SafarPlus cyan — accents on navy
  static const Color appColorPrimaryDark = Color(0xFF0B1B3F); // navy shell (app bar / bnb)
  static const Color appColorAccent = Color(0xFFF5F6FA); // canvas
  static const Color appColorBlack = Color(0xFF000000);
  static const Color appColorGrey = Color(0xFF8A93A8); // muted
  static const Color appColorTextRed = Color(0xFFC2392E); // error
  static const Color appColorDarkRed = Color(0xFFC2392E);
  static const Color appColorHint = Color(0xFF8A93A8);
  static const Color appColorLightTextColor = Color(0xFFE8F0FF); // selected bg
  static const Color appColorTransparent = Color(0xFF0FFFFF);
  static const Color appColorBlue = Color(0xFF1565FF);
  static const Color appColorLightBlue = Color(0xFF0F52D6); // hover / pressed
  static const Color appColorPresent = Color(0xFF0D7A4F);
  static const Color appColorTextDarkGray = Color(0xFF49536B); // secondary text
  static const Color appColorTextLightGray = Color(0xFF8A93A8);
  static const Color appColorSperator = Color(0xFFE8EBF1); // line
  static const Color appColorIcon = Color(0xFF1565FF);
  static const Color appColorWhite = Color(0xFFFFFFFF);
  static const Color appColorTextBlack = Color(0xFF1C2536); // ink
  static const Color appColorSeparator = Color(0xFFE8EBF1);
  static const Color appColorRestDay = Color(0xFFAABCD4);
  static const Color appColorAbsent = Color(0xFFE47F7F);
  static const Color appColorCasualLeave = Color(0xFF89E287);
  static const Color appColorShortLeave = Color(0xFF86C584);
  static const Color appColorHoliday = Color(0xFFEAA254);
  static const Color appColorEarlyOut = Color(0xFFF4B309);
  static const Color appColorAbsent2 = Color(0xFFFD0000);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color red = Color(0xFFC2392E); // portal error
  static const Color blue = Color(0xFF1560B8); // portal info
  static const Color green = Color(0xFF0D7A4F); // portal success
  static const Color orange = Color(0xFF996408); // portal warning
  static const Color transparent = Colors.transparent;

  // -----------------
  static const Color appColordivider = Color(0xFFE7EFFC);
  static const Color textfieldbg = Color(0xFFE7EFFC);

  static const Color fileIconColor = Color(0xFFF5BF38);

  static const Color errorColorDark = Color(0xFFbd0623);
  static const Color errorColorLight = Color(0xFFff6e6b);
  static const Color successColorDark = Color(0xFF069C88);
  static const Color successColorLight = Color(0xFF04E4C6);

  // static const Map<String, Color> statusColors = {
  //   'All': Color(0xFFEDC2CB),
  //   'Total': Color(0xA30A80FE),
  //   'Present': Color(0xFF1ABCA6),
  //   'Rest Day': Color(0xFFAABCD4),
  //   'Absent': Color(0xFFE47F7F),
  //   'Leave': Color(0xFF7BB464),
  //   'Short Leave': Color(0xFF86C584),
  //   'Holiday': Color(0xFFEAA254),
  //   'Absent2': Color(0xFFFD0000),
  //   'On Time': Color(0xFFEAA254),
  //   'Late In': Color(0xFFF1C40F),
  //   'Half Day': Color(0xFF1ABCA6),
  //   'Early Out': Color(0xFF2471A3),
  //   'Over Time': Color(0xFF373B7B),
  // };

  // static LinearGradient drawerbgGradient = LinearGradient(
  //     colors: Get.isDarkMode
  //         ? [
  //             Get.theme.colorScheme.onPrimary,
  //             Get.theme.colorScheme.secondary,
  //             Get.theme.colorScheme.primary,
  //             Get.theme.colorScheme.primary,
  //           ]
  //         : [
  //             Get.theme.colorScheme.background,
  //             Get.theme.colorScheme.tertiary,
  //             Get.theme.colorScheme.secondary,
  //             Get.theme.colorScheme.primary,
  //           ],
  //     begin: Alignment.bottomRight,
  //     end: Alignment.topLeft);
}
