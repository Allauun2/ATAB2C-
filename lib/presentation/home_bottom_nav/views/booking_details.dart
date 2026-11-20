import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/presentation/home_bottom_nav/bnb/bottom_nav_view.dart';

/// Booking confirmation. Replaces the whole funnel on the stack, so back
/// can't return to a form that was already submitted.
// ignore: must_be_immutable
class BookingDetailsScreen extends StatelessWidget {
  BookingDetailsScreen(
      {super.key, required this.parentPNR, required this.status});

  String parentPNR;
  String status;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.appColorAccent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5F6EE),
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 48, color: AppColors.green),
                  ),
                ),
                const SizedBox(height: 20),
                CommonText(
                  text: 'confirm.title'.tr,
                  fontSize: 22.0,
                  weight: FontWeight.w700,
                  color: AppColors.appColorTextBlack,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                CommonText(
                  text: 'confirm.subtitle'.tr,
                  fontSize: 13.5,
                  color: AppColors.appColorTextDarkGray,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.appColorWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.appColorSperator),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  text: 'PNR',
                                  fontSize: 11.0,
                                  color: AppColors.appColorTextDarkGray,
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  parentPNR,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: AppColors.appColorPrimaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'confirm.copy'.tr,
                            icon: const Icon(Icons.copy_rounded,
                                color: AppColors.appColorPrimary),
                            onPressed: () =>
                                Clipboard.setData(ClipboardData(text: parentPNR)),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.appColorSperator),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            text: 'common.status'.tr,
                            fontSize: 13.0,
                            color: AppColors.appColorTextDarkGray,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F6EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CommonText(
                              text: status,
                              fontSize: 12.0,
                              weight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.offAll(() => BottomNavScreen(fromDetails: true)),
                    child: Text('confirm.viewBookings'.tr),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.offAll(() => BottomNavScreen()),
                  child: Text('confirm.home'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
