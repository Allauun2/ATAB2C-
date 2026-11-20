import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/data/providers.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/presentation/home_bottom_nav/controller/search_controller.dart';

/// City / airport picker sheet: a search box on top; while typing it shows
/// live airport matches from the API plus local city matches, otherwise the
/// recent/popular list and the regional groups.
class CitySelectionModal extends StatefulWidget {
  final Function(String) onCitySelected;
  final TextEditingController fromController;
  final TextEditingController toController;

  const CitySelectionModal({
    super.key,
    required this.onCitySelected,
    required this.fromController,
    required this.toController,
  });

  @override
  State<CitySelectionModal> createState() => _CitySelectionModalState();
}

class _CitySelectionModalState extends State<CitySelectionModal> {
  final SearchController1 searchController = Get.put(SearchController1());
  final TextEditingController cityController = TextEditingController();
  final RxList<dynamic> filteredCities = [].obs;

  static const _popularGroup = 'Popular Destinations';

  @override
  void initState() {
    super.initState();
    searchController.mySearch1.value = '';
    searchController.searchModel.value.airports?.clear();
    _filterCities('');
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    final allCities = GetProviders.cityData;
    if (query.isEmpty) {
      filteredCities.assignAll(allCities);
      return;
    }
    final q = query.toLowerCase();
    filteredCities.assignAll(allCities
        .map((group) => {
              'name': group['name'],
              'value': (group['value'] as List)
                  .where((c) =>
                      c['name'].toString().toLowerCase().contains(q) ||
                      c['code'].toString().toLowerCase().contains(q))
                  .toList(),
            })
        .where((g) => (g['value'] as List).isNotEmpty)
        .toList());
  }

  void _onChanged(String value) {
    final v = value.trim();
    setState(() {});
    _filterCities(v);
    if (v.isEmpty) {
      searchController.mySearch1.value = '';
      searchController.searchModel.value.airports?.clear();
      searchController.searchModel.refresh();
    } else {
      searchController.fetchSearch1(v);
    }
  }

  void _select(String code, String name) {
    widget.onCitySelected("$code,$name");
    Navigator.pop(context);
  }

  Future<void> _clearRecent(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentCities');
    setState(() => GetProviders.cityData[index]['value'].clear());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: cityController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.appColorAccent,
                hintText: 'city.searchHint'.tr,
                hintStyle: const TextStyle(
                    color: AppColors.appColorHint, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.appColorTextDarkGray),
                suffixIcon: cityController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          cityController.clear();
                          _onChanged('');
                        },
                      ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.appColorPrimary, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final airports = searchController.searchModel.value.airports ?? [];
              final showAirports =
                  cityController.text.trim().isNotEmpty && airports.isNotEmpty;
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (showAirports) ...[
                    _header('city.results'.tr),
                    ...airports.map((a) => _tile(
                          icon: Icons.flight_rounded,
                          title: a.city,
                          subtitle: a.name,
                          code: a.code,
                          onTap: () => _select(a.code, a.city),
                        )),
                  ],
                  for (var i = 0; i < filteredCities.length; i++)
                    _group(i, filteredCities[i]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _group(int index, dynamic group) {
    final cities = group['value'] as List;
    final isPopular = group['name'] == _popularGroup;
    final searching = cityController.text.trim().isNotEmpty;
    final tiles = cities
        .map<Widget>((c) => _tile(
              icon: isPopular ? Icons.history_rounded : Icons.location_on_outlined,
              title: c['name'].toString(),
              code: c['code'].toString(),
              onTap: () => _select(c['code'].toString(), c['name'].toString()),
            ))
        .toList();

    if (isPopular || searching) {
      if (cities.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(
            isPopular ? 'city.popular'.tr : group['name'].toString(),
            trailing: isPopular && !searching
                ? TextButton(
                    onPressed: () => _clearRecent(index),
                    child: Text('city.clearRecent'.tr,
                        style: const TextStyle(fontSize: 12)),
                  )
                : null,
          ),
          ...tiles,
        ],
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: CommonText(
          text: group['name'].toString(),
          fontSize: 13.5,
          weight: FontWeight.w600,
          color: AppColors.appColorTextBlack,
        ),
        children: tiles,
      ),
    );
  }

  Widget _header(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              text: text,
              fontSize: 11.5,
              weight: FontWeight.w700,
              color: AppColors.appColorTextDarkGray,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String code,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.appColorTextDarkGray),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: title,
                    fontSize: 14.0,
                    weight: FontWeight.w600,
                    color: AppColors.appColorTextBlack,
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    CommonText(
                      text: subtitle,
                      fontSize: 11.5,
                      color: AppColors.appColorTextDarkGray,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.appColorLightTextColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: CommonText(
                text: code,
                fontSize: 11.5,
                weight: FontWeight.w700,
                color: AppColors.appColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
