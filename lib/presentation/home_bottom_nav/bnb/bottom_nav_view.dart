// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/configs/app_size_config.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/app/utils/custom_widgets/custom_appbar.dart';
import 'package:travel_app/presentation/home_bottom_nav/nav_tabs/search_view.dart';
import 'package:travel_app/presentation/booking_history/view/my_bookings_screen.dart';
import 'package:travel_app/presentation/profile/view/user_profile_screen.dart';

import '../../../app/data/data_controller.dart';
import '../../../app/localization/language_service.dart';
import '../../../app/utils/auth_session.dart';
import '../../../app/utils/session_validator.dart';
import '../../auth/view/login_screen.dart';

class BottomNavScreen extends StatefulWidget {
  BottomNavScreen({this.fromDetails = false, super.key, this.cabinClass});
  final bool? fromDetails;
  final String? cabinClass;

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final DataController dataController = Get.put(DataController());
  var tabsList = [];

  /// Customers have no subscription gate (that is for agencies), so the tabs
  /// show straight away.
  final bool _gatePassed = true;

  @override
  void initState() {
    setArgs();
    dataController.loadMyData();
    super.initState();
  }

  setArgs() {
    tabsList = [
      SearchScreen(cabinClass: widget.cabinClass),
      const BookingScreen(),
      const UserProfileScreen(),
    ];
    if (widget.fromDetails!) {
      onSelectTab(1); // My Trips
    }
    setState(() {});
  }

  int selectedIndex = 0;

  onSelectTab(int index) {
    setState(() => selectedIndex = index);
  }

  Widget _drawerSection(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
        child: CommonText(
          text: label.toUpperCase(),
          fontSize: 11.0,
          weight: FontWeight.w700,
          color: AppColors.appColorTextLightGray,
          letterSpacing: 0.8,
        ),
      );

  /// One drawer row: icon in a tinted tile, label, and a trailing widget
  /// (chevron by default). [color] other than ink marks a destructive row.
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    Widget? trailing,
    Color color = AppColors.appColorTextBlack,
  }) {
    final danger = color != AppColors.appColorTextBlack;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.appColorLightTextColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.appColorPrimary
                        : danger
                            ? color.withOpacity(0.1)
                            : AppColors.appColorLightTextColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,
                      size: 19,
                      color: selected
                          ? AppColors.appColorWhite
                          : danger
                              ? color
                              : AppColors.appColorPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: CommonText(
                    text: label,
                    fontSize: 14.5,
                    weight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? AppColors.appColorPrimary : color,
                  ),
                ),
                trailing ??
                    (danger
                        ? const SizedBox.shrink()
                        : const Icon(Icons.chevron_right_rounded,
                            size: 20, color: AppColors.appColorTextLightGray)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _initials {
    final words = dataController.myName.value
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return (words.first[0] + (words.length > 1 ? words.last[0] : ''))
        .toUpperCase();
  }

  var tabsLables = [
    'nav.search',
    'nav.myBookings',
    'nav.myProfile',
  ];

  // (unselected, selected): outlined glyphs fill in when their tab is active.
  static const tabsIcons = [
    (Icons.flight_outlined, Icons.flight_rounded),
    (Icons.confirmation_number_outlined, Icons.confirmation_number_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appColorWhite,
        border: const Border(
            top: BorderSide(color: AppColors.appColorSperator)),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColorPrimaryDark.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 66,
          backgroundColor: AppColors.appColorWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.appColorLightTextColor,
          indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? const IconThemeData(
                      size: 24, color: AppColors.appColorPrimary)
                  : const IconThemeData(
                      size: 24, color: AppColors.appColorTextLightGray)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appColorPrimary)
                  : const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.appColorTextDarkGray)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          animationDuration: const Duration(milliseconds: 350),
          onDestinationSelected: (index) {
            if (index != selectedIndex) HapticFeedback.selectionClick();
            onSelectTab(index);
          },
          destinations: [
            for (var i = 0; i < tabsIcons.length; i++)
              NavigationDestination(
                icon: Icon(tabsIcons[i].$1),
                selectedIcon: Icon(tabsIcons[i].$2),
                label: tabsLables[i].tr,
                tooltip: tabsLables[i].tr,
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> appDrawerData = [
    // {'Icon': Icons.home, 'Name': 'Home'},
    {'Icon': Icons.local_airport_rounded, 'Name': 'nav.bookFlight'},
    {'Icon': Icons.today_rounded, 'Name': 'nav.myBookings'},
    // {'Icon': Icons.location_on_rounded, 'Name': 'Check-Ins'},
    {'Icon': Icons.account_circle_rounded, 'Name': 'nav.myProfile'},
    // {'Icon': Icons.settings, 'Name': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    HeightWidth(context);
    return WillPopScope(
      onWillPop: () async {
        // await showDialog or Show add banners or whatever
        // return true if the route to be popped
        return false; // return false if you want to disable device back button click
      },
      child: Scaffold(
        backgroundColor: AppColors.appColorPrimaryDark,
        appBar: CustomAppBar(title: tabsLables[selectedIndex].tr),

        // --------------------------------
        // No menu until the subscription check passes: it opens top up and
        // company profile, which are part of the gated portal.
        drawer: !_gatePassed
            ? null
            : GetBuilder<DataController>(builder: (controller) {
          return dataController.myLoggedIn.value
              ? Drawer(
                  width: 300,
                  backgroundColor: AppColors.appColorWhite,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Navy identity header
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0B1B3F), Color(0xFF16306B)],
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                            20, MediaQuery.of(context).padding.top + 18, 20, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/1003.png', height: 26),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.appColorWhite
                                        .withOpacity(0.12),
                                    border: Border.all(
                                        color: AppColors.appColorSecondary,
                                        width: 2),
                                  ),
                                  child: CommonText(
                                    text: _initials,
                                    fontSize: 17.0,
                                    weight: FontWeight.w700,
                                    color: AppColors.appColorWhite,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        text: 'nav.hello'.tr,
                                        fontSize: 12.5,
                                        color: AppColors.appColorWhite
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(height: 1),
                                      CommonText(
                                        text: dataController.myName.value,
                                        fontSize: 17.0,
                                        weight: FontWeight.w700,
                                        color: AppColors.appColorWhite,
                                        maxLines: 1,
                                        overFlow: TextOverflow.ellipsis,
                                      ),
                                      if (dataController
                                          .myUsername.value.isNotEmpty)
                                        CommonText(
                                          text:
                                              "@${dataController.myUsername.value}",
                                          fontSize: 12.5,
                                          color: AppColors.appColorWhite
                                              .withOpacity(0.7),
                                          maxLines: 1,
                                          overFlow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 8),
                          children: [
                            _drawerSection('nav.sectionMenu'.tr),
                            ...List.generate(appDrawerData.length, (i) {
                              var item = appDrawerData[i];
                              return _drawerItem(
                                icon: item['Icon'],
                                label: item['Name'].toString().tr,
                                selected: selectedIndex == i,
                                onTap: () {
                                  if (i < tabsList.length) onSelectTab(i);
                                  Get.back();
                                },
                              );
                            }),
                            _drawerSection('nav.sectionSettings'.tr),
                            // Language switcher (portal parity): English <-> Somali
                            _drawerItem(
                              icon: Icons.translate_rounded,
                              label: "nav.language".tr,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.appColorWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFB9C2D4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CommonText(
                                      text: LanguageService.isSomali
                                          ? "Soomaali"
                                          : "English",
                                      fontSize: 12.0,
                                      weight: FontWeight.w700,
                                      color: AppColors.appColorPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.swap_horiz_rounded,
                                        size: 15,
                                        color: AppColors.appColorPrimary),
                                  ],
                                ),
                              ),
                              onTap: () async => LanguageService.toggle(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: AppColors.appColorSperator)),
                        ),
                        padding: const EdgeInsets.only(top: 6),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: _drawerItem(
                                  icon: Icons.logout_rounded,
                                  label: "nav.logout".tr,
                                  color: AppColors.red,
                                  onTap: () async {
                                    SessionValidator.stop();
                                    await AuthSession.clear();
                                    Get.offAll(() => LoginScreen());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 22),
                                // The installed version, so the label never
                                // needs a manual bump per release.
                                child: FutureBuilder<PackageInfo>(
                                  future: PackageInfo.fromPlatform(),
                                  builder: (_, info) => CommonText(
                                    text:
                                        "${'nav.version'.tr} ${info.data?.version ?? ''}",
                                    fontSize: 11.5,
                                    color: AppColors.appColorTextLightGray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              : Drawer(
                  backgroundColor: AppColors.appColorWhite,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        CommonText(
                          text: 'Hello Guest',
                          fontSize: 20.0,
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        ListTile(
                          dense: true,
                          onTap: () async {
                            Get.offAll(() => LoginScreen());
                          },
                          leading: const Icon(
                            Icons.login_rounded,
                          ),
                          title: CommonText(text: "Login"),
                        ),
                        const Spacer(),
                        // App version at the bottom for guest users
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Center(
                            child: CommonText(
                              text: "Version 1.0.0",
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        }),

        // --------------------------------
        body: _gatePassed
            ? tabsList[selectedIndex]
            : const ColoredBox(
                color: AppColors.appColorAccent,
                child: Center(child: CircularProgressIndicator()),
              ),
        // --------------------------------
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }
}
