import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../configs/app_colors.dart';
import 'common_text.dart';

/// One flight leg the way the portal draws it: big departure/arrival times
/// with airport codes on either side of a plane rule, and up to two lines of
/// context (e.g. "Outbound · HA0101" and the date) underneath the rule.
/// Used by results, flight details, passenger details and booking cards so
/// every screen in the funnel reads the same.
class FlightLegRow extends StatelessWidget {
  const FlightLegRow({
    required this.fromCode,
    required this.fromTime,
    required this.toCode,
    required this.toTime,
    this.caption,
    this.date,
    this.timeSize = 18.0,
    super.key,
  });

  final String fromCode, fromTime, toCode, toTime;
  final String? caption;
  final String? date;
  final double timeSize;

  /// Never show a raw ISO date; the API string is left untouched.
  static String prettyDate(String? raw) {
    final d = DateTime.tryParse(raw ?? '');
    return d == null ? (raw ?? '') : DateFormat('EEE, dd MMM yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _end(fromTime, fromCode, false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 1, color: AppColors.appColorSperator)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(FontAwesomeIcons.plane,
                          size: 12, color: AppColors.appColorPrimary),
                    ),
                    Expanded(
                        child: Container(
                            height: 1, color: AppColors.appColorSperator)),
                  ],
                ),
                if (caption != null && caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CommonText(
                    text: caption!,
                    fontSize: 10.5,
                    color: AppColors.appColorTextLightGray,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                ],
                if (date != null && date!.isNotEmpty)
                  CommonText(
                    text: prettyDate(date),
                    fontSize: 10.5,
                    color: AppColors.appColorTextDarkGray,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        _end(toTime, toCode, true),
      ],
    );
  }

  Widget _end(String time, String code, bool end) => Column(
        crossAxisAlignment:
            end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          CommonText(
            text: time,
            fontSize: timeSize,
            weight: FontWeight.w700,
            color: AppColors.appColorTextBlack,
            lineHeight: 1.1,
          ),
          CommonText(
            text: code,
            fontSize: 12.5,
            weight: FontWeight.w600,
            color: AppColors.appColorTextDarkGray,
          ),
        ],
      );
}

/// Airline logo + name on the left, flight number on the right.
class AirlineHeader extends StatelessWidget {
  const AirlineHeader({
    required this.name,
    required this.flightNumber,
    this.logoUrl,
    super.key,
  });
  final String name, flightNumber;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.appColorAccent,
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: logoUrl == null || logoUrl!.isEmpty
              ? const Icon(Icons.flight_rounded,
                  size: 16, color: AppColors.appColorPrimary)
              : Image.network(
                  logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.flight_rounded,
                      size: 16, color: AppColors.appColorPrimary),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText(
            text: name,
            fontSize: 12.5,
            weight: FontWeight.w600,
            color: AppColors.appColorTextBlack,
            maxLines: 1,
            overFlow: TextOverflow.ellipsis,
          ),
        ),
        CommonText(
          text: flightNumber,
          fontSize: 11.5,
          color: AppColors.appColorTextDarkGray,
        ),
      ],
    );
  }
}

/// Placeholder cards while quotes load from every provider in parallel.
class ResultsLoading extends StatelessWidget {
  const ResultsLoading({super.key});

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.appColorSperator,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: AppColors.appColorSperator,
          color: AppColors.appColorPrimary,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.appColorWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.appColorSperator),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _bar(28, 28),
                    const SizedBox(width: 8),
                    _bar(110, 12),
                  ]),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_bar(56, 20), _bar(90, 8), _bar(56, 20)],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_bar(80, 20), _bar(90, 34)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResultsEmpty extends StatelessWidget {
  const ResultsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.appColorLightTextColor,
              ),
              child: const Icon(Icons.flight_rounded,
                  size: 30, color: AppColors.appColorPrimary),
            ),
            const SizedBox(height: 14),
            CommonText(
              text: 'booking.noFlights'.tr,
              fontSize: 16.0,
              weight: FontWeight.w700,
              color: AppColors.appColorTextBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            CommonText(
              text: 'results.emptyHint'.tr,
              fontSize: 12.5,
              color: AppColors.appColorTextDarkGray,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Results header: count on the left, sort + airline-filter chips on the right.
class ResultsToolbar extends StatelessWidget {
  const ResultsToolbar({
    required this.count,
    required this.onSort,
    required this.onFilter,
    this.filterActive = false,
    super.key,
  });
  final int count;
  final VoidCallback onSort, onFilter;
  final bool filterActive;

  Widget _chip(IconData icon, String label, VoidCallback onTap,
      {bool active = false}) {
    return Material(
      color: active ? AppColors.appColorLightTextColor : AppColors.appColorWhite,
      shape: StadiumBorder(
          side: BorderSide(
              color: active
                  ? AppColors.appColorPrimary
                  : const Color(0xFFB9C2D4))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.appColorPrimary),
              const SizedBox(width: 5),
              CommonText(
                text: label,
                fontSize: 12.0,
                weight: FontWeight.w600,
                color: AppColors.appColorTextBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              text: "$count ${(count == 1 ? 'results.flight' : 'results.flights').tr}",
              fontSize: 12.5,
              weight: FontWeight.w600,
              color: AppColors.appColorTextDarkGray,
            ),
          ),
          _chip(Icons.swap_vert_rounded, 'results.sortBy'.tr, onSort),
          const SizedBox(width: 8),
          _chip(Icons.filter_alt_outlined, 'results.filterBy'.tr, onFilter,
              active: filterActive),
        ],
      ),
    );
  }
}

class ResultsError extends StatelessWidget {
  const ResultsError({required this.onRetry, super.key});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 40, color: AppColors.appColorGrey),
            const SizedBox(height: 12),
            CommonText(
              text: 'results.error'.tr,
              fontSize: 14.0,
              weight: FontWeight.w600,
              color: AppColors.appColorTextBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('results.retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flights → Passengers → Payment progress strip shown across the funnel.
class FunnelSteps extends StatelessWidget {
  const FunnelSteps({required this.current, super.key});
  final int current;

  @override
  Widget build(BuildContext context) {
    final labels = [
      'passenger.stepFlights'.tr,
      'passenger.stepPassengers'.tr,
      'passenger.stepPayment'.tr,
    ];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          _step(i, labels[i]),
          if (i < labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: i < current
                    ? AppColors.appColorPrimary
                    : AppColors.appColorSperator,
              ),
            ),
        ],
      ],
    );
  }

  Widget _step(int i, String label) {
    final done = i < current;
    final active = i == current;
    final color = done || active
        ? AppColors.appColorPrimary
        : AppColors.appColorTextLightGray;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? AppColors.appColorPrimary : Colors.white,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : CommonText(
                  text: '${i + 1}',
                  fontSize: 11.0,
                  weight: FontWeight.w700,
                  color: active ? Colors.white : color,
                ),
        ),
        const SizedBox(width: 6),
        CommonText(
          text: label,
          fontSize: 11.5,
          weight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? AppColors.appColorTextBlack : color,
        ),
      ],
    );
  }
}

/// Search-result card: airline header, one row per leg, price + select.
/// The whole card is tappable.
class ResultCard extends StatelessWidget {
  const ResultCard({
    required this.legs,
    required this.airline,
    required this.flightNumber,
    required this.amount,
    required this.onTap,
    this.logoUrl,
    this.buttonLabel,
    this.selected = false,
    super.key,
  });

  final List<Widget> legs;
  final String airline, flightNumber;
  final String? logoUrl;
  final dynamic amount;
  final VoidCallback onTap;
  final String? buttonLabel;
  final bool selected;

  static String money(dynamic v) =>
      '\$${NumberFormat('#,##0.00').format(double.tryParse('$v') ?? 0)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.appColorPrimary : AppColors.appColorSperator,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AirlineHeader(
                    name: airline, flightNumber: flightNumber, logoUrl: logoUrl),
                const SizedBox(height: 12),
                for (var i = 0; i < legs.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 18, color: AppColors.appColorSperator),
                  legs[i],
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: 'results.from'.tr,
                            fontSize: 10.5,
                            color: AppColors.appColorTextLightGray,
                          ),
                          CommonText(
                            text: money(amount),
                            fontSize: 18.0,
                            weight: FontWeight.w700,
                            color: AppColors.appColorTextBlack,
                            lineHeight: 1.1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: onTap,
                        // The app theme makes buttons full-width; inside a Row
                        // that is an unbounded width.
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected) ...[
                              const Icon(Icons.check_rounded, size: 16),
                              const SizedBox(width: 4),
                            ],
                            Text(buttonLabel ?? 'results.select'.tr),
                            if (!selected) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
