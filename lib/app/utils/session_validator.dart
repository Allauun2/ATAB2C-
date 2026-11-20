import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/auth/view/login_screen.dart';
import '../data/data_controller.dart';
import 'api_utility/api_url.dart';
import 'auth_session.dart';

/// Periodically validates the session against the API and force-logs-out the
/// user if their account, agency or agency-user access has been deactivated.
/// Mirrors the Microsite's SessionValidationService (immediate check on start,
/// then every 5 minutes).
class SessionValidator {
  static Timer? _timer;
  static const Duration _interval = Duration(minutes: 5);

  /// Start after a successful login.
  static void start() {
    stop();
    _check();
    _timer = Timer.periodic(_interval, (_) => _check());
  }

  /// Stop on logout.
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _check() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('savedToken');
      if (token == null || prefs.getBool('loggedInStatus') != true) {
        stop();
        return;
      }

      var response = await http.get(
        Uri.parse('${baseURL}api/Accounts/validate-session'),
        headers: {'authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        bool deactivated = false;
        String? message;
        try {
          var jsonData = json.decode(response.body) as Map<String, dynamic>;
          deactivated = jsonData["isDeactivated"] == true;
          message = jsonData["message"];
        } catch (_) {}

        if (deactivated) {
          await _forceLogout("auth.deactivatedTitle".tr,
              message ?? "auth.deactivatedBody".tr);
          return;
        }

        // Plain 401 = the access token lapsed, NOT a deactivation. Refresh
        // silently; only a dead refresh token ends the session.
        if (!await AuthSession.refresh()) {
          var stillLoggedIn = (await SharedPreferences.getInstance())
                  .getBool('loggedInStatus') ==
              true;
          if (!stillLoggedIn) {
            await _forceLogout("auth.sessionExpiredTitle".tr,
                "auth.sessionExpiredBody".tr);
          }
        } else {
          // New token pair saved — reload it into the GetX store.
          await Get.put(DataController()).loadMyData();
        }
      }
    } catch (_) {
      // Network hiccups: ignore and retry on the next tick.
    }
  }

  static Future<void> _forceLogout(String title, String message) async {
    stop();
    await AuthSession.clear();

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("common.ok".tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    Get.offAll(() => LoginScreen());
  }
}
