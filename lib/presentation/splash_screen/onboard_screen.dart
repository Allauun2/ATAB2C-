import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/presentation/auth/view/login_screen.dart';

/// First-launch introduction: three short slides on the navy brand ground,
/// then sign-in. Shown once.
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final controller = PageController();
  int _page = 0;

  static const _slides = [
    (Icons.travel_explore_rounded, 'onboard.searchTitle', 'onboard.searchBody'),
    (Icons.airplane_ticket_rounded, 'onboard.bookTitle', 'onboard.bookBody'),
    (Icons.account_balance_wallet_rounded, 'onboard.payTitle', 'onboard.payBody'),
  ];

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardedStatus', true);
    Get.off(() => const LoginScreen(), transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColorPrimaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1B3F), Color(0xFF16306B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                child: Row(
                  children: [
                    Image.asset('assets/1003.png', height: 28),
                    const Spacer(),
                    if (!_isLast)
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.appColorWhite),
                        child: Text('onboard.skip'.tr),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _slide(_slides[i]),
                ),
              ),
              SmoothPageIndicator(
                controller: controller,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 6,
                  activeDotColor: AppColors.appColorSecondary,
                  dotColor: AppColors.appColorWhite.withOpacity(0.3),
                ),
                onDotClicked: (i) => controller.animateToPage(i,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLast
                        ? _finish
                        : () => controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appColorWhite,
                      foregroundColor: AppColors.appColorPrimaryDark,
                      iconColor: AppColors.appColorPrimaryDark,
                    ),
                    child: Text(
                        _isLast ? 'onboard.getStarted'.tr : 'onboard.next'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slide((IconData, String, String) s) {
    final (icon, title, body) = s;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.appColorWhite.withOpacity(0.08),
              border: Border.all(
                  color: AppColors.appColorWhite.withOpacity(0.15), width: 1.5),
            ),
            child: Icon(icon, size: 54, color: AppColors.appColorSecondary),
          ),
          const SizedBox(height: 36),
          CommonText(
            text: title.tr,
            fontSize: 24.0,
            weight: FontWeight.w700,
            color: AppColors.appColorWhite,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CommonText(
            text: body.tr,
            fontSize: 15.0,
            lineHeight: 1.45,
            color: AppColors.appColorWhite.withOpacity(0.75),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
