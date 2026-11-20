import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/configs/app_colors.dart';
import '../../../app/configs/app_links.dart';
import '../../../app/utils/custom_widgets/common_text.dart';
import '../../../app/utils/custom_widgets/custom_appbar.dart';
import '../controller/customer_register_controller.dart';

/// Customer sign-up. Email is the login; the API sends an activation link to
/// it, so the screen ends on "check your email" and returns to sign-in.
class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final controller = Get.put(CustomerRegisterController());
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phonePattern = RegExp(r'^6\d{8}$');

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _name(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'register.required'.tr;
    return t.length < 3 ? 'register.nameRule'.tr : null;
  }

  Future<void> _submit() async {
    if (controller.isLoading.value) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final ok = await controller.register(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      email: email,
      password: _password.text,
      phone: _phone.text.trim(),
    );
    if (!ok || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.mark_email_read_outlined,
            size: 40, color: AppColors.appColorPrimary),
        title: Text('register.doneTitle'.tr),
        content: Text('register.doneBody'.trParams({'email': email})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.ok'.tr),
          ),
        ],
      ),
    );
    Get.back();
  }

  InputDecoration _decoration(String label, IconData icon,
          {Widget? suffix, String? hint, String? prefix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        errorMaxLines: 2,
        prefixIcon: Icon(icon, size: 20, color: AppColors.appColorTextDarkGray),
        suffixIcon: suffix,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      appBar: CustomAppBar(title: 'register.title'.tr),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Image.asset('assets/1000.png', height: 44),
                const SizedBox(height: 10),
                CommonText(
                  text: 'register.subtitle'.tr,
                  fontSize: 14.0,
                  color: AppColors.appColorTextDarkGray,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _first,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.givenName],
                        decoration: _decoration(
                            'register.firstName'.tr, Icons.person_outline),
                        validator: _name,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _last,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.familyName],
                        decoration: _decoration(
                            'register.lastName'.tr, Icons.person_outline),
                        validator: _name,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: _decoration(
                      'register.email'.tr, Icons.mail_outline_rounded),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'register.required'.tr;
                    return _emailPattern.hasMatch(t) && t.length <= 50
                        ? null
                        : 'register.invalidEmail'.tr;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: _decoration(
                      'register.phone'.tr, Icons.phone_iphone_rounded,
                      hint: 'register.phoneHint'.tr, prefix: '+252 '),
                  validator: (v) => _phonePattern.hasMatch(v?.trim() ?? '')
                      ? null
                      : 'register.invalidPhone'.tr,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: _decoration(
                    'register.password'.tr,
                    Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v ?? '').length >= 8
                      ? null
                      : 'register.passwordRule'.tr,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _decoration('register.confirmPassword'.tr,
                      Icons.lock_outline_rounded),
                  validator: (v) => v == _password.text
                      ? null
                      : 'register.passwordMismatch'.tr,
                ),
                const SizedBox(height: 14),
                CommonText(
                  text: 'register.agree'.tr,
                  fontSize: 12.0,
                  color: AppColors.appColorTextDarkGray,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => launchUrl(Uri.parse(AppLinks.terms),
                          mode: LaunchMode.externalApplication),
                      child: Text('profile.terms'.tr),
                    ),
                    TextButton(
                      onPressed: () => launchUrl(
                          Uri.parse(AppLinks.privacyPolicy),
                          mode: LaunchMode.externalApplication),
                      child: Text('profile.privacy'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text('register.submit'.tr,
                              style: const TextStyle(fontSize: 15)),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonText(
                      text: 'register.haveAccount'.tr,
                      fontSize: 13.0,
                      color: AppColors.appColorTextDarkGray,
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('auth.signIn'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
