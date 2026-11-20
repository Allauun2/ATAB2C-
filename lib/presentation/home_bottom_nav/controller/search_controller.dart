import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../app/configs/app_colors.dart';
import '../../../app/data/data_controller.dart';
import '../../../app/utils/custom_widgets/gradient_snackbar.dart';
import '../model/search_model.dart';
import '../../../app/utils/api_utility/api_url.dart';

class SearchController1 extends GetxController {
  final DataController dataController = Get.put(DataController());
  RxString mySearch1 = ''.obs;
  RxString mySearch2 = ''.obs;
  var isLoading = false.obs;
  var searchModel = SearchModel().obs;

  Future<void> loadGetxData() async {
    await dataController.loadMyData();
  }

  @override
  void onInit() {
    super.onInit();
    loadGetxData();
  }

  Future<List<Map<String, dynamic>>> fetchSearch1(String search) async {
    mySearch1.value = search;
    isLoading.value = true;
    try {
      var headers = {
        'Content-Type': 'application/json',
        'authorization': 'Bearer ${dataController.myToken.value}'
      };
      var body = json.encode({"search": search});

      var response = await http.post(
        Uri.parse('${baseURL}api/Airport/search'),
        headers: headers,
        body: body,
      );

      // debugPrint("This is my Token1: ${dataController.myToken.value}");
      debugPrint("===========jsonBody1: ${jsonEncode(body)}");
      debugPrint("==============jsonBody1-: ${jsonDecode(body)}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List<dynamic>;
        debugPrint("==============jsonData1: $jsonData");

        // Parse jsonData directly into a list of airports
        searchModel.value = SearchModel.fromJson(jsonData);
        isLoading.value = false;

        // Map the airports to a list of maps containing city and code
        return searchModel.value.airports
                ?.map((airport) => {
                      "name": airport.city,
                      "value": airport.code,
                    })
                .toList() ??
            [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error: $e");
      isLoading.value = false;

      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSearch2(String search) async {
    mySearch2.value = search;
    isLoading.value = true;
    try {
      var headers = {
        'Content-Type': 'application/json',
        'authorization': 'Bearer ${dataController.myToken.value}'
      };
      var body = json.encode({"search": search});

      var response = await http.post(
        Uri.parse('${baseURL}api/Airport/search'),
        headers: headers,
        body: body,
      );

      // debugPrint("This is my Token1: ${dataController.myToken.value}");
      debugPrint("===========jsonBody2: ${jsonEncode(body)}");
      debugPrint("==============jsonBody2: ${jsonDecode(body)}");

      List<dynamic> jsonData = [];
      
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body) as List<dynamic>;
        debugPrint("==============jsonData2: $jsonData");

        // Parse jsonData directly into a list of airports
        searchModel.value = SearchModel.fromJson(jsonData);
        isLoading.value = false;

        // Map the airports to a list of maps containing city and code
        return searchModel.value.airports
                ?.map(
                  (airport) => {
                    "name": airport.city,
                    "value": airport.code,
                  },
                )
                .toList() ??
            [];
      } else {
        Get.showSnackbar(gradientSnackbar("Failure", "Something went wrong",
            AppColors.orange, Icons.warning_rounded));
        return [];
      }
    } catch (e) {
      debugPrint("Error: $e");
      Get.showSnackbar(gradientSnackbar("Failure", "Something went wrong",
          AppColors.orange, Icons.warning_rounded));
      isLoading.value = false;

      return [];
    } finally {
      isLoading.value = false;
    }
  }

}
