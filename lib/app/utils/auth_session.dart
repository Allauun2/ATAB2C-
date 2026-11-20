import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_utility/api_url.dart';

/// Keeps the user signed in across app launches, like any consumer app:
/// the stored access token (33h) is reused, and when it lapses the stored
/// refresh token (14-day rolling) buys a new pair via
/// POST api/Authenticator/RefreshToken. The user only sees the login screen
/// again when both are gone or the account is deactivated.
class AuthSession {
  /// True when a stored session exists and is usable (refreshing it if needed).
  /// Fails OPEN on network errors — the API still rejects a genuinely dead
  /// token on every call, but a blip must not force a re-login.
  static Future<bool> tryRestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('savedToken');
    if (prefs.getBool('loggedInStatus') != true || token == null) return false;

    try {
      var response = await http.get(
        Uri.parse('${baseURL}api/Accounts/validate-session'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) return true;

      if (response.statusCode == 401) {
        // Deactivated accounts must NOT be silently restored.
        try {
          var body = json.decode(response.body) as Map<String, dynamic>;
          if (body["isDeactivated"] == true) {
            await clear();
            return false;
          }
        } catch (_) {}
        // Otherwise the access token has just expired — refresh it.
        return await refresh();
      }

      // Any other status (404, 500…): keep the session, fail open.
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Exchange the stored refresh token for a new token pair.
  static Future<bool> refresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var refreshToken = prefs.getString('savedRefToken');
    var userId = prefs.getInt('savedID');
    if (refreshToken == null || userId == null) return false;

    try {
      var response = await http.post(
        Uri.parse('${baseURL}api/Authenticator/RefreshToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"userId": userId, "refreshToken": refreshToken}),
      );

      if (response.statusCode != 200) {
        await clear();
        return false;
      }

      var body = json.decode(response.body) as Map<String, dynamic>;
      var access = body["accessToken"];
      var newRefresh = body["refreshToken"];
      if (access == null || newRefresh == null) {
        await clear();
        return false;
      }

      await prefs.setString('savedToken', access);
      await prefs.setString('savedRefToken', newRefresh);
      return true;
    } catch (_) {
      // Network failure: don't destroy the session over a blip.
      return false;
    }
  }

  /// Forget the stored session (logout / deactivation / dead refresh token).
  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedInStatus', false);
    await prefs.remove('savedToken');
    await prefs.remove('savedRefToken');
  }
}
