import 'package:get/get.dart';

import 'safarplus_strings.dart';

/// English/Somali strings for the agency app (SafarPlus wording is laid on top
/// from safarplus_strings.dart).
///
/// Keys and Somali wording are reused VERBATIM from the agency portal's
/// reviewed translation file (ATASomalia.GDS.Mircosite
/// src/assets/i18n/translations.json) so both products speak the same
/// vocabulary — including the client's "buukin" spelling convention.
/// Mobile-only strings (not present on the portal) follow the same
/// vocabulary and are marked with a trailing comment.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {..._en, ...SafarPlusStrings.en},
        'so': {..._so, ...SafarPlusStrings.so},
      };

  static const Map<String, String> _en = {
    // auth
    'auth.welcome': 'Welcome',
    'auth.signInSubtitle': 'Sign in to continue',
    'auth.username': 'Username',
    'auth.password': 'Password',
    'auth.enterUsername': 'Enter username',
    'auth.enterPassword': 'Enter password',
    'auth.forgotPassword': 'Forgot Password?',
    'auth.signIn': 'Sign in',
    'auth.resetTitle': 'Reset your password',
    'auth.resetSent': 'Password reset. Check email',
    'auth.deactivatedTitle': 'Account Deactivated',
    'auth.deactivatedBody':
        'Your account has been deactivated. You will be logged out.',
    'auth.sessionExpiredTitle': 'Session expired',
    'auth.sessionExpiredBody': 'Please sign in again to continue.',
    'auth.agencySubtitle': 'Sign in to your ATA agency account',
    'auth.agencyOnly': 'This app is for ATA agency accounts only.',
    'auth.agencyOnlyHint': 'For registered ATA travel agencies',
    'auth.showPassword': 'Show password',
    'auth.hidePassword': 'Hide password',
    'splash.tagline': 'Agency flight booking',
    'update.title': 'Update required',
    'update.body':
        'A new version of the ATA app is available. Please update it to keep searching and booking flights.',
    'update.button': 'Update now',
    'onboard.skip': 'Skip',
    'onboard.next': 'Next',
    'onboard.getStarted': 'Get started',
    'onboard.searchTitle': 'Search every airline',
    'onboard.searchBody': 'Compare fares from all ATA partner airlines in one search.',
    'onboard.bookTitle': 'Book in minutes',
    'onboard.bookBody': 'Add passenger details once and get the e-ticket straight away.',
    'onboard.payTitle': 'Pay from your balance',
    'onboard.payBody': 'Bookings are charged to your agency deposit — no cards needed.',

    // dashboard (portal keys)
    'nav.home': 'Home',
    'dashboard.goodMorning': 'Good morning',
    'dashboard.goodAfternoon': 'Good afternoon',
    'dashboard.goodEvening': 'Good evening',
    'dashboard.totalBookings': 'Total bookings',
    'dashboard.recentBookings': 'Recent bookings',
    'dashboard.subscription': 'Subscription',
    'dashboard.manage': 'Manage',
    'dashboard.view': 'View all',
    'dashboard.noBookingsYet': 'No bookings yet',
    'dashboard.noBookingsYetHint': 'Search flights to make your first booking.',
    'dashboard.balance': 'Agency balance',
    'dashboard.topUp': 'Top up',

    // nav / shell
    'nav.search': 'Search',
    'nav.myBookings': 'My Bookings',
    'nav.myProfile': 'My Profile',
    'nav.bookFlight': 'Book a flight',
    'nav.companyProfile': 'Company Profile',
    'nav.balanceTopUp': 'Balance Top Up',
    'nav.subscription': 'My Subscription',
    'nav.logout': 'Logout',
    'nav.language': 'Language',
    'nav.hello': 'Hello',
    'nav.version': 'Version',
    'nav.sectionMenu': 'Menu',
    'nav.sectionAgency': 'Agency',
    'nav.sectionSettings': 'Settings',

    // common
    'common.success': 'Success',
    'common.failure': 'Failure',
    'common.error': 'Something went wrong. Please try again.',
    'common.somethingWrong': 'Something went wrong',
    'common.ok': 'Ok',
    'common.cancel': 'Cancel',
    'common.confirm': 'Confirm',
    'common.back': 'Back',
    'common.total': 'Total',
    'common.date': 'Date',
    'common.amount': 'Amount',
    'common.status': 'Status',
    'common.reference': 'Reference',
    'common.loading': 'Loading',

    // booking / search
    'booking.roundTrip': 'Round trip',
    'booking.oneWay': 'One way',
    'booking.multiCity': 'Multi-city',
    'booking.from': 'From',
    'booking.to': 'To',
    'booking.searchCity': 'City or airport',
    'booking.departure': 'Departure',
    'booking.return': 'Return',
    'booking.travellers': 'Travellers',
    'booking.cabinClass': 'Cabin class',
    'booking.adults': 'Adult',
    'booking.children': 'Child',
    'booking.infants': 'Infant',
    'booking.economy': 'Economy',
    'booking.business': 'Business',
    'booking.searchFlights': 'Search flights',
    'booking.noFlights': 'No flights available',
    'booking.recent': 'Recent',
    'booking.selectDate': 'Select Date',
    'booking.multiCityTitle': 'Multi City',
    'booking.flightPnr': 'Flight PNR',
    'booking.airline': 'Airline',
    'booking.direct': 'Direct',
    'booking.sortLowHigh': 'Price (Low to High)',
    'booking.sortHighLow': 'Price (High to Low)',
    'booking.loadBookingsFailed': 'Failed to load bookings',
    'booking.noBookings': 'No bookings found',
    'booking.reference': 'Reference',
    'booking.fare': 'Fare',
    'booking.taxesAndFees': 'Taxes and fees',
    'booking.agencyCharges': 'Agency charges',
    'booking.total': 'Total',
    'booking.share': 'Share',
    'booking.voidTicket': 'Void ticket',
    'booking.searchPnr': 'Search PNR',

    // passenger details (portal booking-flow keys where they exist)
    'passenger.screenTitle': 'Passenger details',
    'passenger.stepFlights': 'Flights',
    'passenger.stepPassengers': 'Passengers',
    'passenger.stepPayment': 'Payment',
    'passenger.yourFlight': 'Your flight',
    'passenger.outbound': 'Outbound',
    'passenger.inbound': 'Inbound',
    'passenger.passenger': 'Passenger',
    'passenger.leadPassenger': 'Lead passenger',
    'passenger.adult': 'Adult',
    'passenger.child': 'Child',
    'passenger.infant': 'Infant',
    'passenger.age': 'age',
    'passenger.title': 'Title',
    'passenger.firstName': 'First name',
    'passenger.lastName': 'Last name',
    'passenger.asInPassport': 'Names exactly as they appear in the passport.',
    'passenger.dateOfBirth': 'Date of birth',
    'passenger.nationality': 'Nationality',
    'passenger.passportNumber': 'Passport number',
    'passenger.passportExpiry': 'Passport expiry',
    'passenger.contactInformation': 'Contact information',
    'passenger.contactHint': 'The e-ticket and booking updates are sent here.',
    'passenger.email': 'Email',
    'passenger.phoneNumber': 'Phone number',
    'passenger.select': 'Select',
    'passenger.required': 'Required',
    'passenger.invalidEmail': 'Enter a valid email',
    'passenger.lettersOnly': 'Letters only, as in the passport',
    'passenger.invalidPassport': 'Enter a valid passport number',
    'passenger.passportExpiresBeforeTravel':
        'Document expires before the travel date',
    'passenger.fixErrors': 'Please complete the highlighted fields',
    'passenger.fareSummary': 'Fare summary',
    'passenger.fare': 'Fare',
    'passenger.taxesAndFees': 'Taxes and fees',
    'passenger.total': 'Total',
    'passenger.continueToPayment': 'Continue to payment',

    // search form
    'search.headline': 'Where are your clients flying?',
    'search.addReturn': 'Add return',
    'search.travellersCabin': 'Travellers & cabin',
    'search.travellers': 'Travellers',
    'search.adultsHint': '13+ years',
    'search.childrenHint': '2–12 years',
    'search.infantsHint': 'Under 2, on a lap',
    'search.childAges': "Children's ages",
    'search.done': 'Done',
    'search.errRoute': 'Select both departure and destination',
    'search.errSameCity': 'Departure and destination must be different',
    'search.errInfants': 'Each infant must travel with an adult',
    'search.errMaxPax': 'Maximum 9 travellers per booking',
    'search.multiCityHint': 'Plan up to several flights in one trip',

    // results / flight details
    'results.from': 'From',
    'results.select': 'Select',
    'results.sortBy': 'Sort by',
    'results.filterBy': 'Filter by',
    'results.fareOptions': 'Fare options',
    'results.checkedBaggage': 'Checked baggage',
    'results.cabinBaggage': 'Cabin baggage',
    'results.ticket': 'Ticket',
    'results.taxes': 'Taxes and fees',
    'results.total': 'Total',
    'results.book': 'Book this fare',
    'results.noFareRules': 'No fare found for this flight',
    'results.flights': 'flights',
    'results.flight': 'flight',
    'common.checkForm': 'Check the form',
    'results.emptyHint': 'Try another date from the strip above.',
    'common.showMore': 'Show more',
    'common.showLess': 'Show less',
    'profile.firstName': 'First name',
    'profile.middleName': 'Middle name',
    'profile.lastName': 'Last name',
    'profile.username': 'Username',
    'profile.email': 'Email',
    'profile.update': 'Edit profile',
    'city.searchHint': 'City or airport code',
    'city.popular': 'Recent & popular',
    'city.results': 'Airports',
    'city.clearRecent': 'Clear recent',

    // payment
    'payment.title': 'Payment',
    'payment.balance': 'Agency balance',
    'payment.method': 'Payment method',
    'payment.noMethods': 'No payment methods available',
    'payment.selectMethod': 'Please select a payment method',
    'payment.total': 'Total to pay',
    'payment.insufficient': 'Insufficient balance',
    'payment.insufficientHint': 'Top up your deposit to complete this booking.',
    'payment.confirm': 'Confirm booking',
    'payment.confirmTitle': 'Confirm this booking?',
    'payment.confirmBody': '@count passenger(s) · @amount will be charged to the agency balance.',
    'passenger.under2': 'under 2',
    'passenger.documentType': 'Document type',
    'passenger.passport': 'Passport',
    'passenger.nationalId': 'National ID',
    'passenger.idNumber': 'ID number',
    'passenger.documentExpiry': 'Expiry date',
    'passenger.invalidDocument': 'Enter a valid document number',
    'passenger.invalidPhone': 'Enter a valid phone number',
    'passenger.dobOutOfRange': 'Date of birth does not fit this passenger type',
    'passenger.searchCountry': 'Search country',
    'passenger.priceFailed': 'Could not confirm the price for this flight. It may no longer be available.',
    'payment.priceChangedTitle': 'Fare updated',
    'payment.priceChanged': 'The fare is now @amount. Check the total and confirm again.',
    'results.error': 'Could not load flights. Check your connection.',
    'results.retry': 'Try again',
    'results.sortCheapest': 'Lowest price',
    'results.sortPriciest': 'Highest price',
    'results.sortEarliest': 'Earliest departure',
    'results.sortLatest': 'Latest departure',
    'results.airlines': 'Airlines',
    'results.clear': 'Clear',
    'results.showFlights': 'Show @count flights',
    'results.selected': 'Selected',
    'multi.flight': 'Flight',
    'multi.addFlight': 'Add another flight',
    'multi.removeFlight': 'Remove flight',
    'multi.selectedOf': '@count of @total flights selected',
    'multi.continue': 'Continue',
    'confirm.title': 'Booking confirmed',
    'confirm.subtitle': 'The e-ticket is sent to the contact email.',
    'confirm.copy': 'Copy PNR',
    'confirm.viewBookings': 'View my bookings',
    'confirm.home': 'Back to home',

    // status
    'status.confirmed': 'Confirmed',
    'status.pending': 'Pending',
    'status.void': 'Void',
    'status.cancelled': 'Cancelled',
    'status.active': 'Active',
    'status.expiringSoon': 'Expiring Soon',
    'status.expired': 'Expired',
    'status.suspended': 'Suspended',

    // subscription
    'subscription.myTitle': 'My Subscription',
    'subscription.renewTitle': 'Renew or change plan',
    'subscription.choosePlan': 'Choose a plan',
    'subscription.daysLeft': 'days left',
    'subscription.dayLeft': 'day left',
    'subscription.accessUntil': 'Access until',
    'subscription.expiredOn': 'Expired on',
    'subscription.noActive': 'No active subscription.',
    'subscription.payWithEvc': 'Pay with EVC Plus',
    'subscription.evcHint':
        'You will receive a payment prompt on this number. Approve it to activate.',
    'subscription.evcNumber': 'EVC number',
    'subscription.evcRequired': 'Enter the EVC number to charge.',
    'subscription.pay': 'Pay',
    'subscription.renew': 'Renew',
    'subscription.paymentHistory': 'Payment history',
    'subscription.noPayments': 'No payments yet.',
    'subscription.paymentSuccess': 'Payment successful',
    'subscription.paymentFailed': 'Payment failed',
    'subscription.plan': 'Plan',
    'subscription.savePercent': 'Save',
    'subscription.perMonth': '/month',
    'subscription.daysWord': 'days',
    'subscription.notEnrolledTitle': 'No subscription required',
    'subscription.notEnrolledHint':
        'Your agency has open access to the booking portal. There is nothing to pay.',
    'subscription.suspendedHint':
        'Your subscription is suspended. Please contact ATA to reinstate it.',
    'subscription.loadError': 'Could not load your subscription.',
    'subscription.plansError': 'Could not load the plans.',
  };

  static const Map<String, String> _so = {
    // auth
    'auth.welcome': 'Soo dhawoow', // mobile-only
    'auth.signInSubtitle': 'Soo gal si aad u sii wadato', // mobile-only
    'auth.username': 'Magaca isticmaalaha',
    'auth.password': 'Furaha sirta ah',
    'auth.enterUsername': 'Geli magaca isticmaalaha', // mobile-only
    'auth.enterPassword': 'Geli furaha sirta ah', // mobile-only
    'auth.forgotPassword': 'Ma illowday furaha?',
    'auth.signIn': 'Soo gal',
    'auth.resetTitle': 'Furahaaga dib u samee',
    'auth.resetSent': 'Furaha waa la beddelay. Fiiri iimaylkaaga', // mobile-only
    'auth.deactivatedTitle': 'Akoonka waa la joojiyay', // mobile-only
    'auth.deactivatedBody':
        'Akoonkaaga waa la joojiyay. Waa lagaa saarayaa.', // mobile-only
    'auth.sessionExpiredTitle': 'Fadhigu wuu dhacay', // mobile-only
    'auth.sessionExpiredBody': 'Fadlan mar kale soo gal.', // mobile-only
    'auth.agencySubtitle': 'Gal akoonkaaga wakaaladda ATA', // mobile-only
    'auth.agencyOnly': 'Barnaamijkan waxaa loogu talagalay akoonnada wakaaladaha ATA oo kaliya.', // mobile-only
    'auth.agencyOnlyHint': 'Loogu talagalay wakaaladaha safarka ee ATA ka diiwaangashan', // mobile-only
    'auth.showPassword': 'Muuji furaha', // mobile-only
    'auth.hidePassword': 'Qari furaha', // mobile-only
    'splash.tagline': 'Buukinta duulimaadyada wakaaladda', // mobile-only
    'update.title': 'Cusboonaysiin ayaa loo baahan yahay', // mobile-only
    'update.body': // mobile-only
        'Nooc cusub oo app-ka ATA ayaa diyaar ah. Fadlan cusboonaysii si aad u sii raadiso oo u buukiso duulimaadyada.',
    'update.button': 'Hadda cusboonaysii', // mobile-only
    'onboard.skip': 'Ka bood', // mobile-only
    'onboard.next': 'Xiga', // mobile-only
    'onboard.getStarted': 'Bilow', // mobile-only
    'onboard.searchTitle': 'Raadi dhammaan shirkadaha', // mobile-only
    'onboard.searchBody': 'Isbarbardhig qiimaha dhammaan shirkadaha la shaqeeya ATA hal raadin.', // mobile-only
    'onboard.bookTitle': 'Buuki daqiiqado gudahood', // mobile-only
    'onboard.bookBody': 'Geli xogta rakaabka hal mar oo isla markiiba hel e-tikidhka.', // mobile-only
    'onboard.payTitle': 'Ka bixi haraagaaga', // mobile-only
    'onboard.payBody': 'Buukimaha waxaa laga jarayaa lacagta wakaaladda — kaarar looma baahna.', // mobile-only

    // dashboard (portal keys)
    'nav.home': 'Bogga Hore',
    'dashboard.goodMorning': 'Subax wanaagsan',
    'dashboard.goodAfternoon': 'Galab wanaagsan',
    'dashboard.goodEvening': 'Habeen wanaagsan',
    'dashboard.totalBookings': 'Wadarta buukimaha',
    'dashboard.recentBookings': 'Buukimihii ugu dambeeyay',
    'dashboard.subscription': 'Xubinimada',
    'dashboard.manage': 'Maamul',
    'dashboard.view': 'Dhammaan eeg', // common.viewAll from portal
    'dashboard.noBookingsYet': 'Weli buukin ma jiro',
    'dashboard.noBookingsYetHint': 'Duulimaadyo raadi si aad u samayso buukintaada koowaad.',
    'dashboard.balance': 'Haraaga wakaaladda', // mobile-only (nav.balance variant)
    'dashboard.topUp': 'Buuxi', // nav.topUp from portal

    // nav / shell
    'nav.search': 'Raadi',
    'nav.myBookings': 'Diiwaanka Buukinkayga',
    'nav.myProfile': 'Xogtayda',
    'nav.bookFlight': 'Duulimaad Qabso',
    'nav.companyProfile': 'Xogta Shirkadda',
    'nav.balanceTopUp': 'Lacag Dhigasho',
    'nav.subscription': 'Xubinimadayda', // mobile-only variant of nav.subscription
    'nav.logout': 'Ka bax',
    'nav.language': 'Luqadda',
    'nav.hello': 'Salaan', // mobile-only
    'nav.version': 'Nooca', // mobile-only
    'nav.sectionMenu': 'Liiska', // mobile-only
    'nav.sectionAgency': 'Wakaaladda', // mobile-only
    'nav.sectionSettings': 'Dejinta', // mobile-only

    // common
    'common.success': 'Guul', // mobile-only
    'common.failure': 'Khalad', // mobile-only
    'common.error': 'Wax qalad ah ayaa dhacay. Fadlan mar kale isku day.',
    'common.somethingWrong': 'Wax qalad ah ayaa dhacay',
    'common.ok': 'Haye', // mobile-only
    'common.cancel': 'Jooji',
    'common.confirm': 'Xaqiiji',
    'common.back': 'Dib u noqo',
    'common.total': 'Wadarta',
    'common.date': 'Taariikhda',
    'common.amount': 'Qadarka',
    'common.status': 'Xaaladda',
    'common.reference': 'Tixraaca',
    'common.loading': 'Socda',

    // booking / search
    'booking.roundTrip': 'Tag iyo soo noqod',
    'booking.oneWay': 'Hal jiho',
    'booking.multiCity': 'Magaalooyin badan',
    'booking.from': 'Ka',
    'booking.to': 'Ilaa',
    'booking.searchCity': 'Magaalo ama garoon',
    'booking.departure': 'Bixitaanka',
    'booking.return': 'Soo laabashada',
    'booking.travellers': 'Musaafiriinta',
    'booking.cabinClass': 'Fasalka',
    'booking.adults': 'Qof weyn',
    'booking.children': 'Ilmo',
    'booking.infants': 'Dhallaan',
    'booking.economy': 'Fasalka caadiga',
    'booking.business': 'Fasalka ganacsiga',
    'booking.searchFlights': 'Duulimaadyo raadi',
    'booking.noFlights': 'Duulimaad lama helin', // mobile-only
    'booking.recent': 'Kuwii dhawaa',
    'booking.selectDate': 'Taariikh dooro',
    'booking.multiCityTitle': 'Magaalooyin badan',
    'booking.flightPnr': 'PNR-ka Duulimaadka',
    'booking.airline': 'Shirkadda Duulimaadka',
    'booking.direct': 'Toos',
    'booking.sortLowHigh': 'Qiimaha: hooseeya ilaa sare',
    'booking.sortHighLow': 'Qiimaha: sareeya ilaa hoose',
    'booking.loadBookingsFailed': 'Buukimaha lama soo dejin karin', // mobile-only
    'booking.noBookings': 'Wax buukin ah lama helin',
    'booking.reference': 'Tixraaca',
    'booking.fare': 'Qiimaha tikidhka', // mobile-only
    'booking.taxesAndFees': 'Canshuuraha iyo khidmadaha', // mobile-only
    'booking.agencyCharges': 'Khidmadda wakaaladda', // mobile-only
    'booking.total': 'Wadarta',
    'booking.share': 'La wadaag', // mobile-only
    'booking.voidTicket': 'Tikidhka buri',
    'booking.searchPnr': 'PNR raadi', // mobile-only

    // passenger details
    'passenger.screenTitle': 'Faahfaahinta musaafiriinta', // mobile-only
    'passenger.stepFlights': 'Duulimaadyada', // mobile-only
    'passenger.stepPassengers': 'Musaafiriinta',
    'passenger.stepPayment': 'Lacag bixinta', // mobile-only
    'passenger.yourFlight': 'Duulimaadkaaga', // mobile-only
    'passenger.outbound': 'Baxitaanka',
    'passenger.inbound': 'Soo laabashada',
    'passenger.passenger': 'Musaafir',
    'passenger.leadPassenger': 'Musaafirka hoggaamiyaha', // mobile-only
    'passenger.adult': 'Qof weyn',
    'passenger.child': 'Ilmo',
    'passenger.infant': 'Dhallaan',
    'passenger.age': 'da\'da', // mobile-only
    'passenger.title': 'Cinwaanka',
    'passenger.firstName': 'Magaca koowaad',
    'passenger.lastName': 'Magaca dambe',
    'passenger.asInPassport': 'Magacyada sida ay ugu qoran yihiin baasaboorka.', // mobile-only
    'passenger.dateOfBirth': 'Taariikhda dhalashada',
    'passenger.nationality': 'Dalka',
    'passenger.passportNumber': 'Lambarka baasaboorka', // mobile-only
    'passenger.passportExpiry': 'Dhicitaanka baasaboorka', // mobile-only
    'passenger.contactInformation': 'Xogta xiriirka',
    'passenger.contactHint': 'E-tikidhka iyo cusboonaysiinta buukinta halkan ayaa loo dirayaa.', // mobile-only
    'passenger.email': 'Iimaylka',
    'passenger.phoneNumber': 'Lambarka taleefanka',
    'passenger.select': 'Dooro', // mobile-only
    'passenger.required': 'Waa loo baahan yahay', // mobile-only
    'passenger.invalidEmail': 'Iimayl sax ah geli', // mobile-only
    'passenger.lettersOnly': 'Xarfo kaliya, sida baasaboorka ku qoran', // mobile-only
    'passenger.invalidPassport': 'Lambar baasaboor sax ah geli', // mobile-only
    'passenger.passportExpiresBeforeTravel':
        'Dokumentigu wuxuu dhacayaa taariikhda safarka ka hor', // mobile-only
    'passenger.fixErrors': 'Fadlan buuxi goobaha la calaamadeeyay', // mobile-only
    'passenger.fareSummary': 'Kooban qiimaha', // mobile-only
    'passenger.fare': 'Qiimaha tikidhka', // mobile-only
    'passenger.taxesAndFees': 'Canshuuraha iyo khidmadaha', // mobile-only
    'passenger.total': 'Wadarta',
    'passenger.continueToPayment': 'U gudub lacag bixinta', // mobile-only

    // search form
    'search.headline': 'Xagee macaamiishaadu u duulayaan?',
    'search.addReturn': 'Ku dar soo laabasho', // mobile-only
    'search.travellersCabin': 'Musaafiriinta & fasalka', // mobile-only
    'search.travellers': 'Musaafiriinta',
    'search.adultsHint': '13+ sano', // mobile-only
    'search.childrenHint': '2–12 sano', // mobile-only
    'search.infantsHint': 'Ka yar 2 sano, dhabta lagu qaado', // mobile-only
    'search.childAges': 'Da\'da carruurta', // mobile-only
    'search.done': 'Dhammee', // mobile-only
    'search.errRoute': 'Dooro meesha laga baxayo iyo meesha la aadayo', // mobile-only
    'search.errSameCity': 'Meesha laga baxayo iyo meesha la aadayo waa inay kala duwanaadaan', // mobile-only
    'search.errInfants': 'Dhallaan kastaa waa inuu la socdaa qof weyn', // mobile-only
    'search.errMaxPax': 'Ugu badnaan 9 musaafir buukin kasta', // mobile-only
    'search.multiCityHint': 'Qorshee dhowr duulimaad hal safar', // mobile-only

    // results / flight details
    'results.from': 'Laga bilaabo', // mobile-only
    'results.select': 'Dooro', // mobile-only
    'results.sortBy': 'Kala saar', // mobile-only
    'results.filterBy': 'Shaandhee', // mobile-only
    'results.fareOptions': 'Xulashooyinka qiimaha', // mobile-only
    'results.checkedBaggage': 'Shandad la hubiyay', // mobile-only
    'results.cabinBaggage': 'Shandadda gacanta', // mobile-only
    'results.ticket': 'Tikidhka', // mobile-only
    'results.taxes': 'Canshuuraha iyo khidmadaha', // mobile-only
    'results.total': 'Wadarta',
    'results.book': 'Buuki qiimahan', // mobile-only
    'results.noFareRules': 'Qiime looma helin duulimaadkan', // mobile-only
    'results.flights': 'duulimaad', // mobile-only
    'results.flight': 'duulimaad', // mobile-only
    'common.checkForm': 'Hubi foomka', // mobile-only
    'results.emptyHint': 'Isku day taariikh kale oo kor ku jirta.', // mobile-only
    'common.showMore': 'Wax badan muuji', // mobile-only
    'common.showLess': 'Wax yar muuji', // mobile-only
    'profile.firstName': 'Magaca koowaad',
    'profile.middleName': 'Magaca dhexe', // mobile-only
    'profile.lastName': 'Magaca dambe',
    'profile.username': 'Magaca isticmaalaha',
    'profile.email': 'Iimaylka',
    'profile.update': 'Wax ka beddel xogta', // mobile-only
    'city.searchHint': 'Magaalo ama garoon', // mobile-only
    'city.popular': 'Kuwii dhawaa & caanka ah', // mobile-only
    'city.results': 'Garoomada', // mobile-only
    'city.clearRecent': 'Tirtir kuwii dhawaa', // mobile-only

    // payment
    'payment.title': 'Lacag bixinta', // mobile-only
    'payment.balance': 'Haraaga wakaaladda', // mobile-only
    'payment.method': 'Habka lacag bixinta',
    'payment.noMethods': 'Hab lacag bixin lama helin', // mobile-only
    'payment.selectMethod': 'Fadlan dooro hab lacag bixin', // mobile-only
    'payment.total': 'Wadarta la bixinayo', // mobile-only
    'payment.insufficient': 'Haraaga kuma filna',
    'payment.insufficientHint': 'Lacag ku dar haraagaaga si aad u dhammaystirto buukintan.',
    'payment.confirm': 'Xaqiiji buukinta', // mobile-only
    'payment.confirmTitle': 'Ma xaqiijinaysaa buukintan?', // mobile-only
    'payment.confirmBody': '@count musaafir · @amount ayaa laga jarayaa haraaga wakaaladda.', // mobile-only
    'passenger.under2': 'ka yar 2 sano', // mobile-only
    'passenger.documentType': 'Nooca dokumentiga',
    'passenger.passport': 'Baasaboor', // mobile-only
    'passenger.nationalId': 'Aqoonsi qaran', // mobile-only
    'passenger.idNumber': 'Lambarka aqoonsiga', // mobile-only
    'passenger.documentExpiry': 'Dhicitaanka dokumentiga',
    'passenger.invalidDocument': 'Lambar dokumenti sax ah geli', // mobile-only
    'passenger.invalidPhone': 'Lambar taleefan sax ah geli', // mobile-only
    'passenger.dobOutOfRange': 'Taariikhda dhalashadu kuma habboona nooca rakaabka',
    'passenger.searchCountry': 'Raadi dal', // mobile-only
    'passenger.priceFailed': 'Qiimaha duulimaadkan lama xaqiijin karin. Waxaa laga yaabaa inuusan hadda diyaar ahayn.', // mobile-only
    'payment.priceChangedTitle': 'Qiimaha waa la cusboonaysiiyay', // mobile-only
    'payment.priceChanged': 'Qiimaha hadda waa @amount. Hubi wadarta oo mar kale xaqiiji.', // mobile-only
    'results.error': 'Duulimaadyada lama soo dejin karin. Hubi internetkaaga.', // mobile-only
    'results.retry': 'Isku day mar kale', // mobile-only
    'results.sortCheapest': 'Qiimaha ugu jaban', // mobile-only
    'results.sortPriciest': 'Qiimaha ugu sarreeya', // mobile-only
    'results.sortEarliest': 'Bixitaanka ugu hore', // mobile-only
    'results.sortLatest': 'Bixitaanka ugu dambeeya', // mobile-only
    'results.airlines': 'Shirkadaha duulimaadka', // mobile-only
    'results.clear': 'Tirtir', // mobile-only
    'results.showFlights': 'Muuji @count duulimaad', // mobile-only
    'results.selected': 'La doortay', // mobile-only
    'multi.flight': 'Duulimaad', // mobile-only
    'multi.addFlight': 'Ku dar duulimaad kale', // mobile-only
    'multi.removeFlight': 'Ka saar duulimaadka', // mobile-only
    'multi.selectedOf': '@count ka mid ah @total duulimaad ayaa la doortay', // mobile-only
    'multi.continue': 'Sii wad', // mobile-only
    'confirm.title': 'Buukinta waa la xaqiijiyay', // mobile-only
    'confirm.subtitle': 'E-tikidhka waxaa loo diray iimaylka xiriirka.', // mobile-only
    'confirm.copy': 'Koobi PNR', // mobile-only
    'confirm.viewBookings': 'Eeg buukinkayga', // mobile-only
    'confirm.home': 'Ku noqo bogga hore', // mobile-only

    // status
    'status.confirmed': 'La xaqiijiyay',
    'status.pending': 'La sugayo',
    'status.void': 'La buriyay',
    'status.cancelled': 'La joojiyay',
    'status.active': 'Firfircoon',
    'status.expiringSoon': 'Dhawaan dhacaysa',
    'status.expired': 'Dhacday',
    'status.suspended': 'Hakad',

    // subscription
    'subscription.myTitle': 'Xubinimadayda', // mobile-only
    'subscription.renewTitle': 'Cusboonaysii ama beddel qorshahaaga',
    'subscription.choosePlan': 'Dooro qorshe',
    'subscription.daysLeft': 'maalmood harsan',
    'subscription.dayLeft': 'maalin harsan', // mobile-only singular
    'subscription.accessUntil': 'Gelitaanku wuxuu socdaa ilaa',
    'subscription.expiredOn': 'Waxay dhacday', // mobile-only
    'subscription.noActive': 'Xubinimo firfircoon ma jirto.', // mobile-only
    'subscription.payWithEvc': 'Ku bixi EVC Plus', // mobile-only
    'subscription.evcHint':
        'Waxaad heli doontaa codsi lacag bixin ah lambarkan. Ansixi si aad u hawlgeliso.', // mobile-only
    'subscription.evcNumber': 'Lambarka EVC',
    'subscription.evcRequired': 'Fadlan geli lambarkaaga mobilada EVC.',
    'subscription.pay': 'Bixi', // mobile-only
    'subscription.renew': 'Cusboonaysii', // mobile-only
    'subscription.paymentHistory': 'Taariikhda lacag bixinta',
    'subscription.noPayments': 'Wali lacag bixin ma jirto.', // mobile-only
    'subscription.paymentSuccess': 'Lacag bixintu way guulaysatay',
    'subscription.paymentFailed': 'Lacag bixinta lama dhammaystiri karin',
    'subscription.plan': 'Qorshaha',
    'subscription.savePercent': 'Badbaadi',
    'subscription.perMonth': '/bishiiba',
    'subscription.daysWord': 'maalmood',
    'subscription.notEnrolledTitle': 'Xubinimo looma baahna',
    'subscription.notEnrolledHint':
        'Wakaaladdaadu si buuxda ayey u geli kartaa bogga buukinta. Wax lacag ah looma baahna.', // shortened from portal
    'subscription.suspendedHint':
        'Xubinimadaadu waa hakad. Fadlan la xiriir ATA si dib loogu soo celiyo.', // mobile-only
    'subscription.loadError': 'Xubinimadaada lama soo dejin karin.',
    'subscription.plansError': 'Qorshayaasha lama soo dejin karin.',
  };
}
