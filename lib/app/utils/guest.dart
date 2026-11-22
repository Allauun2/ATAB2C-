import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Booking without an account. The choice is remembered, so a guest opens
/// straight to search, and the trips they book are kept on this phone: with no
/// account there is nothing to list them from. Any booking can still be found
/// by its PNR.
class Guest {
  static const _modeKey = 'guestMode';
  static const _tripsKey = 'guestTrips';

  static Future<bool> isOn() async =>
      (await SharedPreferences.getInstance()).getBool(_modeKey) ?? false;

  static Future<void> enter() async =>
      (await SharedPreferences.getInstance()).setBool(_modeKey, true);

  static Future<void> leave() async =>
      (await SharedPreferences.getInstance()).remove(_modeKey);

  /// Newest first.
  static Future<List<GuestTrip>> trips() async {
    final raw = (await SharedPreferences.getInstance()).getStringList(_tripsKey);
    return [
      for (final s in raw ?? const <String>[])
        GuestTrip.fromJson(json.decode(s) as Map<String, dynamic>)
    ];
  }

  static Future<void> saveTrip(GuestTrip trip) async {
    final prefs = await SharedPreferences.getInstance();
    final kept = (await trips()).where((t) => t.pnr != trip.pnr);
    await prefs.setStringList(
        _tripsKey, [for (final t in [trip, ...kept]) json.encode(t.toJson())]);
  }
}

class GuestTrip {
  const GuestTrip(
      {required this.pnr,
      required this.route,
      required this.date,
      required this.airline});

  final String pnr;
  final String route; // "MGQ → NBO", or "MGQ ⇄ NBO" for a return
  final String date; // yyyy-MM-dd of the first flight
  final String airline;

  factory GuestTrip.fromJson(Map<String, dynamic> j) => GuestTrip(
        pnr: '${j['pnr']}',
        route: '${j['route']}',
        date: '${j['date']}',
        airline: '${j['airline'] ?? ''}',
      );

  Map<String, dynamic> toJson() =>
      {'pnr': pnr, 'route': route, 'date': date, 'airline': airline};
}
