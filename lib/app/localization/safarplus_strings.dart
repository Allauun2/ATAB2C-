/// SafarPlus wording. Laid over the ATA agency app's translations (same keys
/// win here) and adds the customer-only strings. Somali here is best-effort
/// for the SafarPlus copy — worth a review by a native speaker before launch.
class SafarPlusStrings {
  static const Map<String, String> en = {
    // brand
    'splash.tagline': 'Flights · Travel · More',
    'update.body':
        'A new version of SafarPlus is available. Please update it to keep searching and booking flights.',
    'onboard.searchBody': "Compare fares from Somalia's airlines in one search.",
    'onboard.payTitle': 'Pay with EVC Plus',
    'onboard.payBody':
        'Approve the payment on your phone — your e-ticket is issued straight away.',

    // sign in
    'auth.signInSubtitle': 'Sign in to book your flights',
    'auth.agencySubtitle': 'Sign in to your SafarPlus account',
    'auth.agencyOnly':
        'This app is for SafarPlus customer accounts. Travel agencies use the ATA app.',
    'auth.agencyOnlyHint': 'Flights · Travel · More',
    'auth.username': 'Email',
    'auth.enterUsername': 'Enter your email',
    'auth.noAccount': 'New to SafarPlus?',
    'auth.createAccount': 'Create an account',

    // sign up
    'register.title': 'Create your account',
    'register.subtitle': 'Book flights and pay with EVC Plus',
    'register.firstName': 'First name',
    'register.lastName': 'Last name',
    'register.email': 'Email',
    'register.phone': 'Mobile number',
    'register.phoneHint': '61xxxxxxx',
    'register.password': 'Password',
    'register.confirmPassword': 'Confirm password',
    'register.required': 'Required',
    'register.nameRule': 'At least 3 letters',
    'register.invalidEmail': 'Enter a valid email address',
    'register.invalidPhone': 'Enter the 9-digit number, e.g. 61xxxxxxx',
    'register.passwordRule': 'At least 8 characters',
    'register.passwordMismatch': 'Passwords do not match',
    'register.agree':
        'By creating an account you agree to the Terms of use and Privacy policy.',
    'register.submit': 'Create account',
    'register.haveAccount': 'Already have an account?',
    'register.doneTitle': 'Check your email',
    'register.doneBody':
        'We sent an activation link to @email. Open it to activate your account, then sign in.',
    'register.exists':
        'An account with this email already exists. Sign in or reset your password.',

    // shell
    'search.headline': 'Where are you flying to?',
    'nav.myBookings': 'My Trips',
    'nav.search': 'Book a flight',

    // payment
    'payment.method': 'Pay with EVC Plus',
    'payment.evcHint':
        'Enter the EVC Plus number to pay from. That phone will ask you to approve the payment with your PIN.',
    'payment.evcNumber': 'EVC Plus number',
    'payment.invalidEvc': 'Enter the 9-digit EVC Plus number, e.g. 61xxxxxxx',
    'payment.confirm': 'Pay and book',
    'payment.confirmTitle': 'Pay and book?',
    'payment.confirmBody':
        '@count passenger(s) · @amount will be requested from EVC Plus @phone. Approve it on that phone with your PIN.',
    'payment.waiting': 'Approve the payment on your phone',
    'payment.waitingHint':
        'Enter your EVC PIN when your phone asks. Keep this screen open — your ticket is issued as soon as you approve.',
    'payment.notChargedNote':
        'If we cannot issue your ticket, the payment is cancelled and you are not charged.',

    // profile
    'profile.support': 'Help & support',
    'profile.callUs': 'Call us',
    'profile.emailUs': 'Email us',
    'profile.website': 'Website',
    'profile.privacy': 'Privacy policy',
    'profile.terms': 'Terms of use',
    'profile.account': 'Account',
    'profile.deleteAccount': 'Delete account',
    'profile.deleteTitle': 'Delete your account?',
    'profile.deleteBody':
        'Your login and personal details will be removed. Tickets you have already booked stay valid. This cannot be undone.',
    'profile.deleteConfirm': 'Delete',
    'profile.deleted': 'Your account has been deleted.',

    // my trips
    'trips.emptyHint':
        'Find great fares to your next destination with SafarPlus.',
    'trips.guestHint':
        'Trips you book as a guest are saved on this phone. You can also find any booking with its reference (PNR).',
    'trips.findBooking': 'Find a booking',

    // guest
    'auth.continueAsGuest': 'Continue as guest',
    'auth.or': 'or',
    'auth.continueWithGoogle': 'Continue with Google',
    'auth.continueWithApple': 'Continue with Apple',
    'guest.hello': 'Hello, guest',
    'guest.title': "You're booking as a guest",
    'guest.body':
        'Create a free account to keep all your trips in one place, on any phone.',
    'guest.signUp': 'Sign up',
    'guest.signInForTrips': 'Have an account? Sign in to see all your trips',
    'profile.settings': 'Settings',
  };

  static const Map<String, String> so = {
    'splash.tagline': 'Duulimaadyo · Safar · Iyo wax kale',
    'update.body':
        'Nooc cusub oo SafarPlus ah ayaa diyaar ah. Fadlan cusboonaysii si aad u sii raadiso oo u buukiso duulimaadyada.',
    'onboard.searchBody':
        'Isbarbardhig qiimaha shirkadaha diyaaradaha Soomaaliya hal raadin.',
    'onboard.payTitle': 'Ku bixi EVC Plus',
    'onboard.payBody':
        'Lacagta ka ogolow taleefankaaga — e-tikidhkaaga isla markiiba waa la soo saarayaa.',

    'auth.signInSubtitle': 'Soo gal si aad u buukiso duulimaadyadaada',
    'auth.agencySubtitle': 'Gal akoonkaaga SafarPlus',
    'auth.agencyOnly':
        'App-kan waxaa loogu talagalay akoonnada macaamiisha SafarPlus. Wakaaladaha safarka waxay isticmaalaan app-ka ATA.',
    'auth.agencyOnlyHint': 'Duulimaadyo · Safar · Iyo wax kale',
    'auth.username': 'Iimaylka',
    'auth.enterUsername': 'Geli iimaylkaaga',
    'auth.noAccount': 'Ku cusub SafarPlus?',
    'auth.createAccount': 'Samee akoon',

    'register.title': 'Samee akoonkaaga',
    'register.subtitle': 'Buuki duulimaadyo oo ku bixi EVC Plus',
    'register.firstName': 'Magaca koowaad',
    'register.lastName': 'Magaca dambe',
    'register.email': 'Iimaylka',
    'register.phone': 'Lambarka taleefanka',
    'register.phoneHint': '61xxxxxxx',
    'register.password': 'Furaha sirta ah',
    'register.confirmPassword': 'Xaqiiji furaha sirta ah',
    'register.required': 'Waa loo baahan yahay',
    'register.nameRule': 'Ugu yaraan 3 xaraf',
    'register.invalidEmail': 'Geli iimayl sax ah',
    'register.invalidPhone': 'Geli lambarka 9-ka god ah, tusaale 61xxxxxxx',
    'register.passwordRule': 'Ugu yaraan 8 xaraf',
    'register.passwordMismatch': 'Furayaasha sirta ah isma laha',
    'register.agree':
        'Markaad akoon samaysato waxaad aqbashay Shuruudaha isticmaalka iyo Siyaasadda asturnaanta.',
    'register.submit': 'Samee akoon',
    'register.haveAccount': 'Akoon ma leedahay?',
    'register.doneTitle': 'Fiiri iimaylkaaga',
    'register.doneBody':
        'Waxaan xiriir hawlgelin ah u dirnay @email. Fur si aad akoonkaaga u hawlgeliso, kadibna soo gal.',
    'register.exists':
        'Akoon leh iimaylkan horay ayuu u jiray. Soo gal ama dib u samee furaha.',

    'search.headline': 'Xagee u socotaa?',
    'nav.myBookings': 'Safarradayda',
    'nav.search': 'Duulimaad qabso',

    'payment.method': 'Ku bixi EVC Plus',
    'payment.evcHint':
        'Geli lambarka EVC Plus ee lacagta laga bixinayo. Taleefankaas ayaa ku weydiin doona inaad PIN-kaaga ku ogolaato lacagta.',
    'payment.evcNumber': 'Lambarka EVC Plus',
    'payment.invalidEvc':
        'Geli lambarka EVC Plus ee 9-ka god ah, tusaale 61xxxxxxx',
    'payment.confirm': 'Bixi oo buuki',
    'payment.confirmTitle': 'Ma bixinaysaa oo ma buukinaysaa?',
    'payment.confirmBody':
        '@count musaafir · @amount ayaa laga codsanayaa EVC Plus @phone. Ku ogolow taleefankaas PIN-kaaga.',
    'payment.waiting': 'Lacagta ka ogolow taleefankaaga',
    'payment.waitingHint':
        'Geli PIN-ka EVC markuu taleefanku ku weydiiyo. Shaashaddan ha xirin — tikidhkaaga isla markaad ogolaato ayaa la soo saarayaa.',
    'payment.notChargedNote':
        'Haddii aynaan soo saari karin tikidhkaaga, lacag bixinta waa la joojinayaa oo lagaama jarayo.',

    'profile.support': 'Caawimaad',
    'profile.callUs': 'Na wac',
    'profile.emailUs': 'Iimayl noo soo dir',
    'profile.website': 'Websaydka',
    'profile.privacy': 'Siyaasadda asturnaanta',
    'profile.terms': 'Shuruudaha isticmaalka',
    'profile.account': 'Akoonka',
    'profile.deleteAccount': 'Tirtir akoonka',
    'profile.deleteTitle': 'Ma tirtiraysaa akoonkaaga?',
    'profile.deleteBody':
        'Galitaankaaga iyo xogtaada shakhsiga ah waa la tirtirayaa. Tikidhada aad horay u buukisay way shaqaynayaan. Tan dib looma celin karo.',
    'profile.deleteConfirm': 'Tirtir',
    'profile.deleted': 'Akoonkaaga waa la tirtiray.',

    'trips.emptyHint': 'Ka hel qiimo fiican safarkaaga xiga SafarPlus.',
    'trips.guestHint':
        'Safarrada aad marti ahaan u ballansato waxay ku kaydsan yihiin taleefankan. Ballan kasta waxaad ku heli kartaa lambarkeeda (PNR).',
    'trips.findBooking': 'Raadi ballan',

    'auth.continueAsGuest': 'Ku sii wad marti ahaan',
    'auth.or': 'ama',
    'auth.continueWithGoogle': 'Ku sii wad Google',
    'auth.continueWithApple': 'Ku sii wad Apple',
    'guest.hello': 'Soo dhawoow, marti',
    'guest.title': 'Waxaad u ballansanaysaa marti ahaan',
    'guest.body':
        'Samee akoon bilaash ah si safarradaada oo dhan meel keliya ugu jiraan, taleefan kasta.',
    'guest.signUp': 'Is diiwaangeli',
    'guest.signInForTrips': 'Akoon ma leedahay? Gal si aad u aragto safarradaada oo dhan',
    'profile.settings': 'Dejinta',
  };
}
