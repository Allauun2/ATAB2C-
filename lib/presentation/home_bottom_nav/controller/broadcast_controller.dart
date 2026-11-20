import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/data/data_controller.dart';
import '../../../app/data/providers.dart';
import '../../../app/utils/api_utility/api_url.dart';

/// A live admin announcement, as served by GET api/BroadcastMessage/active.
/// Mirrors the portal's BroadcastService contract.
class BroadcastMessage {
  final int id;
  final String title;
  final String message;
  final String severity; // info | success | warning | error

  BroadcastMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
  });

  factory BroadcastMessage.fromJson(Map<String, dynamic> json) =>
      BroadcastMessage(
        id: json["id"] ?? 0,
        title: json["title"] ?? "",
        message: json["message"] ?? "",
        severity: json["severity"] ?? "info",
      );
}

/// Fetches the admin broadcasts shown as banners above the flight search.
/// A failure must never break the search screen, so errors collapse to an
/// empty list (portal parity). Dismissal is session-only, like the portal.
class BroadcastController extends GetxController {
  final DataController dataController = Get.put(DataController());

  var messages = <BroadcastMessage>[].obs;
  final _dismissed = <int>{};

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      await dataController.loadMyData();
      var response = await http.get(
        Uri.parse(
            '${baseURL}api/BroadcastMessage/active?microSiteClientId=${GetProviders.clientId}'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer ${dataController.myToken.value}',
        },
      );
      if (response.statusCode == 200) {
        messages.value = (json.decode(response.body) as List)
            .map((e) => BroadcastMessage.fromJson(e))
            .where((m) => !_dismissed.contains(m.id))
            .toList();
      }
    } catch (_) {
      // Fail silent — the banner is informational, never blocking.
    }
  }

  void dismiss(int id) {
    _dismissed.add(id);
    messages.removeWhere((m) => m.id == id);
  }
}
