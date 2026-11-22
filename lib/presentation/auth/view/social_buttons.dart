import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../app/configs/app_colors.dart';
import '../../../app/utils/social_sign_in.dart';
import '../controller/login_controller.dart';

/// "or" divider plus Continue with Google / Apple. Shows nothing where no
/// provider is set up (web, or Google before its client ids are filled in).
class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final google = SocialSignIn.googleReady, apple = SocialSignIn.appleReady;
    if (!google && !apple) return const SizedBox.shrink();
    final login = Get.put(LoginController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('auth.or'.tr,
                style: const TextStyle(
                    color: AppColors.appColorTextDarkGray, fontSize: 12.5)),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 16),
        if (apple) ...[
          SizedBox(
            height: 48,
            child: SignInWithAppleButton(
              text: 'auth.continueWithApple'.tr,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onPressed: () => login.socialLogin(SocialSignIn.apple),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (google)
          OutlinedButton.icon(
            onPressed: () => login.socialLogin(SocialSignIn.google),
            icon: const Text('G',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4))),
            label: Text('auth.continueWithGoogle'.tr,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appColorTextBlack)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFFB9C2D4), width: 1.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }
}
