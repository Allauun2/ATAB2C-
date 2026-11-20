import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/configs/app_colors.dart';
import '../../../app/utils/custom_widgets/common_text.dart';
import '../../../app/utils/custom_widgets/custom_appbar.dart';
import '../../../app/utils/custom_widgets/flight_leg.dart';
import '../controller/flight_search_service.dart';
import '../model/booking_trip.dart';
import 'passenger_details.dart';

/// One-way / round-trip results: date strip, sort + airline filter, fare cards.
/// Selecting a fare goes straight to passenger details.
class FlightResultsScreen extends StatefulWidget {
  const FlightResultsScreen({
    required this.from,
    required this.to,
    required this.departDate,
    required this.party,
    this.returnDate,
    super.key,
  });

  final String from, to; // airport codes
  final DateTime departDate;
  final DateTime? returnDate;
  final TravellerParty party;

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  static final _api = DateFormat('yyyy-MM-dd');

  late DateTime _depart = widget.departDate;
  DateTime? get _return => widget.returnDate == null
      ? null
      : _depart.add(widget.returnDate!.difference(widget.departDate));

  List<QuotedFlight>? _flights;
  bool _failed = false;
  final _filter = ResultsFilter();
  int _requestNo = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final request = ++_requestNo;
    setState(() {
      _flights = null;
      _failed = false;
    });
    try {
      final flights = await FlightSearchService.search(
        from: widget.from,
        to: widget.to,
        departDate: _api.format(_depart),
        returnDate: _return == null ? null : _api.format(_return!),
        party: widget.party,
      );
      // A slower, older request must not overwrite a newer date's results.
      if (!mounted || request != _requestNo) return;
      setState(() => _flights = flights);
    } on SearchFailure {
      if (!mounted || request != _requestNo) return;
      setState(() => _failed = true);
    }
  }

  void _select(QuotedFlight q) {
    Get.to(() => PassengerDetailsScreen(
          trip: BookingTrip(selections: [q], party: widget.party),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final days = _depart.difference(start).inDays + 30;

    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      appBar: CustomAppBar(title: '${widget.from} – ${widget.to}'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.appColorWhite,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: DatePicker(
              start,
              height: 84,
              width: 54,
              daysCount: days < 30 ? 30 : days,
              initialSelectedDate: _depart,
              selectionColor: AppColors.appColorPrimary,
              selectedTextColor: AppColors.appColorWhite,
              dayTextStyle: const TextStyle(
                  fontSize: 10, color: AppColors.appColorTextDarkGray),
              monthTextStyle: const TextStyle(
                  fontSize: 10, color: AppColors.appColorTextDarkGray),
              dateTextStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appColorTextBlack),
              onDateChange: (d) {
                _depart = d;
                _load();
              },
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_failed) return ResultsError(onRetry: _load);
    if (_flights == null) return const ResultsLoading();
    if (_flights!.isEmpty) return const ResultsEmpty();
    return FlightResultsList(
      flights: _flights!,
      filter: _filter,
      onChanged: () => setState(() {}),
      onSelect: _select,
    );
  }
}

// ======================================================= shared list + filter

enum ResultSort { cheapest, priciest, earliest, latest }

/// Sort + airline filter state for a results list.
class ResultsFilter {
  ResultSort sort = ResultSort.cheapest;
  final Set<String> airlines = {};

  bool get active => airlines.isNotEmpty;

  List<QuotedFlight> apply(List<QuotedFlight> all) {
    final list = [
      for (final q in all)
        if (airlines.isEmpty || airlines.contains(q.airline)) q
    ];
    switch (sort) {
      case ResultSort.cheapest:
        list.sort((a, b) => a.total.compareTo(b.total));
      case ResultSort.priciest:
        list.sort((a, b) => b.total.compareTo(a.total));
      case ResultSort.earliest:
        list.sort((a, b) => a.departureKey.compareTo(b.departureKey));
      case ResultSort.latest:
        list.sort((a, b) => b.departureKey.compareTo(a.departureKey));
    }
    return list;
  }
}

class FlightResultsList extends StatelessWidget {
  const FlightResultsList({
    required this.flights,
    required this.filter,
    required this.onChanged,
    required this.onSelect,
    this.selected,
    this.bottomPadding = 24,
    super.key,
  });

  final List<QuotedFlight> flights;
  final ResultsFilter filter;
  final VoidCallback onChanged;
  final ValueChanged<QuotedFlight> onSelect;
  final QuotedFlight? selected;
  final double bottomPadding;

  static const _sortLabels = {
    ResultSort.cheapest: 'results.sortCheapest',
    ResultSort.priciest: 'results.sortPriciest',
    ResultSort.earliest: 'results.sortEarliest',
    ResultSort.latest: 'results.sortLatest',
  };

  void _sortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sheetTitle('results.sortBy'.tr),
            for (final s in ResultSort.values)
              ListTile(
                title: CommonText(
                  text: _sortLabels[s]!.tr,
                  fontSize: 14.0,
                  weight: filter.sort == s ? FontWeight.w700 : FontWeight.w500,
                  color: filter.sort == s
                      ? AppColors.appColorPrimary
                      : AppColors.appColorTextBlack,
                ),
                trailing: filter.sort == s
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.appColorPrimary)
                    : null,
                onTap: () {
                  filter.sort = s;
                  Navigator.pop(ctx);
                  onChanged();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _filterSheet(BuildContext context) {
    final counts = <String, int>{};
    for (final q in flights) {
      counts[q.airline] = (counts[q.airline] ?? 0) + 1;
    }
    final names = counts.keys.toList()..sort();
    final draft = {...filter.airlines};

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final shown = flights
              .where((q) => draft.isEmpty || draft.contains(q.airline))
              .length;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sheetTitle('results.airlines'.tr,
                      trailing: draft.isEmpty
                          ? null
                          : TextButton(
                              onPressed: () => setSheet(draft.clear),
                              child: Text('results.clear'.tr),
                            )),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.5),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final n in names)
                          CheckboxListTile(
                            value: draft.contains(n),
                            activeColor: AppColors.appColorPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: CommonText(
                              text: n,
                              fontSize: 14.0,
                              weight: FontWeight.w500,
                              color: AppColors.appColorTextBlack,
                            ),
                            secondary: CommonText(
                              text: '${counts[n]}',
                              fontSize: 12.5,
                              color: AppColors.appColorTextDarkGray,
                            ),
                            onChanged: (v) => setSheet(
                                () => v! ? draft.add(n) : draft.remove(n)),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          filter.airlines
                            ..clear()
                            ..addAll(draft);
                          Navigator.pop(ctx);
                          onChanged();
                        },
                        child: Text('results.showFlights'
                            .trParams({'count': '$shown'})),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetTitle(String text, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: CommonText(
                text: text,
                fontSize: 16.0,
                weight: FontWeight.w700,
                color: AppColors.appColorTextBlack,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final visible = filter.apply(flights);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultsToolbar(
          count: visible.length,
          filterActive: filter.active,
          onSort: () => _sortSheet(context),
          onFilter: () => _filterSheet(context),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: visible.length,
            itemBuilder: (_, i) => _card(visible[i]),
          ),
        ),
      ],
    );
  }

  Widget _card(QuotedFlight q) {
    final out = q.flight.outBound!;
    final inb = q.flight.inBound;
    final outLeg = TripLeg.fromBound(out);
    final inLeg = inb == null ? null : TripLeg.fromBound(inb);
    final airline = inLeg != null && inLeg.airline != outLeg.airline
        ? '${outLeg.airline} · ${inLeg.airline}'
        : outLeg.airline;
    final isSelected = selected != null &&
        selected!.searchId == q.searchId &&
        '${selected!.flight.id}' == '${q.flight.id}';

    return ResultCard(
      airline: airline,
      flightNumber: '',
      logoUrl: outLeg.logoUrl,
      amount: q.total,
      selected: isSelected,
      buttonLabel: isSelected ? 'results.selected'.tr : null,
      onTap: () => onSelect(q),
      legs: [
        FlightLegRow(
          fromCode: outLeg.fromCode,
          fromTime: outLeg.fromTime,
          toCode: outLeg.toCode,
          toTime: outLeg.toTime,
          caption: inLeg == null
              ? outLeg.flightNumber
              : "${'passenger.outbound'.tr} · ${outLeg.flightNumber}",
          date: outLeg.date,
        ),
        if (inLeg != null)
          FlightLegRow(
            fromCode: inLeg.fromCode,
            fromTime: inLeg.fromTime,
            toCode: inLeg.toCode,
            toTime: inLeg.toTime,
            caption: "${'passenger.inbound'.tr} · ${inLeg.flightNumber}",
            date: inLeg.date,
          ),
      ],
    );
  }
}
