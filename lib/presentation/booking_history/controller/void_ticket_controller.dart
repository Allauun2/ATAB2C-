// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/presentation/booking_history/model/search_PNR_model.dart';
import 'package:travel_app/presentation/booking_history/view/my_bookings_screen.dart';
import '../../../app/configs/app_colors.dart';
import '../../../app/data/data_controller.dart';
import '../../../app/utils/api_utility/api_url.dart';
import '../../../app/utils/custom_widgets/gradient_snackbar.dart';

class VoidTicketController extends GetxController {
  final DataController dataController = Get.put(DataController());
  var isLoading = false.obs;
  var searchPNRModel = SearchPNRModel().obs;

  Future<void> loadGetxData() async {
    await dataController.loadMyData();
  }

  @override
  void onInit() {
    super.onInit();
    loadGetxData();
  }

  Future<void> voidTicket(String Id) async {
    isLoading.value = true;
    try {
      var headers = {
        'Content-Type': 'application/json',
        'authorization': 'Bearer ${dataController.myToken.value}'
      };

      var response = await http.get(
          Uri.parse('${baseURL}api/Cancellation/voidTicket/bookingId/$Id'),
          headers: headers);

      // debugPrint("**** SearchPNR Response ****");
      // debugPrint("PNR Controller: ${response.body}");

      if (response.statusCode == 204) {
        // Get.back();
        Get.to(() => BookingScreen());
        Get.showSnackbar(
          gradientSnackbar(
            "Success",
            "${"Ticket Cancelled"}",
            AppColors.green,
            Icons.check_circle_rounded,
          ),
        );
        isLoading.value = false;
      } else {
        // debugPrint('Error1: ${response.statusCode}');
      }
    } catch (e) {
      // debugPrint('Error2: $e');
      Get.showSnackbar(
        gradientSnackbar(
          "Failure",
          "Something went wrong",
          AppColors.orange,
          Icons.warning_rounded,
        ),
      );
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
