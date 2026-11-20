import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Names the app and its version on every request ("SafarPlus/1.0.0 (android)"
/// as the User-Agent) so the API can refuse outdated copies at login and search
/// (its minimums are the safarplus_min_version_* settings).
class AppIdentity {
  static Future<void> install() async {
    if (kIsWeb) return;
    final info = await PackageInfo.fromPlatform();
    final platform = Platform.isIOS ? 'ios' : 'android';
    HttpOverrides.global =
        _AgentOverrides('SafarPlus/${info.version} ($platform)');
  }
}

class _AgentOverrides extends HttpOverrides {
  _AgentOverrides(this.agent);
  final String agent;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)..userAgent = agent;
}
