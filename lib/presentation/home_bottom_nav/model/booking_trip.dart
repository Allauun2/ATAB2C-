import '../model/flight_quote_model.dart';

/// A priced flight from one provider's quote. `searchId` is that provider's
/// search id — booking needs the pair (searchId, flightId).
class QuotedFlight {
  QuotedFlight(this.flight, this.searchId);
  final Flights flight;
  final int searchId;

  double get total => double.tryParse('${flight.totalAmount}') ?? 0;
  double get tax => double.tryParse('${flight.taxesAmount}') ?? 0;
  String get airline => flight.outBound?.segments?.first.airlineName ?? '';
  String? get logo => flight.outBound?.segments?.first.airlineLogo;
  String get departureKey => flight.outBound?.departureDateTime ?? '';
}

/// One flown leg, for display on every funnel screen.
class TripLeg {
  const TripLeg({
    required this.airline,
    required this.flightNumber,
    required this.fromCode,
    required this.fromTime,
    required this.toCode,
    required this.toTime,
    required this.date,
    this.logoUrl,
  });

  final String airline, flightNumber, fromCode, fromTime, toCode, toTime;
  final String date; // yyyy-MM-dd
  final String? logoUrl;

  static TripLeg fromBound(OutBound b) {
    final s = b.segments?.first;
    return TripLeg(
      airline: s?.airlineName ?? '',
      flightNumber: s?.flightNumber ?? '',
      logoUrl: s?.airlineLogo,
      fromCode: s?.departure ?? b.departure ?? '',
      fromTime: b.departureTime ?? '',
      toCode: s?.arrival ?? b.arrival ?? '',
      toTime: b.arrivalTime ?? '',
      date: b.departureDate ?? '',
    );
  }
}

/// Who is travelling and in which cabin — fixed from the search form onward.
class TravellerParty {
  const TravellerParty({
    required this.adults,
    required this.children,
    required this.infants,
    required this.childAges,
    required this.cabin,
  });

  final int adults, children, infants;
  final List<int> childAges;
  final String cabin;
}

/// Everything the passenger and payment steps need about the chosen flights.
class BookingTrip {
  BookingTrip({
    required this.selections,
    required this.party,
  });

  /// One entry per bookable flight (1 for one-way/round trip, N for multi-city).
  final List<QuotedFlight> selections;
  final TravellerParty party;

  List<TripLeg> get legs => [
        for (final q in selections) ...[
          if (q.flight.outBound != null) TripLeg.fromBound(q.flight.outBound!),
          if (q.flight.inBound != null) TripLeg.fromBound(q.flight.inBound!),
        ]
      ];

  /// Set from the fare-rules response, which reprices the selection.
  double? pricedTotal, pricedTax;

  double get total => pricedTotal ?? selections.fold(0, (a, q) => a + q.total);
  double get tax => pricedTax ?? selections.fold(0, (a, q) => a + q.tax);
  double get fare => total - tax;

  List<Map<String, int>> get flightSelection => [
        for (final q in selections)
          {'searchId': q.searchId, 'flightId': int.parse('${q.flight.id}')}
      ];

  DateTime? get firstDeparture => DateTime.tryParse(legs.first.date);
  DateTime? get lastDeparture => DateTime.tryParse(legs.last.date);
}
