import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/configs/app_links.dart';
import 'package:travel_app/app/localization/language_service.dart';
import 'package:travel_app/app/utils/api_utility/api_url.dart';
import 'package:travel_app/app/utils/auth_session.dart';
import 'package:travel_app/app/utils/custom_widgets/gradient_snackbar.dart';
import 'package:travel_app/app/utils/session_validator.dart';
import 'package:travel_app/presentation/auth/view/login_screen.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/presentation/profile/controller/user_profile_controller.dart';
import 'package:travel_app/presentation/profile/model/user_profile_model.dart';

import '../../../app/data/data_controller.dart';
import '../../booking_history/view/my_bookings_screen.dart';
import 'update_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final Rx<UserProfileModel> userProfileModel = UserProfileModel().obs;
  final RxBool isLoading = false.obs;
  final DataController dataController = Get.put(DataController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProfileController.fetchUser();
      dataController.loadMyData();
    });
  }

  String _initials(UserProfileModel u) {
    final f = (u.firstName ?? '').trim();
    final l = (u.lastName ?? '').trim();
    final s = "${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}";
    return s.isEmpty ? '?' : s.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      body: dataController.myLoggedIn.value
          ? Obx(() {
              final u = userProfileController.userProfileModel.value;
              if (userProfileController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final fullName = [u.firstName, u.middleName, u.lastName]
                  .where((s) => s != null && s.trim().isNotEmpty)
                  .join(' ');
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Identity card ------------------------------------------
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    decoration: BoxDecoration(
                      color: AppColors.appColorPrimaryDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.appColorWhite.withOpacity(0.12),
                            border: Border.all(
                                color: AppColors.appColorWhite.withOpacity(0.5)),
                          ),
                          alignment: Alignment.center,
                          child: CommonText(
                            text: _initials(u),
                            fontSize: 20.0,
                            weight: FontWeight.w700,
                            color: AppColors.appColorWhite,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: fullName.isEmpty ? '-' : fullName,
                                fontSize: 17.0,
                                weight: FontWeight.w700,
                                color: AppColors.appColorWhite,
                                maxLines: 1,
                                overFlow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              CommonText(
                                text: "@${u.username ?? '-'}",
                                fontSize: 12.5,
                                color: AppColors.appColorWhite.withOpacity(0.75),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Details ------------------------------------------------
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.appColorWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.appColorSperator),
                    ),
                    child: Column(
                      children: [
                        _row(Icons.person_outline_rounded, 'profile.firstName'.tr,
                            u.firstName),
                        _divider(),
                        _row(Icons.person_outline_rounded, 'profile.lastName'.tr,
                            u.lastName),
                        _divider(),
                        _row(Icons.mail_outline_rounded, 'profile.email'.tr,
                            u.email),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => UpdateProfileScreen(
                              name: u.firstName.toString(),
                              midName: u.middleName.toString(),
                              lastName: u.lastName.toString(),
                              email: u.email.toString(),
                              username: u.username.toString(),
                            ));
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text('profile.update'.tr),
                    ),
                  ),
                  _section('profile.support'.tr),
                  _card([
                    _link(Icons.call_outlined, 'profile.callUs'.tr,
                        AppLinks.supportPhone,
                        'tel:${AppLinks.supportPhone.replaceAll(' ', '')}'),
                    _divider(),
                    _link(Icons.mail_outline_rounded, 'profile.emailUs'.tr,
                        AppLinks.supportEmail, 'mailto:${AppLinks.supportEmail}'),
                    _divider(),
                    _link(Icons.public_rounded, 'profile.website'.tr,
                        'safarplus.so', AppLinks.website),
                    _divider(),
                    _link(Icons.privacy_tip_outlined, 'profile.privacy'.tr,
                        null, AppLinks.privacyPolicy),
                    _divider(),
                    _link(Icons.description_outlined, 'profile.terms'.tr, null,
                        AppLinks.terms),
                  ]),
                  _section('profile.account'.tr),
                  _card([
                    _action(Icons.translate_rounded, 'nav.language'.tr,
                        LanguageService.isSomali ? 'Soomaali' : 'English',
                        () async {
                      await LanguageService.toggle();
                      setState(() {});
                    }),
                    _divider(),
                    _action(Icons.logout_rounded, 'nav.logout'.tr, null,
                        _logout),
                    _divider(),
                    _action(Icons.delete_outline_rounded,
                        'profile.deleteAccount'.tr, null, _deleteAccount,
                        color: AppColors.red),
                  ]),
                ],
              );
            })
          : const Padding(
              padding: EdgeInsets.all(20),
              child: GotoLoginWidget(),
            ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, indent: 48, color: AppColors.appColorSperator);

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
        child: CommonText(
          text: title,
          fontSize: 13.0,
          weight: FontWeight.w700,
          color: AppColors.appColorTextDarkGray,
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.appColorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.appColorSperator),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );

  Widget _link(IconData icon, String label, String? detail, String url) =>
      _action(icon, label, detail, () => launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication));

  Widget _action(IconData icon, String label, String? detail, VoidCallback onTap,
      {Color color = AppColors.appColorTextBlack}) {
    final iconColor =
        color == AppColors.appColorTextBlack ? AppColors.appColorPrimary : color;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: CommonText(
                text: label,
                fontSize: 14.0,
                weight: FontWeight.w600,
                color: color,
              ),
            ),
            if (detail != null)
              CommonText(
                text: detail,
                fontSize: 12.5,
                color: AppColors.appColorTextDarkGray,
              ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.appColorTextLightGray),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    SessionValidator.stop();
    await AuthSession.clear();
    Get.offAll(() => const LoginScreen());
  }

  /// Store requirement: customers can delete their own account in the app
  /// (DELETE api/Accounts/me). Tickets already booked stay valid.
  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('profile.deleteTitle'.tr),
        content: Text('profile.deleteBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text('profile.deleteConfirm'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await dataController.loadMyData();
      final response = await http.delete(
        Uri.parse('${baseURL}api/Accounts/me'),
        headers: {'authorization': 'Bearer ${dataController.myToken.value}'},
      );
      if (response.statusCode != 200) {
        String message = 'common.error'.tr;
        try {
          message = '${(json.decode(response.body) as Map)['error'] ?? message}';
        } catch (_) {}
        Get.showSnackbar(gradientSnackbar('common.failure'.tr, message,
            AppColors.red, Icons.warning_rounded));
        return;
      }
      await _logout();
      Get.showSnackbar(gradientSnackbar('common.success'.tr,
          'profile.deleted'.tr, AppColors.green, Icons.check_circle_rounded));
    } catch (_) {
      Get.showSnackbar(gradientSnackbar('common.failure'.tr, 'common.error'.tr,
          AppColors.red, Icons.warning_rounded));
    }
  }

  Widget _row(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.appColorPrimary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: label,
                  fontSize: 11.0,
                  color: AppColors.appColorTextDarkGray,
                ),
                const SizedBox(height: 2),
                CommonText(
                  text: (value == null || value.trim().isEmpty) ? '-' : value,
                  fontSize: 14.0,
                  weight: FontWeight.w600,
                  color: AppColors.appColorTextBlack,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
