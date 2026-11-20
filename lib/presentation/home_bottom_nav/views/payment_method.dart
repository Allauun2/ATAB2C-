import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/utils/custom_widgets/flight_leg.dart';

import '../../../app/utils/custom_widgets/common_text.dart';
import '../../../app/utils/custom_widgets/custom_appbar.dart';
import '../controller/flight_booking_controller.dart';
import '../model/booking_trip.dart';
import 'passenger_details.dart';

/// Final step: the customer pays with EVC Plus. The API puts the fare on hold
/// on that number (the phone asks for the PIN), issues the ticket and only then
/// takes the money — so the request stays open while the customer approves.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    required this.trip,
    required this.passengers,
    super.key,
  });

  final BookingTrip trip;
  final List<Map<String, dynamic>> passengers;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  /// PaymentGatewayEnum.WaafiPay on the API — the only method for customers.
  static const _evcPaymentTypeId = 3;
  static final _evcPattern = RegExp(r'^6\d{8}$');

  final FlightBookingController flightBookingController =
      Get.put(FlightBookingController());
  final _formKey = GlobalKey<FormState>();
  final _evc = TextEditingController();

  static String _money(num v) => NumberFormat('#,##0.00').format(v);

  @override
  void dispose() {
    _evc.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final phone = _evc.text.trim();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('payment.confirmTitle'.tr),
        content: Text('payment.confirmBody'.trParams({
          'amount': '\$${_money(widget.trip.total)}',
          'count': '${widget.passengers.length}',
          'phone': '+252 $phone',
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('payment.confirm'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await flightBookingController.book(
      trip: widget.trip,
      paymentTypeId: _evcPaymentTypeId,
      passengers: widget.passengers,
      evcNumber: '252$phone',
    );
    // A changed fare updates trip.total; redraw so the new amount shows.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final booking = flightBookingController.isLoading.value;
      return PopScope(
        canPop: !booking,
        child: Scaffold(
          backgroundColor: AppColors.appColorAccent,
          appBar: CustomAppBar(title: 'payment.title'.tr),
          body: booking
              ? _waiting()
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      const FunnelSteps(current: 2),
                      const SizedBox(height: 14),
                      _evcCard(),
                      const SizedBox(height: 16),
                      TripSummaryCard(trip: widget.trip),
                    ],
                  ),
                ),
          bottomNavigationBar: booking
              ? null
              : FareBar(
                  trip: widget.trip,
                  buttonLabel: 'payment.confirm'.tr,
                  onPressed: _confirm,
                ),
        ),
      );
    });
  }

  Widget _evcCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.appColorSperator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.appColorLightTextColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_iphone_rounded,
                    color: AppColors.appColorPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonText(
                  text: 'payment.method'.tr,
                  fontSize: 15.0,
                  weight: FontWeight.w700,
                  color: AppColors.appColorPrimaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CommonText(
            text: 'payment.evcHint'.tr,
            fontSize: 12.5,
            color: AppColors.appColorTextDarkGray,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _evc,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: InputDecoration(
              labelText: 'payment.evcNumber'.tr,
              hintText: 'register.phoneHint'.tr,
              prefixText: '+252 ',
              errorMaxLines: 2,
            ),
            validator: (v) => _evcPattern.hasMatch(v?.trim() ?? '')
                ? null
                : 'payment.invalidEvc'.tr,
            onFieldSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 16, color: AppColors.green),
              const SizedBox(width: 6),
              Expanded(
                child: CommonText(
                  text: 'payment.notChargedNote'.tr,
                  fontSize: 11.5,
                  color: AppColors.appColorTextDarkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shown while the API waits for the customer to approve on their phone.
  Widget _waiting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phonelink_ring_rounded,
                size: 56, color: AppColors.appColorPrimary),
            const SizedBox(height: 18),
            CommonText(
              text: 'payment.waiting'.tr,
              fontSize: 18.0,
              weight: FontWeight.w700,
              color: AppColors.appColorPrimaryDark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            CommonText(
              text: 'payment.waitingHint'.tr,
              fontSize: 13.5,
              color: AppColors.appColorTextDarkGray,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
