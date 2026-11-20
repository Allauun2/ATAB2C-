import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/configs/app_colors.dart';
import '../../../app/utils/custom_widgets/common_text.dart';
import '../../../app/utils/custom_widgets/custom_appbar.dart';
import '../../../app/utils/custom_widgets/flight_leg.dart';
import '../controller/flight_search_service.dart';
import '../model/booking_trip.dart';
import 'flight_results.dart';
import 'passenger_details.dart';

class SearchLeg {
  const SearchLeg(this.from, this.to, this.date);
  final String from, to; // airport codes
  final DateTime date;
}

/// Multi-city: each leg is searched as its own one-way trip (as on the
/// portal). The agent picks one flight per leg; the tabs show progress and
/// the footer totals the picks.
class MultiCityResultsScreen extends StatefulWidget {
  const MultiCityResultsScreen({
    required this.legs,
    required this.party,
    super.key,
  });

  final List<SearchLeg> legs;
  final TravellerParty party;

  @override
  State<MultiCityResultsScreen> createState() => _MultiCityResultsScreenState();
}

class _MultiCityResultsScreenState extends State<MultiCityResultsScreen> {
  late final List<List<QuotedFlight>?> _results =
      List.filled(widget.legs.length, null);
  late final List<bool> _failed = List.filled(widget.legs.length, false);
  late final List<QuotedFlight?> _picked = List.filled(widget.legs.length, null);
  late final List<ResultsFilter> _filters =
      List.generate(widget.legs.length, (_) => ResultsFilter());
  int _current = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.legs.length; i++) {
      _load(i);
    }
  }

  Future<void> _load(int i) async {
    setState(() {
      _results[i] = null;
      _failed[i] = false;
    });
    final leg = widget.legs[i];
    try {
      final flights = await FlightSearchService.search(
        from: leg.from,
        to: leg.to,
        departDate: DateFormat('yyyy-MM-dd').format(leg.date),
        party: widget.party,
      );
      if (mounted) setState(() => _results[i] = flights);
    } on SearchFailure {
      if (mounted) setState(() => _failed[i] = true);
    }
  }

  void _pick(QuotedFlight q) {
    setState(() {
      _picked[_current] = q;
      final next = _picked.indexWhere((p) => p == null);
      if (next != -1) _current = next;
    });
  }

  bool get _complete => _picked.every((p) => p != null);

  double get _total => _picked.fold(0, (a, p) => a + (p?.total ?? 0));

  void _continue() {
    Get.to(() => PassengerDetailsScreen(
          trip: BookingTrip(
            selections: _picked.cast<QuotedFlight>(),
            party: widget.party,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      appBar: CustomAppBar(title: 'booking.multiCity'.tr),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.appColorWhite,
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: widget.legs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _legTab(i),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
      bottomNavigationBar: _footer(),
    );
  }

  Widget _legTab(int i) {
    final leg = widget.legs[i];
    final active = i == _current;
    final done = _picked[i] != null;
    return Material(
      color: active ? AppColors.appColorLightTextColor : AppColors.appColorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: active ? AppColors.appColorPrimary : const Color(0xFFB9C2D4),
          width: active ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _current = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.green : AppColors.appColorPrimary,
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : CommonText(
                        text: '${i + 1}',
                        fontSize: 10.5,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: '${leg.from} → ${leg.to}',
                    fontSize: 13.0,
                    weight: FontWeight.w700,
                    color: AppColors.appColorTextBlack,
                  ),
                  CommonText(
                    text: DateFormat('EEE, dd MMM').format(leg.date),
                    fontSize: 10.5,
                    color: AppColors.appColorTextDarkGray,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final i = _current;
    if (_failed[i]) return ResultsError(onRetry: () => _load(i));
    final flights = _results[i];
    if (flights == null) return const ResultsLoading();
    if (flights.isEmpty) return const ResultsEmpty();
    return FlightResultsList(
      key: ValueKey(i),
      flights: flights,
      filter: _filters[i],
      selected: _picked[i],
      onChanged: () => setState(() {}),
      onSelect: _pick,
    );
  }

  Widget _footer() {
    final count = _picked.where((p) => p != null).length;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.appColorWhite,
        border: Border(top: BorderSide(color: AppColors.appColorSperator)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: 'multi.selectedOf'.trParams({
                        'count': '$count',
                        'total': '${widget.legs.length}',
                      }),
                      fontSize: 11.0,
                      color: AppColors.appColorTextDarkGray,
                    ),
                    CommonText(
                      text: ResultCard.money(_total),
                      fontSize: 20.0,
                      weight: FontWeight.w700,
                      color: AppColors.appColorTextBlack,
                      lineHeight: 1.1,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _complete ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text('multi.continue'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
