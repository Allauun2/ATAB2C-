import "dart:async";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:travel_app/app/configs/app_colors.dart";
import "package:travel_app/app/utils/custom_widgets/common_text.dart";
import "package:travel_app/presentation/auth/view/login_screen.dart";
import "package:travel_app/presentation/splash_screen/onboard_screen.dart";

import "../../app/data/data_controller.dart";
import "../../app/utils/app_update.dart";
import "../../app/utils/auth_session.dart";
import "../../app/utils/guest.dart";
import "../../app/utils/session_validator.dart";
import "../home_bottom_nav/bnb/bottom_nav_view.dart";
import "../update/update_required_screen.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DataController dataController = Get.put(DataController());

  @override
  void initState() {
    super.initState();
    _route();
  }

  /// Keep the user signed in across app launches (client request: like any
  /// consumer app, only deactivation or a dead refresh token ends the session).
  /// The brand shows for at least a moment, but never longer than the
  /// session check actually takes.
  Future<void> _route() async {
    final minimum = Future.delayed(const Duration(seconds: 2));
    final updateRequired = AppUpdate.isRequired();
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('isOnboardedStatus') ?? false;

    Widget next;
    if (!onboarded) {
      next = const OnBoardingScreen();
    } else if (await AuthSession.tryRestore()) {
      await dataController.loadMyData();
      SessionValidator.start();
      next = BottomNavScreen();
    } else if (await Guest.isOn()) {
      await dataController.loadMyData();
      next = BottomNavScreen();
    } else {
      next = const LoginScreen();
    }
    await minimum;
    if (!mounted) return;
    if (await updateRequired) {
      Get.offAll(() => const UpdateRequiredScreen());
      return;
    }
    Get.off(() => next, transition: Transition.fadeIn);
  }

  // Logo size and position match the native launch screens (android
  // launch_background.xml, iOS LaunchScreen.storyboard): centred, 200 wide on
  // flat navy, so the hand-off from the OS splash doesn't jump.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColorPrimaryDark,
      body: Stack(
        children: [
          Center(child: Image.asset('assets/1003.png', width: 200)),
          Align(
            alignment: const Alignment(0, 0.22),
            child: CommonText(
              text: 'splash.tagline'.tr,
              fontSize: 14.0,
              weight: FontWeight.w500,
              color: AppColors.appColorWhite.withOpacity(0.75),
              letterSpacing: 0.4,
            ),
          ),
          const Align(
            alignment: Alignment(0, 0.8),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.appColorSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
