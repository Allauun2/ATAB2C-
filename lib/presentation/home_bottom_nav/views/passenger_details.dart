import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/app/utils/custom_widgets/custom_appbar.dart';
import 'package:travel_app/app/utils/custom_widgets/custom_textfield.dart';
import 'package:travel_app/app/utils/custom_widgets/flight_leg.dart';
import 'package:travel_app/app/utils/custom_widgets/gradient_snackbar.dart';

import '../controller/flight_search_service.dart';
import '../model/booking_trip.dart';
import 'payment_method.dart';

/// Passenger details for any trip (one-way, round trip, multi-city).
/// Builds the booking API's passenger list, matching the agency portal:
/// per-passenger title, document, birth date and nationality; one shared
/// email + phone.
class PassengerDetailsScreen extends StatefulWidget {
  const PassengerDetailsScreen({required this.trip, super.key});
  final BookingTrip trip;

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

enum _Kind { adult, child, infant }

class _Pax {
  _Pax(this.kind, {this.age});
  final _Kind kind;
  final int? age; // children: the age chosen on the search form

  String? title; // MISTER | MISTRESS | MISS
  String docType = 'PASSPORT';
  DateTime? dob;
  DateTime? expiry;
  Country? nationality;
  final first = TextEditingController();
  final last = TextEditingController();
  final docNumber = TextEditingController();
  final dobText = TextEditingController();
  final expiryText = TextEditingController();
  final nationalityText = TextEditingController();

  String get apiType => switch (kind) {
        _Kind.adult => 'Adult',
        _Kind.child => 'Child',
        _Kind.infant => 'Infant',
      };

  void dispose() {
    for (final c in [first, last, docNumber, dobText, expiryText, nationalityText]) {
      c.dispose();
    }
  }
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  static const _titles = {'MISTER': 'Mr', 'MISTRESS': 'Mrs', 'MISS': 'Ms'};
  static final _show = DateFormat('dd MMM yyyy');
  static final _api = DateFormat('yyyy-MM-dd');

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _submitted = false;

  late final List<_Pax> _pax;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String _dialCode = '+252';
  final PhoneNumber _initialPhone = PhoneNumber(isoCode: 'SO', dialCode: '+252');

  TravellerParty get _party => widget.trip.party;

  @override
  void initState() {
    super.initState();
    _pax = [
      for (var i = 0; i < _party.adults; i++) _Pax(_Kind.adult),
      for (var i = 0; i < _party.children; i++)
        _Pax(_Kind.child,
            age: i < _party.childAges.length ? _party.childAges[i] : 2),
      for (var i = 0; i < _party.infants; i++) _Pax(_Kind.infant),
    ];
    FlightSearchService.countries().ignore(); // warm the nationality list
  }

  @override
  void dispose() {
    for (final p in _pax) {
      p.dispose();
    }
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- date rules

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime _yearsAgo(int years, {int plusDays = 0}) =>
      DateTime(_today.year - years, _today.month, _today.day + plusDays);

  /// Same bounds as the portal: adults 13+, a child exactly the age chosen
  /// on the search form, infants under 2.
  (DateTime, DateTime) _dobRange(_Pax p) => switch (p.kind) {
        _Kind.adult => (DateTime(1900), _yearsAgo(13)),
        _Kind.child => (
            _yearsAgo((p.age ?? 2) + 1, plusDays: 2),
            _yearsAgo(p.age ?? 2)
          ),
        _Kind.infant => (_yearsAgo(2, plusDays: 2), _today),
      };

  DateTime get _lastTravelDay => widget.trip.lastDeparture ?? _today;

  Future<void> _pickDate(
    _Pax p, {
    required bool isDob,
  }) async {
    final (first, last) = isDob
        ? _dobRange(p)
        : (_lastTravelDay, DateTime(_today.year + 20, 12, 31));
    var initial = (isDob ? p.dob : p.expiry) ??
        (isDob
            ? (p.kind == _Kind.adult ? DateTime(1990, 1, 1) : last)
            : DateTime(_today.year + 5, _today.month, _today.day));
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      initialDatePickerMode:
          isDob && p.kind == _Kind.adult ? DatePickerMode.year : DatePickerMode.day,
    );
    if (picked == null) return;
    setState(() {
      if (isDob) {
        p.dob = picked;
        p.dobText.text = _show.format(picked);
      } else {
        p.expiry = picked;
        p.expiryText.text = _show.format(picked);
      }
    });
  }

  Future<void> _pickNationality(_Pax p) async {
    final country = await showModalBottomSheet<Country>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const _CountrySheet(),
    );
    if (country == null) return;
    setState(() {
      p.nationality = country;
      p.nationalityText.text = country.name;
      // Most parties share a nationality: prefill the ones still empty.
      for (final other in _pax) {
        if (other.nationality == null) {
          other.nationality = country;
          other.nationalityText.text = country.name;
        }
      }
    });
  }

  // ------------------------------------------------------------- validators

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'passenger.required'.tr : null;

  String? _name(String? v) =>
      _required(v) ??
      (RegExp(r"^[A-Za-z' -]+$").hasMatch(v!.trim())
          ? null
          : 'passenger.lettersOnly'.tr);

  String? Function(String?) _docNumber(_Pax p) => (v) =>
      _required(v) ??
      (RegExp(p.docType == 'PASSPORT' ? r'^[A-Za-z0-9]{5,15}$' : r'^[A-Za-z0-9-]{3,20}$')
              .hasMatch(v!.trim())
          ? null
          : 'passenger.invalidDocument'.tr);

  String? Function(String?) _dob(_Pax p) => (_) {
        if (p.dob == null) return 'passenger.required'.tr;
        final (first, last) = _dobRange(p);
        return p.dob!.isBefore(first) || p.dob!.isAfter(last)
            ? 'passenger.dobOutOfRange'.tr
            : null;
      };

  String? Function(String?) _expiry(_Pax p) => (_) {
        if (p.expiry == null) return 'passenger.required'.tr;
        return p.expiry!.isBefore(_lastTravelDay)
            ? 'passenger.passportExpiresBeforeTravel'.tr
            : null;
      };

  String? _email(String? v) =>
      _required(v) ??
      (RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v!.trim())
          ? null
          : 'passenger.invalidEmail'.tr);

  String? _phoneValidator(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'passenger.required'.tr;
    return digits.length < 6 ? 'passenger.invalidPhone'.tr : null;
  }

  // ----------------------------------------------------------------- submit

  int _age(DateTime dob) {
    var years = _today.year - dob.year;
    if (_today.month < dob.month ||
        (_today.month == dob.month && _today.day < dob.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  List<Map<String, dynamic>> _payload() {
    final phone = phoneController.text.replaceAll(RegExp(r'\D'), '');
    return [
      for (final p in _pax)
        {
          'type': p.apiType,
          'title': p.title,
          'firstName': p.first.text.trim(),
          'lastName': p.last.text.trim(),
          'requestedAge': _age(p.dob!),
          'birthDate': _api.format(p.dob!),
          'documentType': p.docType,
          'documentNumber': p.docNumber.text.trim().toUpperCase(),
          'documentExpiry': _api.format(p.expiry!),
          'documentExpiration': _api.format(p.expiry!),
          'email': emailController.text.trim(),
          'phoneCountryCode': _dialCode,
          'phone': phone,
          'country': p.nationality!.isoCode,
          'countryId': p.nationality!.id,
        }
    ];
  }

  void _continue() {
    final titlesOk = _pax.every((p) => p.title != null);
    final formOk = _formKey.currentState!.validate();
    setState(() {
      _submitted = true;
      _autovalidate = AutovalidateMode.always;
    });
    if (!formOk || !titlesOk) {
      Get.showSnackbar(gradientSnackbar('common.checkForm'.tr,
          'passenger.fixErrors'.tr, AppColors.orange, Icons.warning_rounded));
      return;
    }
    Get.to(() => PaymentMethodScreen(
          trip: widget.trip,
          passengers: _payload(),
        ));
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColorAccent,
      appBar: CustomAppBar(title: 'passenger.screenTitle'.tr),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            const FunnelSteps(current: 1),
            const SizedBox(height: 14),
            TripSummaryCard(trip: widget.trip),
            const SizedBox(height: 14),
            for (var i = 0; i < _pax.length; i++) ...[
              _paxCard(_pax[i], i),
              const SizedBox(height: 12),
            ],
            _contactCard(),
          ],
        ),
      ),
      bottomNavigationBar: FareBar(
        trip: widget.trip,
        buttonLabel: 'passenger.continueToPayment'.tr,
        onPressed: _continue,
      ),
    );
  }

  String _kindLabel(_Pax p) => switch (p.kind) {
        _Kind.adult => 'passenger.adult'.tr,
        _Kind.child => "${'passenger.child'.tr} · ${'passenger.age'.tr} ${p.age}",
        _Kind.infant => "${'passenger.infant'.tr} · ${'passenger.under2'.tr}",
      };

  Widget _chips<T>({
    required Map<T, String> options,
    required T? value,
    required ValueChanged<T> onSelected,
    bool error = false,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: options.entries.map((e) {
        final sel = value == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: sel,
          showCheckmark: false,
          onSelected: (_) => onSelected(e.key),
          backgroundColor: AppColors.appColorWhite,
          selectedColor: AppColors.appColorLightTextColor,
          side: BorderSide(
              color: sel
                  ? AppColors.appColorPrimary
                  : error
                      ? AppColors.red
                      : const Color(0xFFB9C2D4)),
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
          labelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: sel ? AppColors.appColorPrimary : AppColors.appColorTextBlack,
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.appColorTextDarkGray,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: text),
              const TextSpan(text: ' *', style: TextStyle(color: AppColors.red)),
            ],
          ),
        ),
      );

  Widget _paxCard(_Pax p, int index) {
    final titleMissing = _submitted && p.title == null;
    final isPassport = p.docType == 'PASSPORT';
    return SectionCard(
      icon: p.kind == _Kind.adult ? Icons.person_rounded : Icons.child_care_rounded,
      title: "${'passenger.passenger'.tr} ${index + 1}",
      subtitle: index == 0
          ? "${_kindLabel(p)} · ${'passenger.leadPassenger'.tr}"
          : _kindLabel(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('passenger.title'.tr),
          _chips<String>(
            options: _titles,
            value: p.title,
            error: titleMissing,
            onSelected: (v) => setState(() => p.title = v),
          ),
          if (titleMissing)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CommonText(
                  text: 'passenger.required'.tr,
                  fontSize: 11.0,
                  color: AppColors.red),
            ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  textEditingController: p.first,
                  labelText: 'passenger.firstName'.tr,
                  isRequired: true,
                  hintText: 'passenger.firstName'.tr,
                  keyboardType: TextInputType.name,
                  validator: _name,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  textEditingController: p.last,
                  labelText: 'passenger.lastName'.tr,
                  isRequired: true,
                  hintText: 'passenger.lastName'.tr,
                  keyboardType: TextInputType.name,
                  validator: _name,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CommonText(
            text: 'passenger.asInPassport'.tr,
            fontSize: 11.0,
            color: AppColors.appColorTextLightGray,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  textEditingController: p.dobText,
                  labelText: 'passenger.dateOfBirth'.tr,
                  isRequired: true,
                  hintText: 'passenger.select'.tr,
                  readOnly: true,
                  onTap: () => _pickDate(p, isDob: true),
                  icon: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.appColorTextDarkGray),
                  validator: _dob(p),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  textEditingController: p.nationalityText,
                  labelText: 'passenger.nationality'.tr,
                  isRequired: true,
                  hintText: 'passenger.select'.tr,
                  readOnly: true,
                  onTap: () => _pickNationality(p),
                  icon: const Icon(Icons.expand_more_rounded,
                      color: AppColors.appColorTextDarkGray),
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _label('passenger.documentType'.tr),
          _chips<String>(
            options: {
              'PASSPORT': 'passenger.passport'.tr,
              'ID': 'passenger.nationalId'.tr,
            },
            value: p.docType,
            onSelected: (v) => setState(() => p.docType = v),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  textEditingController: p.docNumber,
                  labelText: isPassport
                      ? 'passenger.passportNumber'.tr
                      : 'passenger.idNumber'.tr,
                  isRequired: true,
                  hintText: isPassport ? 'P1234567' : '',
                  validator: _docNumber(p),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  textEditingController: p.expiryText,
                  labelText: 'passenger.documentExpiry'.tr,
                  isRequired: true,
                  hintText: 'passenger.select'.tr,
                  readOnly: true,
                  onTap: () => _pickDate(p, isDob: false),
                  icon: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.appColorTextDarkGray),
                  validator: _expiry(p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactCard() {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderSide: BorderSide(color: c, width: w),
          borderRadius: BorderRadius.circular(8),
        );
    return SectionCard(
      icon: Icons.alternate_email_rounded,
      title: 'passenger.contactInformation'.tr,
      subtitle: 'passenger.contactHint'.tr,
      child: Column(
        children: [
          CustomTextField(
            textEditingController: emailController,
            labelText: 'passenger.email'.tr,
            isRequired: true,
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: _email,
          ),
          const SizedBox(height: 12),
          InternationalPhoneNumberInput(
            initialValue: _initialPhone,
            textFieldController: phoneController,
            formatInput: true,
            keyboardType: TextInputType.phone,
            ignoreBlank: false,
            autoValidateMode: _autovalidate,
            selectorConfig: const SelectorConfig(
              trailingSpace: false,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              useEmoji: true,
              setSelectorButtonAsPrefixIcon: false,
            ),
            searchBoxDecoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
            ),
            selectorTextStyle:
                const TextStyle(color: AppColors.appColorTextBlack),
            cursorColor: AppColors.appColorPrimary,
            onInputChanged: (PhoneNumber n) => _dialCode = n.dialCode ?? _dialCode,
            validator: _phoneValidator,
            inputDecoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.appColorWhite,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: '61 234 5678',
              hintStyle: const TextStyle(
                  color: AppColors.appColorHint, fontSize: 14.0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.appColorTextDarkGray,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(text: 'passenger.phoneNumber'.tr),
                    const TextSpan(
                        text: ' *', style: TextStyle(color: AppColors.red)),
                  ],
                ),
              ),
              errorMaxLines: 2,
              border: border(const Color(0xFFB9C2D4)),
              enabledBorder: border(const Color(0xFFB9C2D4)),
              focusedBorder: border(AppColors.appColorPrimary, 2),
              errorBorder: border(AppColors.red, 1),
              focusedErrorBorder: border(AppColors.red, 2),
              errorStyle: const TextStyle(color: AppColors.red, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================ building blocks

class _CountrySheet extends StatefulWidget {
  const _CountrySheet();

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  late Future<List<Country>> _future = FlightSearchService.countries();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.appColorAccent,
                hintText: 'passenger.searchCountry'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.appColorPrimary, width: 1.5)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Country>>(
              future: _future,
              builder: (_, snap) {
                if (snap.hasError) {
                  return ResultsError(
                    onRetry: () => setState(
                        () => _future = FlightSearchService.countries()),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data!;
                // Somalia first: most ATA passengers are Somali.
                final list = [
                  ...all.where((c) => c.isoCode == 'SO'),
                  ...all.where((c) => c.isoCode != 'SO'),
                ]
                    .where((c) =>
                        _query.isEmpty ||
                        c.name.toLowerCase().contains(_query) ||
                        c.isoCode.toLowerCase() == _query)
                    .toList();
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: CommonText(
                      text: list[i].name,
                      fontSize: 14.0,
                      weight: FontWeight.w500,
                      color: AppColors.appColorTextBlack,
                    ),
                    trailing: CommonText(
                      text: list[i].isoCode,
                      fontSize: 12.0,
                      color: AppColors.appColorTextDarkGray,
                    ),
                    onTap: () => Navigator.pop(context, list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Itinerary summary card: one row per flown leg.
class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({required this.trip, super.key});
  final BookingTrip trip;

  String _legLabel(int i, int count) {
    if (count == 1) return '';
    if (trip.selections.length == 1 && count == 2) {
      return i == 0 ? 'passenger.outbound'.tr : 'passenger.inbound'.tr;
    }
    return "${'multi.flight'.tr} ${i + 1}";
  }

  @override
  Widget build(BuildContext context) {
    final legs = trip.legs;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.appColorSperator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CommonText(
                  text: 'passenger.yourFlight'.tr,
                  fontSize: 12.5,
                  weight: FontWeight.w600,
                  color: AppColors.appColorTextDarkGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.appColorLightTextColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CommonText(
                  text: trip.party.cabin == 'Business'
                      ? 'booking.business'.tr
                      : 'booking.economy'.tr,
                  fontSize: 10.5,
                  weight: FontWeight.w600,
                  color: AppColors.appColorPrimary,
                ),
              ),
            ],
          ),
          for (var i = 0; i < legs.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.appColorSperator),
            if (i == 0) const SizedBox(height: 10),
            AirlineHeader(
              name: legs[i].airline,
              flightNumber: legs[i].flightNumber,
              logoUrl: legs[i].logoUrl,
            ),
            const SizedBox(height: 8),
            FlightLegRow(
              fromCode: legs[i].fromCode,
              fromTime: legs[i].fromTime,
              toCode: legs[i].toCode,
              toTime: legs[i].toTime,
              caption: _legLabel(i, legs.length),
              date: legs[i].date,
            ),
          ],
        ],
      ),
    );
  }
}

/// White card with an icon badge, title, subtitle and a body.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });
  final IconData icon;
  final String title, subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.appColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.appColorSperator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.appColorLightTextColor,
                ),
                child: Icon(icon, size: 18, color: AppColors.appColorPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: title,
                      fontSize: 14.0,
                      weight: FontWeight.w700,
                      color: AppColors.appColorTextBlack,
                    ),
                    const SizedBox(height: 2),
                    CommonText(
                      text: subtitle,
                      fontSize: 11.5,
                      color: AppColors.appColorTextDarkGray,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Sticky footer: total (tap for the breakdown) + the primary action.
class FareBar extends StatelessWidget {
  const FareBar({
    required this.trip,
    required this.buttonLabel,
    required this.onPressed,
    super.key,
  });
  final BookingTrip trip;
  final String buttonLabel;
  final VoidCallback? onPressed;

  static String _money(double v) => ResultCard.money(v);

  String get _travellers {
    final p = trip.party;
    return [
      "${p.adults} ${'passenger.adult'.tr}",
      if (p.children > 0) "${p.children} ${'passenger.child'.tr}",
      if (p.infants > 0) "${p.infants} ${'passenger.infant'.tr}",
    ].join(' · ');
  }

  void _showBreakdown(BuildContext context) {
    Widget row(String l, String v, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                text: l,
                fontSize: 13.0,
                weight: strong ? FontWeight.w600 : FontWeight.w400,
                color: strong
                    ? AppColors.appColorTextBlack
                    : AppColors.appColorTextDarkGray,
              ),
              CommonText(
                text: v,
                fontSize: strong ? 15.0 : 13.0,
                weight: strong ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.appColorTextBlack,
              ),
            ],
          ),
        );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'passenger.fareSummary'.tr,
              fontSize: 16.0,
              weight: FontWeight.w700,
              color: AppColors.appColorTextBlack,
            ),
            const SizedBox(height: 4),
            CommonText(
              text: _travellers,
              fontSize: 12.0,
              color: AppColors.appColorTextDarkGray,
            ),
            const SizedBox(height: 14),
            row('passenger.fare'.tr, _money(trip.fare)),
            row('passenger.taxesAndFees'.tr, _money(trip.tax)),
            const Divider(height: 18, color: AppColors.appColorSperator),
            row('passenger.total'.tr, _money(trip.total), strong: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.appColorWhite,
        border: Border(top: BorderSide(color: AppColors.appColorSperator)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showBreakdown(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonText(
                            text: 'passenger.total'.tr,
                            fontSize: 11.0,
                            color: AppColors.appColorTextDarkGray,
                          ),
                          const Icon(Icons.expand_less_rounded,
                              size: 16, color: AppColors.appColorTextDarkGray),
                        ],
                      ),
                      CommonText(
                        text: _money(trip.total),
                        fontSize: 20.0,
                        weight: FontWeight.w700,
                        color: AppColors.appColorTextBlack,
                        lineHeight: 1.1,
                      ),
                      CommonText(
                        text: _travellers,
                        fontSize: 11.0,
                        color: AppColors.appColorTextLightGray,
                        maxLines: 1,
                        overFlow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
