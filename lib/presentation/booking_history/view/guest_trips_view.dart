import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/app/utils/guest.dart';
import 'package:travel_app/presentation/auth/view/login_screen.dart';

import 'search_PNR_screen.dart';

/// My Trips for a guest: the trips booked on this phone, each opened by its
/// PNR, plus a lookup for any other booking and a way to sign in.
class GuestTripsView extends StatelessWidget {
  const GuestTripsView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GuestTrip>>(
      future: Guest.trips(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final trips = snap.data!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            CommonText(
              text: 'trips.guestHint'.tr,
              fontSize: 13.0,
              color: AppColors.appColorTextDarkGray,
            ),
            const SizedBox(height: 14),
            if (trips.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    const Icon(Icons.airplane_ticket_outlined,
                        size: 48, color: AppColors.appColorGrey),
                    const SizedBox(height: 10),
                    CommonText(
                      text: 'booking.noBookings'.tr,
                      fontSize: 14.0,
                      color: AppColors.appColorTextDarkGray,
                    ),
                  ],
                ),
              ),
            for (final t in trips) _TripCard(trip: t),
            const SizedBox(height: 8),
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(() => const SearchPNRScreen()),
                icon: const Icon(Icons.search_rounded, size: 20),
                label: Text('trips.findBooking'.tr),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Get.offAll(() => const LoginScreen()),
              child: Text('guest.signInForTrips'.tr),
            ),
          ],
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final GuestTrip trip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.to(() => SearchPNRScreen(pnr: trip.pnr)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.appColorSperator),
            ),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded,
                    color: AppColors.appColorPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: trip.route,
                        fontSize: 15.0,
                        weight: FontWeight.w700,
                      ),
                      const SizedBox(height: 2),
                      CommonText(
                        text: [trip.date, trip.airline]
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        fontSize: 12.5,
                        color: AppColors.appColorTextDarkGray,
                      ),
                    ],
                  ),
                ),
                CommonText(
                  text: trip.pnr,
                  fontSize: 13.0,
                  weight: FontWeight.w700,
                  color: AppColors.appColorPrimary,
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.appColorTextLightGray),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
