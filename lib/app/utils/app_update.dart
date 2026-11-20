import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../presentation/update/update_required_screen.dart';
import '../configs/app_links.dart';
import '../data/providers.dart';
import 'api_utility/api_url.dart';

/// Forced update. ATA sets, for SafarPlus, the oldest app version it still accepts, per
/// platform, as a microsite setting (keys below, microsite 2). An install older
/// than that sees only the "Update required" screen. A missing or empty key, or
/// a check that fails (offline, server error), lets the app through — a network
/// blip must never lock customers out.
class AppUpdate {
  static const androidKey = 'safarplus_min_version_android';
  static const iosKey = 'safarplus_min_version_ios';

  static const _androidStoreUrl = AppLinks.androidStore;
  static const _iosStoreUrl = AppLinks.iosStore;

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  static String get storeUrl => _isIos ? _iosStoreUrl : _androidStoreUrl;

  static DateTime? _lastCheck;

  /// Whether this install is older than the minimum set for SafarPlus.
  static Future<bool> isRequired() async {
    _lastCheck = DateTime.now();
    try {
      final res = await http
          .post(
            Uri.parse('${baseURL}api/ClientMicroSite/configuration/'
                '${GetProviders.clientId}/get-by-keys'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode([
              {'key': _isIos ? iosKey : androidKey}
            ]),
          )
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return false;
      final rows = json.decode(res.body) as List;
      final minimum = rows.isEmpty ? '' : '${rows.first['value'] ?? ''}'.trim();
      if (minimum.isEmpty) return false;
      final current = (await PackageInfo.fromPlatform()).version;
      return isOlder(current, minimum);
    } catch (_) {
      return false;
    }
  }

  /// Compares dotted versions number by number, so 2.3.10 is newer than 2.3.9.
  static bool isOlder(String current, String minimum) {
    List<int> parts(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    final a = parts(current), b = parts(minimum);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x < y;
    }
    return false;
  }

  /// Shows the blocking update screen when needed; true if it did.
  static Future<bool> enforce() async {
    if (!await isRequired()) return false;
    Get.offAll(() => const UpdateRequiredScreen());
    return true;
  }

  /// Checks again whenever the app returns to the foreground (at most every
  /// five minutes), so a phone that keeps the app open for days still updates.
  static void watchResume() =>
      WidgetsBinding.instance.addObserver(_ResumeWatcher());
}

class _ResumeWatcher extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final last = AppUpdate._lastCheck;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 5)) {
      return;
    }
    AppUpdate.enforce();
  }
}
