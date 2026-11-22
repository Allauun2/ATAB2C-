import 'package:flutter/material.dart';
import 'social_buttons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/localization/language_service.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/presentation/auth/view/customer_register_screen.dart';
import 'package:travel_app/presentation/auth/view/reset_password_screen.dart';
import 'package:travel_app/app/data/data_controller.dart';
import 'package:travel_app/app/utils/guest.dart';
import 'package:travel_app/presentation/home_bottom_nav/bnb/bottom_nav_view.dart';

import '../controller/login_controller.dart';

/// Agency sign-in: brand header on navy, form on a white sheet. The page
/// scrolls under the keyboard, fields support password managers, and the
/// language can be switched before signing in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());
  final userController = TextEditingController();
  final passController = TextEditingController();
  final _passFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (loginController.isLoading.value) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();
    loginController.getLogin(
        userController.text.trim(), passController.text.trim());
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.appColorTextDarkGray, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.appColorWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.appColorTextDarkGray),
      floatingLabelStyle: const TextStyle(color: AppColors.appColorPrimary),
      errorStyle: const TextStyle(color: AppColors.red, fontSize: 11.5),
      border: border(const Color(0xFFB9C2D4)),
      enabledBorder: border(const Color(0xFFB9C2D4)),
      focusedBorder: border(AppColors.appColorPrimary, 2),
      errorBorder: border(AppColors.red),
      focusedErrorBorder: border(AppColors.red, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Matches the header gradient's end so the sheet's rounded corners
        // blend into it.
        backgroundColor: const Color(0xFF16306B),
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context),
                    Expanded(child: _form()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1B3F), Color(0xFF16306B)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 8, 12, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await LanguageService.toggle();
                setState(() {});
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.appColorWhite,
                iconColor: AppColors.appColorWhite,
              ),
              icon: const Icon(Icons.language_rounded, size: 18),
              label: Text(LanguageService.isSomali ? 'English' : 'Soomaali'),
            ),
          ),
          const SizedBox(height: 20),
          Image.asset('assets/1003.png', height: 56),
          const SizedBox(height: 28),
          CommonText(
            text: 'auth.welcome'.tr,
            fontSize: 26.0,
            weight: FontWeight.w700,
            color: AppColors.appColorWhite,
          ),
          const SizedBox(height: 6),
          CommonText(
            text: 'auth.agencySubtitle'.tr,
            fontSize: 14.0,
            color: AppColors.appColorWhite.withOpacity(0.75),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 28, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText(
                text: 'auth.signIn'.tr,
                fontSize: 20.0,
                weight: FontWeight.w700,
                color: AppColors.appColorTextBlack,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: userController,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                onFieldSubmitted: (_) => _passFocus.requestFocus(),
                decoration: _decoration(
                  label: 'auth.username'.tr,
                  icon: Icons.mail_outline_rounded,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'auth.enterUsername'.tr
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passController,
                focusNode: _passFocus,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _decoration(
                  label: 'auth.password'.tr,
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    tooltip: _obscure ? 'auth.showPassword'.tr : 'auth.hidePassword'.tr,
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.appColorTextDarkGray,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'auth.enterPassword'.tr : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const ResetPasswordScreen()),
                  child: Text(
                    'auth.forgotPassword'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final loading = loginController.isLoading.value;
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor:
                          AppColors.appColorPrimary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('auth.signIn'.tr,
                            style: const TextStyle(fontSize: 15)),
                  ),
                );
              }),
              const SocialButtons(),
              const SizedBox(height: 18),
              CommonText(
                text: 'auth.noAccount'.tr,
                fontSize: 13.0,
                color: AppColors.appColorTextDarkGray,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Get.to(() => const CustomerRegisterScreen()),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(
                      color: AppColors.appColorPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('auth.createAccount'.tr,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () async {
                  await Guest.enter();
                  await Get.put(DataController()).loadMyData();
                  Get.offAll(() => BottomNavScreen(),
                      transition: Transition.fadeIn);
                },
                child: Text('auth.continueAsGuest'.tr,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              const SizedBox(height: 24),
              CommonText(
                text: 'auth.agencyOnlyHint'.tr,
                fontSize: 12.0,
                color: AppColors.appColorTextLightGray,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
