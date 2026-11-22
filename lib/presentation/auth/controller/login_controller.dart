import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/configs/app_colors.dart';
import '../../../app/utils/api_utility/api_url.dart';
import '../../../app/data/data_controller.dart';
import '../../../app/utils/guest.dart';
import '../../../app/utils/session_validator.dart';
// import '../../../app/utils/custom_widgets/gradient_snackbar.dart';
import '../../home_bottom_nav/bnb/bottom_nav_view.dart';
import '../../update/update_required_screen.dart';
import '../model/login_model.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var loginModel = LoginModel().obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Save Remember Me Function
  Future<void> getLogin(String? username, String? password) async {
    isLoading.value = true;
    try {
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({"username": username, "password": password});

      var response = await http.post(
        Uri.parse('${baseURL}api/authenticator/loginUser'),
        headers: headers,
        body: body,
      );
      await _handle(response);
    } catch (e) {
      // debugPrint('Error: $e');

      // Show generic error snackbar
      Get.showSnackbar(
        gradientSnackbar(
          "common.failure".tr,
          "common.somethingWrong".tr,
          AppColors.orange,
          Icons.warning_rounded,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Continue with Google / Apple. [provider] opens the provider's sheet and
  /// returns the API call to make, or null when the customer closed it.
  Future<void> socialLogin(
      Future<(String, Map<String, dynamic>)?> Function() provider) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final call = await provider();
      if (call == null) return;
      final response = await http.post(
        Uri.parse('$baseURL${call.$1}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(call.$2),
      );
      await _handle(response);
    } catch (e) {
      Get.showSnackbar(gradientSnackbar("common.failure".tr,
          "common.somethingWrong".tr, AppColors.orange, Icons.warning_rounded));
    } finally {
      isLoading.value = false;
    }
  }

  /// Stores a customer's session, or explains why the sign-in was refused.
  Future<void> _handle(http.Response response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      var jsonData = json.decode(response.body) as Map<String, dynamic>;
    loginModel.value = LoginModel.fromJson(jsonData);

    // debugPrint("**** LoginController Response ****");
    // debugPrint("Login Controller: $jsonData");
    // debugPrint("Login Role: ${jsonData["data"]["role"]}");

    final data = jsonData["data"];
    if (response.statusCode == 200 && data is Map && data["role"] == 6) {
      await prefs.setInt('savedID', data["id"]);
      await prefs.setString('savedName', data["fullName"]);
      await prefs.setString('savedEmail', data["email"]);
      await prefs.setString('savedUsername', data["username"]);
      await prefs.setString('savedToken', data["accessToken"]);
      await prefs.setInt('roleID', data["role"]);
      await prefs.setString('savedRefToken', data["refreshToken"]);
      await prefs.setInt('savedRoleSupportId', data["roleSupportId"]);
      await prefs.setBool('loggedInStatus', true);
      // A guest who signs in leaves guest mode; screens read the new session.
      await Guest.leave();
      await Get.put(DataController()).loadMyData();

      // Watch for server-side deactivation while logged in
      SessionValidator.start();

      // Replace the sign-in stack so back can't return to the login form.
      Get.offAll(() => BottomNavScreen(), transition: Transition.fadeIn);
    } else if (jsonData["updateRequired"] == true) {
      // The API refuses app versions older than the SafarPlus minimum.
      Get.offAll(() => const UpdateRequiredScreen());
    } else {
      // A valid login for any other role (agent, admin) is refused
      // here; otherwise show the API's own error, e.g. the deactivation
      // reason from the ErrorHandlerMiddleware: {"error": "..."}.
      final message = response.statusCode == 200
          ? "auth.agencyOnly".tr
          : "${jsonData["error"] ?? jsonData["message"] ?? "common.somethingWrong".tr}";
      Get.showSnackbar(
        gradientSnackbar(
          "common.failure".tr,
          message,
          AppColors.red,
          Icons.warning_rounded,
        ),
      );
    }
  }

  /// Snackbar function
  GetSnackBar gradientSnackbar(
      String title, String message, Color color, IconData icon) {
    return GetSnackBar(
      titleText: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      duration: Duration(seconds: 3),
    );
  }

  Future<void> resetPassword(String? username) async {
    isLoading.value = true;
    try {
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({"email": username});

      var response = await http.post(
        Uri.parse('${baseURL}api/Accounts/reset-password/init'),
        headers: headers,
        body: body,
      );
      // debugPrint("This is my Username: $username");

      if (response.statusCode == 200) {
        isLoading.value = false;
        Get.back();
        Get.showSnackbar(
          gradientSnackbar(
            "common.success".tr,
            "auth.resetSent".tr,
            AppColors.green,
            Icons.check_circle_rounded,
          ),
        );
      }
    } catch (e) {
      // debugPrint('Error: $e');

      Get.showSnackbar(
        gradientSnackbar(
          "common.failure".tr,
          "common.somethingWrong".tr,
          AppColors.orange,
          Icons.warning_rounded,
        ),
      );
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
