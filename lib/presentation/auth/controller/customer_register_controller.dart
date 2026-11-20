import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/configs/app_colors.dart';
import '../../../app/data/providers.dart';
import '../../../app/utils/api_utility/api_url.dart';
import '../../../app/utils/custom_widgets/gradient_snackbar.dart';

/// Customer sign-up: POST api/Accounts/register/customer. The API emails an
/// activation link; the account can sign in once it is opened.
class CustomerRegisterController extends GetxController {
  var isLoading = false.obs;

  /// True when the account was created (activation email sent).
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${baseURL}api/Accounts/register/customer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'username': email,
          'email': email,
          'password': password,
          'mobileCode': '+252',
          'mobileNo': phone,
          'microSiteClientId': GetProviders.clientId,
        }),
      );
      if (response.statusCode == 200) return true;

      _fail(_errorText(response.body));
      return false;
    } catch (_) {
      _fail('common.error'.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// The API answers {"error": "..."} for its own errors and a validation
  /// problem ({"errors": {field: [..]}}) for rejected fields.
  String _errorText(String body) {
    try {
      final data = json.decode(body);
      if (data is Map) {
        final error = '${data['error'] ?? ''}';
        if (error.toLowerCase().contains('already exist')) {
          return 'register.exists'.tr;
        }
        if (error.isNotEmpty) return error;
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          return first is List && first.isNotEmpty ? '${first.first}' : '$first';
        }
        if (data['title'] != null) return '${data['title']}';
      }
    } catch (_) {}
    return 'common.error'.tr;
  }

  void _fail(String message) => Get.showSnackbar(gradientSnackbar(
      'common.failure'.tr, message, AppColors.red, Icons.warning_rounded));
}
