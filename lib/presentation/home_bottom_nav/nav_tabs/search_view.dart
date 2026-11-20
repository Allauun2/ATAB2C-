// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/configs/app_size_config.dart';
import 'package:travel_app/app/data/providers.dart';
import 'package:travel_app/app/utils/custom_widgets/broadcast_banner.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/app/utils/custom_widgets/gradient_snackbar.dart';
import 'package:travel_app/presentation/home_bottom_nav/nav_tabs/components/search_tabs/cityselection.dart';
import 'package:travel_app/presentation/home_bottom_nav/model/booking_trip.dart';
import 'package:travel_app/presentation/home_bottom_nav/views/flight_results.dart';
import 'package:travel_app/presentation/home_bottom_nav/views/multi_city_results.dart';

/// Flight search form (portal pattern): trip type, route with swap, dates,
/// one "travellers & cabin" picker, and inline validation. Multi-city edits
/// its legs in the same card.
class SearchScreen extends StatefulWidget {
  String? cabinClass;
  SearchScreen({super.key, this.cabinClass});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _Place {
  const _Place(this.code, this.name);
  final String code, name;
  String get label => '$name ($code)';
}

class _Leg {
  _Leg(this.date, {this.from});
  _Place? from, to;
  DateTime date;
}

class _SearchScreenState extends State<SearchScreen> {
  static const _maxPax = 9;
  static const _maxChildren = 4;
  static const _maxInfants = 4;
  static const _maxLegs = 5;

  static const _oneWay = 0, _roundTrip = 1, _multiCity = 2;
  int _tripType = _oneWay;

  _Place? _from, _to;
  late DateTime _depart;
  late DateTime _return;
  late final List<_Leg> _legs;

  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  final List<int> _childAges = [2, 2, 2, 2];
  late String _cabin;
  static const _cabins = ['Economy', 'Business'];

  String? _routeError;
  String? _paxError;
  final Map<int, String> _legErrors = {};

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _depart = DateTime(today.year, today.month, today.day + 1);
    _return = _depart.add(const Duration(days: 1));
    _legs = [_Leg(_depart), _Leg(_depart.add(const Duration(days: 2)))];
    _cabin = _cabins.contains(widget.cabinClass) ? widget.cabinClass! : 'Economy';
  }

  // ------------------------------------------------------------- helpers

  // Short form so two tiles fit side by side; the picker shows the full date.
  String _display(DateTime d) => DateFormat('EEE, dd MMM').format(d);
  String _displayLong(DateTime d) => DateFormat('EEE, dd MMM yyyy').format(d);

  String _travellersLine() {
    final parts = <String>[
      "$_adults ${'booking.adults'.tr}",
      if (_children > 0) "$_children ${'booking.children'.tr}",
      if (_infants > 0) "$_infants ${'booking.infants'.tr}",
    ];
    return "${parts.join(' · ')} · ${_cabin == 'Business' ? 'booking.business'.tr : 'booking.economy'.tr}";
  }

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<DateTime?> _pickDate(DateTime initial, DateTime first) {
    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: _today.add(const Duration(days: 365)),
    );
  }

  Future<void> _pickDepart() async {
    final picked = await _pickDate(_depart, _today);
    if (picked == null) return;
    setState(() {
      _depart = picked;
      if (!_return.isAfter(_depart)) {
        _return = _depart.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickReturn() async {
    final picked = await _pickDate(_return, _depart);
    if (picked != null) setState(() => _return = picked);
  }

  /// A leg can't depart before the previous one; later legs move forward
  /// when an earlier one is moved past them.
  Future<void> _pickLegDate(int i) async {
    final first = i == 0 ? _today : _legs[i - 1].date;
    final picked = await _pickDate(_legs[i].date, first);
    if (picked == null) return;
    setState(() {
      _legs[i].date = picked;
      for (var j = i + 1; j < _legs.length; j++) {
        if (_legs[j].date.isBefore(_legs[j - 1].date)) {
          _legs[j].date = _legs[j - 1].date;
        }
      }
    });
  }

  void _openCity(ValueChanged<_Place> onPicked) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CitySelectionModal(
        onCitySelected: (selected) {
          final parts = selected.split(',');
          final code = parts[0].trim();
          final name = parts.length > 1 ? parts[1].trim() : code;
          setState(() {
            onPicked(_Place(code, name));
            _routeError = null;
            _legErrors.clear();
          });
          _addRecentCity(name, code);
        },
        fromController: TextEditingController(),
        toController: TextEditingController(),
      ),
    );
  }

  void _setTripType(int t) {
    setState(() {
      if (t == _multiCity && _tripType != _multiCity) {
        // Carry the route typed so far into the first leg.
        _legs[0]
          ..from = _from ?? _legs[0].from
          ..to = _to ?? _legs[0].to
          ..date = _depart;
        _legs[1].from ??= _legs[0].to;
        if (_legs[1].date.isBefore(_depart)) {
          _legs[1].date = _depart.add(const Duration(days: 2));
        }
      }
      _tripType = t;
      _routeError = null;
      _legErrors.clear();
    });
  }

  void _addLeg() {
    final last = _legs.last;
    setState(() => _legs.add(_Leg(last.date.add(const Duration(days: 2)),
        from: last.to)));
  }

  void _removeLeg(int i) => setState(() {
        _legs.removeAt(i);
        _legErrors.clear();
      });

  /// Recent searches feed the "Popular Destinations" group of the city picker.
  Future<void> _addRecentCity(String cityName, String cityCode) async {
    final prefs = await SharedPreferences.getInstance();
    final recentList = GetProviders.cityData[0]['value'] as List<dynamic>;
    recentList.removeWhere((city) => city['name'] == cityName);
    recentList.insert(0, {'name': cityName, 'code': cityCode});
    if (recentList.length > 5) recentList.removeLast();
    await prefs.setStringList(
      'recentCities',
      recentList
          .map((c) => jsonEncode({'name': c['name'], 'code': c['code']}))
          .toList(),
    );
    GetProviders.cityData[0]['value'] = recentList;
  }

  // ----------------------------------------------------------- travellers

  void _openTravellers() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void update(VoidCallback fn) {
            setSheet(fn);
            setState(() => _paxError = null);
          }

          final total = _adults + _children + _infants;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: 'search.travellers'.tr,
                  fontSize: 16.0,
                  weight: FontWeight.w700,
                  color: AppColors.appColorTextBlack,
                ),
                const SizedBox(height: 12),
                _StepperRow(
                  label: 'booking.adults'.tr,
                  hint: 'search.adultsHint'.tr,
                  value: _adults,
                  min: 1,
                  max: _maxPax - _children - _infants,
                  onChanged: (v) => update(() {
                    _adults = v;
                    if (_infants > _adults) _infants = _adults;
                  }),
                ),
                _StepperRow(
                  label: 'booking.children'.tr,
                  hint: 'search.childrenHint'.tr,
                  value: _children,
                  min: 0,
                  max: [_maxChildren, _maxPax - _adults - _infants]
                      .reduce((a, b) => a < b ? a : b),
                  onChanged: (v) => update(() => _children = v),
                ),
                _StepperRow(
                  label: 'booking.infants'.tr,
                  hint: 'search.infantsHint'.tr,
                  value: _infants,
                  min: 0,
                  max: [_maxInfants, _adults, _maxPax - _adults - _children]
                      .reduce((a, b) => a < b ? a : b),
                  onChanged: (v) => update(() => _infants = v),
                ),
                if (_children > 0) ...[
                  const SizedBox(height: 6),
                  CommonText(
                    text: 'search.childAges'.tr,
                    fontSize: 12.5,
                    weight: FontWeight.w600,
                    color: AppColors.appColorTextDarkGray,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: List.generate(_children, (i) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB9C2D4)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonText(
                              text: "${'booking.children'.tr} ${i + 1}",
                              fontSize: 12.0,
                              color: AppColors.appColorTextDarkGray,
                            ),
                            const SizedBox(width: 6),
                            DropdownButton<int>(
                              value: _childAges[i],
                              isDense: true,
                              underline: const SizedBox.shrink(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.appColorTextBlack,
                              ),
                              items: List.generate(
                                11, // ages 2–12; adults are 13+ (portal rule)
                                (a) => DropdownMenuItem(
                                    value: a + 2, child: Text('${a + 2}')),
                              ),
                              onChanged: (v) =>
                                  update(() => _childAges[i] = v ?? 2),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),
                CommonText(
                  text: 'booking.cabinClass'.tr,
                  fontSize: 12.5,
                  weight: FontWeight.w600,
                  color: AppColors.appColorTextDarkGray,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _cabins.map((c) {
                    final sel = _cabin == c;
                    return ChoiceChip(
                      label: Text(c == 'Business'
                          ? 'booking.business'.tr
                          : 'booking.economy'.tr),
                      selected: sel,
                      showCheckmark: false,
                      onSelected: (_) => update(() => _cabin = c),
                      backgroundColor: AppColors.appColorWhite,
                      selectedColor: AppColors.appColorLightTextColor,
                      side: BorderSide(
                          color: sel
                              ? AppColors.appColorPrimary
                              : const Color(0xFFB9C2D4)),
                      shape: const StadiumBorder(),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? AppColors.appColorPrimary
                            : AppColors.appColorTextBlack,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: total <= _maxPax ? () => Navigator.pop(ctx) : null,
                    child: Text('search.done'.tr),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------- search

  void _search() {
    String? routeError;
    String? paxError;
    _legErrors.clear();
    if (_tripType == _multiCity) {
      for (var i = 0; i < _legs.length; i++) {
        final l = _legs[i];
        if (l.from == null || l.to == null) {
          _legErrors[i] = 'search.errRoute'.tr;
        } else if (l.from!.code == l.to!.code) {
          _legErrors[i] = 'search.errSameCity'.tr;
        }
      }
      if (_legErrors.isNotEmpty) routeError = _legErrors.values.first;
    } else if (_from == null || _to == null) {
      routeError = 'search.errRoute'.tr;
    } else if (_from!.code == _to!.code) {
      routeError = 'search.errSameCity'.tr;
    }
    if (_infants > _adults) {
      paxError = 'search.errInfants'.tr;
    } else if (_adults + _children + _infants > _maxPax) {
      paxError = 'search.errMaxPax'.tr;
    }
    setState(() {
      _routeError = _tripType == _multiCity ? null : routeError;
      _paxError = paxError;
    });
    final first = routeError ?? paxError;
    if (first != null) {
      Get.showSnackbar(gradientSnackbar(
          'common.checkForm'.tr, first, AppColors.orange, Icons.warning_rounded));
      return;
    }

    final party = TravellerParty(
      adults: _adults,
      children: _children,
      infants: _infants,
      childAges: _childAges.take(_children).toList(),
      cabin: _cabin,
    );
    if (_tripType == _multiCity) {
      Get.to(() => MultiCityResultsScreen(
            legs: [
              for (final l in _legs) SearchLeg(l.from!.code, l.to!.code, l.date)
            ],
            party: party,
          ));
    } else {
      Get.to(() => FlightResultsScreen(
            from: _from!.code,
            to: _to!.code,
            departDate: _depart,
            returnDate: _tripType == _roundTrip ? _return : null,
            party: party,
          ));
    }
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    HeightWidth(context);
    final multi = _tripType == _multiCity;

    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // No BroadcastBanner: broadcasts are ATA's messages to agencies.
          CommonText(
            text: 'search.headline'.tr,
            fontSize: 20.0,
            weight: FontWeight.w700,
            color: AppColors.appColorPrimaryDark,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.appColorWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.appColorSperator),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Segmented(
                  labels: [
                    'booking.oneWay'.tr,
                    'booking.roundTrip'.tr,
                    'booking.multiCity'.tr,
                  ],
                  selected: _tripType,
                  onChanged: _setTripType,
                ),
                const SizedBox(height: 14),

                if (multi) ..._multiCityLegs() else ..._singleRoute(),

                // Travellers & cabin -----------------------------------
                _PickerField(
                  label: 'search.travellersCabin'.tr,
                  value: _travellersLine(),
                  icon: Icons.people_alt_outlined,
                  trailing: Icons.expand_more_rounded,
                  error: _paxError != null,
                  onTap: _openTravellers,
                ),
                if (_paxError != null) _errorText(_paxError!),
                const SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _search,
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: Text('booking.searchFlights'.tr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _singleRoute() {
    final roundTrip = _tripType == _roundTrip;
    return [
      Stack(
        alignment: Alignment.centerRight,
        children: [
          Column(
            children: [
              _PickerField(
                label: 'booking.from'.tr,
                value: _from?.label ?? '',
                placeholder: 'booking.searchCity'.tr,
                icon: Icons.flight_takeoff_rounded,
                error: _routeError != null && _from == null,
                onTap: () => _openCity((p) => _from = p),
              ),
              const SizedBox(height: 8),
              _PickerField(
                label: 'booking.to'.tr,
                value: _to?.label ?? '',
                placeholder: 'booking.searchCity'.tr,
                icon: Icons.flight_land_rounded,
                error: _routeError != null && _to == null,
                onTap: () => _openCity((p) => _to = p),
              ),
            ],
          ),
          Positioned(
            right: 12,
            child: Material(
              color: AppColors.appColorWhite,
              shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFB9C2D4))),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _swap,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.swap_vert_rounded,
                      size: 20, color: AppColors.appColorPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
      if (_routeError != null) _errorText(_routeError!),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _PickerField(
              label: 'booking.departure'.tr,
              value: roundTrip ? _display(_depart) : _displayLong(_depart),
              icon: Icons.calendar_today_outlined,
              onTap: _pickDepart,
            ),
          ),
          if (roundTrip) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _PickerField(
                label: 'booking.return'.tr,
                value: _display(_return),
                icon: Icons.calendar_today_outlined,
                onTap: _pickReturn,
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _multiCityLegs() {
    return [
      for (var i = 0; i < _legs.length; i++) ...[
        _legCard(i),
        const SizedBox(height: 10),
      ],
      if (_legs.length < _maxLegs)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addLeg,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('multi.addFlight'.tr),
          ),
        ),
      const SizedBox(height: 6),
    ];
  }

  Widget _legCard(int i) {
    final leg = _legs[i];
    final error = _legErrors[i];
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.appColorAccent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: error != null ? AppColors.red : AppColors.appColorSperator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CommonText(
                  text: "${'multi.flight'.tr} ${i + 1}",
                  fontSize: 12.5,
                  weight: FontWeight.w700,
                  color: AppColors.appColorPrimaryDark,
                ),
              ),
              if (_legs.length > 2)
                IconButton(
                  tooltip: 'multi.removeFlight'.tr,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _removeLeg(i),
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.appColorTextDarkGray),
                )
              else
                const SizedBox(height: 32),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _PickerField(
                  label: 'booking.from'.tr,
                  value: leg.from?.code ?? '',
                  placeholder: 'booking.from'.tr,
                  icon: Icons.flight_takeoff_rounded,
                  error: error != null && leg.from == null,
                  onTap: () => _openCity((p) => leg.from = p),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PickerField(
                  label: 'booking.to'.tr,
                  value: leg.to?.code ?? '',
                  placeholder: 'booking.to'.tr,
                  icon: Icons.flight_land_rounded,
                  error: error != null && leg.to == null,
                  onTap: () => _openCity((p) {
                    leg.to = p;
                    // The next leg usually starts where this one lands.
                    if (i + 1 < _legs.length) _legs[i + 1].from ??= p;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _PickerField(
            label: 'booking.departure'.tr,
            value: _displayLong(leg.date),
            icon: Icons.calendar_today_outlined,
            onTap: () => _pickLegDate(i),
          ),
          if (error != null) _errorText(error),
        ],
      ),
    );
  }

  Widget _errorText(String text) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 2),
        child: CommonText(text: text, fontSize: 11.5, color: AppColors.red),
      );
}

// ============================================================ building blocks

/// Pill-style segmented control on a canvas track.
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.appColorAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final sel = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? AppColors.appColorWhite : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: CommonText(
                  text: labels[i],
                  textAlign: TextAlign.center,
                  fontSize: 12.5,
                  weight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel
                      ? AppColors.appColorPrimary
                      : AppColors.appColorTextDarkGray,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Read-only "field" that opens a picker: micro-label, leading icon, value.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.placeholder = '',
    this.trailing,
    this.error = false,
  });
  final String label, value, placeholder;
  final IconData icon;
  final IconData? trailing;
  final bool error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty;
    return Material(
      color: AppColors.appColorWhite,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: error ? AppColors.red : const Color(0xFFB9C2D4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.appColorPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: label,
                      fontSize: 10.5,
                      weight: FontWeight.w600,
                      color: AppColors.appColorTextDarkGray,
                    ),
                    const SizedBox(height: 2),
                    CommonText(
                      text: empty ? placeholder : value,
                      fontSize: 14.0,
                      weight: empty ? FontWeight.w400 : FontWeight.w600,
                      color: empty
                          ? AppColors.appColorHint
                          : AppColors.appColorTextBlack,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Icon(trailing, size: 20, color: AppColors.appColorTextDarkGray),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label + hint on the left, a −/＋ stepper on the right.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label, hint;
  final int value, min, max;
  final ValueChanged<int> onChanged;

  Widget _btn(IconData icon, bool enabled, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: BorderSide(
            color: enabled ? AppColors.appColorPrimary : AppColors.appColorSperator),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon,
              size: 18,
              color: enabled
                  ? AppColors.appColorPrimary
                  : AppColors.appColorTextLightGray),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: label,
                  fontSize: 14.0,
                  weight: FontWeight.w600,
                  color: AppColors.appColorTextBlack,
                ),
                CommonText(
                  text: hint,
                  fontSize: 11.5,
                  color: AppColors.appColorTextDarkGray,
                ),
              ],
            ),
          ),
          _btn(Icons.remove_rounded, value > min, () => onChanged(value - 1)),
          SizedBox(
            width: 36,
            child: Center(
              child: CommonText(
                text: '$value',
                fontSize: 15.0,
                weight: FontWeight.w700,
                color: AppColors.appColorTextBlack,
              ),
            ),
          ),
          _btn(Icons.add_rounded, value < max, () => onChanged(value + 1)),
        ],
      ),
    );
  }
}
