import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../app/configs/app_colors.dart';
import '../../../app/data/data_controller.dart';
import '../../../app/utils/api_utility/api_url.dart';
import '../../../app/utils/custom_widgets/gradient_snackbar.dart';
import '../model/booking_trip.dart';
import '../views/booking_details.dart';
import 'flight_search_service.dart';

class FlightBookingController extends GetxController {
  final DataController dataController = Get.put(DataController());
  var isLoading = false.obs;

  /// `passengers` are already in the API shape (see PassengerDetailsScreen).
  /// Returns false without booking if the fare changed since it was shown,
  /// so the customer can confirm the new total.
  /// [evcNumber] (252 + nine digits) is the EVC Plus wallet the API charges.
  Future<bool> book({
    required BookingTrip trip,
    required int paymentTypeId,
    required List<Map<String, dynamic>> passengers,
    String? evcNumber,
  }) async {
    isLoading.value = true;
    try {
      if (dataController.myToken.value.isEmpty) {
        await dataController.loadMyData();
      }
      // The fare-rules call creates the price record addBooking looks up;
      // without it the API answers "Invalid Price Pnr ID".
      final shown = trip.total;
      try {
        await FlightSearchService.priceTrip(trip);
      } on SearchFailure {
        Get.showSnackbar(gradientSnackbar('common.failure'.tr,
            'passenger.priceFailed'.tr, AppColors.red, Icons.warning_rounded));
        return false;
      }
      if ((trip.total - shown).abs() > 0.005) {
        Get.showSnackbar(gradientSnackbar(
            'payment.priceChangedTitle'.tr,
            'payment.priceChanged'
                .trParams({'amount': '\$${trip.total.toStringAsFixed(2)}'}),
            AppColors.orange,
            Icons.info_outline_rounded));
        return false;
      }

      final response = await http.post(
        Uri.parse('${baseURL}api/FlightBooking/addBooking'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer ${dataController.myToken.value}',
        },
        body: json.encode({
          'flightSelection': trip.flightSelection,
          'paymentTypeId': paymentTypeId,
          'microSiteClientId': 2,
          'passengers': passengers,
          if (evcNumber != null) 'paymentParams': {'phoneNumber': evcNumber},
        }),
      );

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (_) {}

      if (response.statusCode == 200 && data is Map) {
        Get.offAll(() => BookingDetailsScreen(
              parentPNR: '${data['parentPnr']}',
              status: '${data['status']}',
            ));
        return true;
      } else {
        final message = data is Map
            ? (data['error'] ?? data['title'] ?? data['message'])
            : null;
        // A dialog, not a snackbar: the customer has just been waiting on
        // their phone and must not miss why the payment or ticket failed.
        Get.dialog(AlertDialog(
          icon: const Icon(Icons.error_outline_rounded,
              size: 40, color: AppColors.red),
          title: Text('common.failure'.tr),
          content: Text('${message ?? 'common.error'.tr}'),
          actions: [
            TextButton(onPressed: Get.back, child: Text('common.ok'.tr)),
          ],
        ));
      }
      return false;
    } catch (_) {
      Get.showSnackbar(gradientSnackbar(
        'common.failure'.tr,
        'common.error'.tr,
        AppColors.orange,
        Icons.warning_rounded,
      ));
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
