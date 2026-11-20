// ignore_for_file: must_be_immutable, camel_case_types

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/configs/app_size_config.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/app/utils/custom_widgets/custom_button.dart';
import 'package:travel_app/presentation/booking_history/controller/void_ticket_controller.dart';
import 'package:travel_app/presentation/booking_history/view/search_PNR_screen.dart';

import '../../../app/data/data_controller.dart';
import '../../../app/utils/custom_widgets/gradient_snackbar.dart';
import '../../auth/view/login_screen.dart';
import '../controller/booking_history_controller.dart';
import '../controller/share_ticket_controller.dart';
import '../model/booking_history_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final DataController dataController = Get.put(DataController());
  final BookingHistoryController bookingHistoryController =
      Get.put(BookingHistoryController());
  final Rx<BookingHistoryModel> bookingHistoryModel = BookingHistoryModel().obs;
  final RxList<BookingHistoryModel> bookingHistoryList =
      <BookingHistoryModel>[].obs;
  final RxBool isLoading = false.obs;
  String? formattedDate = "";
  String? formattedTime = "";

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

    return formattedDate;
  }

  String formatTime(String dateTimeString) {
    // Parse the input date and time string
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Format the time
    String formattedTime =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bookingHistoryController.fetchBookings();
      dataController.loadMyData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HeightWidth(context);
    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      body: dataController.myLoggedIn.value
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SearchBar(tripType: '', bookingId: ''),
                ),
                Expanded(
                  child: Obx(() {
                    if (bookingHistoryController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = bookingHistoryController.bookingHistoryList;
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final booking = list[index];
                        return BookingCard(
                          booking: booking,
                          onShare: () => _showSheet(
                              context, BottomSheetWidget(pnr: "${booking.parentPnr}")),
                          // Voiding refunds to an agency balance; customers
                          // ask support instead.
                          onVoid: null,
                        );
                      },
                    );
                  }),
                ),
              ],
            )
          : Padding(
              padding: EdgeInsets.all(20),
              child: GotoLoginWidget(),
            ),
    );
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: child,
        ),
      ),
    );
  }
}

/// Boarding-pass style booking card on portal tokens: airline + status up top,
/// the route with times, a notched ticket divider, then reference / PNR /
/// total with the actions. The fare breakdown is tucked behind a chevron so
/// the list stays scannable.
class BookingCard extends StatefulWidget {
  const BookingCard({
    required this.booking,
    required this.onShare,
    this.onVoid,
    super.key,
  });

  final BookingHistoryModel booking;
  final VoidCallback onShare;
  final VoidCallback? onVoid;

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _expanded = false;

  static String _time(String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    return d == null ? '--:--' : DateFormat('HH:mm').format(d);
  }

  static String _date(String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    return d == null ? '-' : DateFormat('EEE, dd MMM yyyy').format(d);
  }

  static String _money(dynamic v) =>
      '\$${NumberFormat('#,##0.00').format(double.tryParse('$v') ?? 0)}';

  static Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'confirmed':
        return AppColors.green;
      case 'pending':
        return AppColors.orange;
      case 'void':
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.appColorTextDarkGray;
    }
  }

  static String _tripType(String? t) {
    switch ((t ?? '').toLowerCase().replaceAll(' ', '')) {
      case 'oneway':
        return 'booking.oneWay'.tr;
      case 'return':
      case 'roundtrip':
        return 'booking.roundTrip'.tr;
      case 'multicity':
        return 'booking.multiCity'.tr;
      default:
        return t ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final statusColor = _statusColor(b.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.appColorSperator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Airline + status -------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded,
                    size: 16, color: AppColors.appColorPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: CommonText(
                    text: b.airlineName ?? '-',
                    fontSize: 12.5,
                    weight: FontWeight.w600,
                    color: AppColors.appColorTextDarkGray,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: statusColor),
                      ),
                      const SizedBox(width: 5),
                      CommonText(
                        text: b.status ?? '-',
                        fontSize: 10.5,
                        weight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Route ------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Endpoint(
                      time: _time(b.departureDateTime),
                      code: b.departure ?? '-',
                      end: false,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 1,
                                        color: AppColors.appColorSperator)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(FontAwesomeIcons.plane,
                                      size: 13,
                                      color: AppColors.appColorPrimary),
                                ),
                                Expanded(
                                    child: Container(
                                        height: 1,
                                        color: AppColors.appColorSperator)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            CommonText(
                              text: _tripType(b.tripType),
                              fontSize: 10.5,
                              color: AppColors.appColorTextLightGray,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _Endpoint(
                      time: _time(b.arrivalDateTime),
                      code: b.arrival ?? '-',
                      end: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CommonText(
                  text: _date(b.departureDateTime),
                  fontSize: 11.5,
                  color: AppColors.appColorTextDarkGray,
                ),
              ],
            ),
          ),

          const _TicketDivider(),

          // Reference / PNR / total -----------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _Fact(
                      label: 'booking.reference'.tr,
                      value: b.bookingReference ?? '-'),
                ),
                Expanded(
                  child: _Fact(label: 'PNR', value: b.parentPnr ?? '-'),
                ),
                _Fact(
                  label: 'booking.total'.tr,
                  value: _money(b.totalAmount),
                  end: true,
                  strong: true,
                ),
              ],
            ),
          ),

          // Actions ----------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 4, 2),
            child: Row(
              children: [
                _Action(
                  icon: Icons.ios_share_rounded,
                  label: 'booking.share'.tr,
                  onTap: widget.onShare,
                ),
                if (widget.onVoid != null)
                  _Action(
                    icon: Icons.block_rounded,
                    label: 'booking.voidTicket'.tr,
                    color: AppColors.red,
                    onTap: widget.onVoid!,
                  ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  color: AppColors.appColorTextDarkGray,
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ),
              ],
            ),
          ),

          // Fare breakdown (on demand) ---------------------------------------
          if (_expanded)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.appColorAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Customers see what they paid: fare = total − taxes. The
                  // agency's net cost (ticketAmount) and markup stay internal.
                  _FareRow(
                      'booking.fare'.tr,
                      _money((num.tryParse('${b.totalAmount}') ?? 0) -
                          (num.tryParse('${b.taxAmount}') ?? 0))),
                  _FareRow('booking.taxesAndFees'.tr, _money(b.taxAmount)),
                  const Divider(height: 14, color: AppColors.appColorSperator),
                  _FareRow('booking.total'.tr, _money(b.totalAmount),
                      strong: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.time, required this.code, required this.end});
  final String time, code;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        CommonText(
          text: time,
          fontSize: 20.0,
          weight: FontWeight.w700,
          color: AppColors.appColorTextBlack,
          lineHeight: 1.1,
        ),
        const SizedBox(height: 2),
        CommonText(
          text: code,
          fontSize: 13.0,
          weight: FontWeight.w600,
          color: AppColors.appColorTextDarkGray,
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.end = false,
    this.strong = false,
  });
  final String label, value;
  final bool end, strong;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        CommonText(
          text: label,
          fontSize: 10.5,
          color: AppColors.appColorTextLightGray,
        ),
        const SizedBox(height: 2),
        CommonText(
          text: value,
          fontSize: strong ? 14.0 : 12.5,
          weight: strong ? FontWeight.w700 : FontWeight.w600,
          color: AppColors.appColorTextBlack,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.appColorPrimary,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow(this.label, this.value, {this.strong = false});
  final String label, value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            text: label,
            fontSize: 12.0,
            weight: strong ? FontWeight.w600 : FontWeight.w400,
            color: strong
                ? AppColors.appColorTextBlack
                : AppColors.appColorTextDarkGray,
          ),
          CommonText(
            text: value,
            fontSize: 12.0,
            weight: strong ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.appColorTextBlack,
          ),
        ],
      ),
    );
  }
}

/// Dashed rule with the two side notches that make the card read as a ticket.
class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final n = (c.maxWidth / 10).floor();
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        n,
                        (_) => Container(
                          width: 6,
                          height: 1,
                          margin: const EdgeInsets.only(right: 4),
                          color: AppColors.appColorSperator,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(left: -10, top: 0, child: _notch()),
          Positioned(right: -10, top: 0, child: _notch()),
        ],
      ),
    );
  }

  Widget _notch() => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.appColorAccent,
          border: Border.all(color: AppColors.appColorSperator),
        ),
      );
}

class GotoLoginWidget extends StatelessWidget {
  const GotoLoginWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // height: 140,
          width: 160,
          child: Image(
            image: AssetImage("assets/icons/logo.png"),
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20),
        CommonText(
          text: "Start Your Journey",
          weight: FontWeight.w500,
          fontSize: 18,
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: CommonText(
              text:
                  'trips.emptyHint'.tr,
              weight: FontWeight.w300,
              textAlign: TextAlign.center,
              fontSize: 15),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(
                height: 40,
                width: 240,
                text: 'Login',
                onPress: () {
                  Get.offAll(() => LoginScreen());
                }),
          ],
        )
      ],
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  String? pnr;
  BottomSheetWidget({super.key, required this.pnr});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  TextEditingController emailController = TextEditingController();
  final ShareTicketController shareTicketController =
      Get.put(ShareTicketController());
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Obx(() {
          if (shareTicketController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CommonText(
                    text: "Share Ticket",
                    weight: FontWeight.w400,
                    fontSize: 18),
                SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: AppColors.appColorPrimary.withOpacity(0.1),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'example@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                    onChanged: (value) {},
                  ),
                ),
                SizedBox(height: 16.0),
                CustomButton(
                    height: 40,
                    width: w,
                    text: 'Share',
                    onPress: () {
                      RegExp emailRegExp =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (emailController.text.trim().isEmpty) {
                        Get.showSnackbar(gradientSnackbar(
                            "Error",
                            "Email field is empty",
                            AppColors.orange,
                            Icons.warning_rounded));
                      } else if (!emailRegExp
                          .hasMatch(emailController.text.trim())) {
                        Get.showSnackbar(gradientSnackbar(
                            "Error",
                            "Please type a valid email",
                            AppColors.orange,
                            Icons.warning_rounded));
                      } else {
                        shareTicketController.shareTicket(
                            widget.pnr.toString(), emailController.text.trim());
                      }
                    })
              ],
            );
          }
        }),
      ),
    );
  }
}

class VoidSheetWidget extends StatefulWidget {
  String? bookingId;
  VoidSheetWidget({
    super.key,
    required this.bookingId,
  });

  @override
  State<VoidSheetWidget> createState() => _VoidSheetWidgetState();
}

class _VoidSheetWidgetState extends State<VoidSheetWidget> {
  TextEditingController emailController = TextEditingController();
  final VoidTicketController voidTicketController =
      Get.put(VoidTicketController());
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Obx(() {
          if (voidTicketController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CommonText(
                    text: "Cancel Ticket",
                    weight: FontWeight.w400,
                    fontSize: 18),
                SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: AppColors.appColorPrimary.withOpacity(0.1),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'This action is irreversible.Are you sure?',
                      prefixIcon: Icon(
                        Icons.dangerous,
                        color: AppColors.appColorDarkRed,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                    onChanged: (value) {},
                  ),
                ),
                SizedBox(height: 16.0),
                CustomButton(
                  height: 40,
                  width: w,
                  text: 'Yes',
                  onPress: () {
                    voidTicketController.voidTicket(
                      widget.bookingId.toString(),
                    );
                  },
                )
              ],
            );
          }
        }),
      ),
    );
  }
}

class FlightSummaryWidget extends StatelessWidget {
  const FlightSummaryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: [10, 8],
      strokeWidth: 1,
      color: AppColors.appColorPrimary,
      child: Container(
        padding: EdgeInsets.fromLTRB(15.0, 15, 15, 30),
        margin: const EdgeInsets.all(20.0),
        // height: h * 0.43,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1st  FROM TO ------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FromToFlightWidget(
                  date: 'Fri 29 Dec 23',
                  time: '19:30',
                  city: 'CAI',
                ),
                Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.plane,
                      color: AppColors.appColorPrimary,
                      size: 20.0,
                    ),
                    0.01.ph,
                    CommonText(
                      text: 'EK06',
                      fontSize: 12.0,
                    )
                  ],
                ),
                FromToFlightWidget(
                  date: 'Sat 29 Dec 23',
                  time: '22:30',
                  city: 'DXB',
                ),
              ],
            ),
            0.04.ph,
            CommonText(
              text: 'Fare Information',
              weight: FontWeight.w600,
            ),
            0.02.ph,
            CommonText(
              text: 'Adult x 01',
              fontSize: 11,
            ),
            0.02.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: 'Fare',
                  fontSize: 11,
                ),
                CommonText(
                  text: '\$ 125',
                  fontSize: 11,
                ),
              ],
            ),
            0.02.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: 'Taxes and Fees',
                  fontSize: 11,
                ),
                CommonText(
                  text: '\$ 2',
                  fontSize: 11,
                ),
              ],
            ),
            0.02.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: 'Extra Baggage',
                  fontSize: 11,
                ),
                CommonText(
                  text: '\$ 20',
                  fontSize: 11,
                ),
              ],
            ),

            0.02.ph,
            Divider(color: Colors.black),

            0.02.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: 'Total Charges',
                  fontSize: 11,
                  weight: FontWeight.w700,
                ),
                CommonText(
                  text: '\$ 147',
                  fontSize: 11,
                  weight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FromToFlightWidget extends StatelessWidget {
  const FromToFlightWidget({
    required this.time,
    required this.date,
    required this.city,
    super.key,
  });

  final String date, time, city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: date, //'Fri 29 Dec 23',
          fontSize: 10.0,
        ),
        0.005.ph,
        CommonText(
          text: time, //'19:30',
          fontSize: 20.0,
          weight: FontWeight.bold,
        ),
        0.005.ph,
        CommonText(
          text: city, //'CAI',
          fontSize: 16.0,
          weight: FontWeight.w600,
        ),
      ],
    );
  }
}

class SearchBar extends StatefulWidget {
  String tripType;
  String bookingId;

  SearchBar({
    super.key,
    required this.tripType,
    required this.bookingId,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.appColorWhite,
        border: Border.all(color: AppColors.appColorSperator),
      ),
      child: TextField(
        onTap: () {
          Get.to(() => SearchPNRScreen());
          // filter the list by "bookings.parentPnr" instead of calling the screen - SearchPNRScreen()
        },
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'booking.searchPnr'.tr,
          prefixIcon:
              const Icon(Icons.search, color: AppColors.appColorTextDarkGray),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {},
      ),
    );
  }
}
