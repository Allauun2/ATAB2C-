import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/configs/app_colors.dart';
import '../../app/utils/app_update.dart';
import '../../app/utils/custom_widgets/common_text.dart';

/// Shown instead of the app when this version is older than the minimum ATA
/// accepts. There is no way past it except updating from the store.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/1003.png', height: 28),
                  ),
                  const Spacer(),
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.appColorWhite.withOpacity(0.08),
                      border: Border.all(
                          color: AppColors.appColorWhite.withOpacity(0.15),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.system_update_rounded,
                        size: 52, color: AppColors.appColorSecondary),
                  ),
                  const SizedBox(height: 32),
                  CommonText(
                    text: 'update.title'.tr,
                    fontSize: 24.0,
                    weight: FontWeight.w700,
                    color: AppColors.appColorWhite,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  CommonText(
                    text: 'update.body'.tr,
                    fontSize: 15.0,
                    lineHeight: 1.45,
                    color: AppColors.appColorWhite.withOpacity(0.75),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => launchUrl(Uri.parse(AppUpdate.storeUrl),
                          mode: LaunchMode.externalApplication),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColorWhite,
                        foregroundColor: AppColors.appColorPrimaryDark,
                        iconColor: AppColors.appColorPrimaryDark,
                      ),
                      child: Text('update.button'.tr),
                    ),
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
