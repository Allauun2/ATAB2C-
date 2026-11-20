import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/data/data_controller.dart';
import '../../../app/data/providers.dart';
import '../../../app/utils/api_utility/api_url.dart';
import '../model/booking_trip.dart';
import '../model/flight_quote_model.dart';

class SearchFailure implements Exception {}

/// Nationality option from the API's country list (same source as the portal).
class Country {
  Country(this.id, this.isoCode, this.name, this.phoneCode);
  final int id;
  final String isoCode, name, phoneCode;
}

/// Flight quote search. The API quotes one provider per request, so every
/// search fans out to all providers in parallel and merges the flights, each
/// tagged with the search id it must be booked under.
class FlightSearchService {
  static Future<Map<String, String>> _headers() async {
    final dc = Get.put(DataController());
    if (dc.myToken.value.isEmpty) await dc.loadMyData();
    return {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${dc.myToken.value}',
    };
  }

  static Future<List<QuotedFlight>> search({
    required String from,
    required String to,
    required String departDate,
    String? returnDate,
    required TravellerParty party,
  }) async {
    final headers = await _headers();
    final roundTrip = returnDate != null;
    final requests = GetProviders.providers.map((provider) async {
      try {
        final res = await http.post(
          Uri.parse('${baseURL}api/FlightQuote/search'),
          headers: headers,
          body: json.encode({
            'DepartureCity': from,
            'ArrivalCity': to,
            'DepartureDate': departDate,
            'ReturnDate': returnDate,
            'Adults': party.adults,
            'Children': party.children,
            // The portal sends the ages with the search; some providers price
            // children off them.
            'ChildrenAges': party.childAges,
            'Infants': party.infants,
            'CabinClass': party.cabin,
            'IsFlexibleDates': true,
            'IsDirectFlight': true,
            'TripType': roundTrip ? 'RoundTrip' : 'OneWay',
            'MicrositeClientId': GetProviders.clientId,
            'provider': provider,
          }),
        );
        if (res.statusCode != 200) return null;
        final quote = FlightQuoteModel.fromJson(json.decode(res.body));
        final searchId = int.tryParse('${quote.id}') ?? 0;
        return [
          for (final f in quote.flights ?? <Flights>[])
            // A round-trip quote can include one-way fares; skip those.
            if (f.outBound != null && (!roundTrip || f.inBound != null))
              QuotedFlight(f, searchId)
        ];
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(requests);
    if (results.every((r) => r == null)) throw SearchFailure();
    return [for (final r in results) ...?r]
      ..sort((a, b) => a.total.compareTo(b.total));
  }

  /// Prices the chosen flights. Booking fails with "Invalid Price Pnr ID"
  /// unless this runs first: it creates the price record the booking uses.
  static Future<void> priceTrip(BookingTrip trip) async {
    final res = await http.post(
      Uri.parse('${baseURL}api/FlightFareRules'),
      headers: await _headers(),
      body: json.encode({'flightSelection': trip.flightSelection}),
    );
    if (res.statusCode != 200) throw SearchFailure();
    final flights = (json.decode(res.body)['flights'] as List?) ?? [];
    if (flights.isEmpty) throw SearchFailure();
    double sum(String key) =>
        flights.fold(0, (a, f) => a + (double.tryParse('${f[key]}') ?? 0));
    trip
      ..pricedTotal = sum('totalAmount')
      ..pricedTax = sum('taxesAmount');
  }

  static List<Country>? _countries;

  static Future<List<Country>> countries() async {
    if (_countries != null) return _countries!;
    final res = await http.get(Uri.parse('${baseURL}api/Country'),
        headers: await _headers());
    if (res.statusCode != 200) throw SearchFailure();
    final list = (json.decode(res.body) as List)
        .where((c) => c['isActive'] != false && '${c['isoCode']}'.isNotEmpty)
        .map((c) => Country(
              c['id'] as int,
              '${c['isoCode']}',
              '${c['friendlyName'] ?? c['name']}',
              '${c['phoneCode'] ?? ''}',
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _countries = list;
  }
}
