import 'package:flutter/foundation.dart';

enum AppLanguage { en, gu, hi }

class AppStrings extends ChangeNotifier {
  static final AppStrings instance = AppStrings._internal();
  AppStrings._internal();

  AppLanguage _currentLanguage = AppLanguage.en;
  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.gu:
        return 'ગુજરાતી (Gujarati)';
      case AppLanguage.hi:
        return 'हिंदी (Hindi)';
      case AppLanguage.en:
        return 'English';
    }
  }

  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    'tagline': {
      AppLanguage.en: 'Home repairs & emergency RSA, sorted.',
      AppLanguage.gu: 'ઘર સમારકામ અને તાત્કાલિક સેવાઓ, સરળતાથી.',
      AppLanguage.hi: 'घर की मरम्मत और आपातकालीन सेवाएं, आसानी से।',
    },
    'home': {
      AppLanguage.en: 'Home',
      AppLanguage.gu: 'હોમ',
      AppLanguage.hi: 'होम',
    },
    'bookings': {
      AppLanguage.en: 'Bookings',
      AppLanguage.gu: 'બુકિંગ',
      AppLanguage.hi: 'बुकिंग',
    },
    'profile': {
      AppLanguage.en: 'Profile',
      AppLanguage.gu: 'પ્રોફાઇલ',
      AppLanguage.hi: 'प्रोफाइल',
    },
    'searchPlaceholder': {
      AppLanguage.en: 'Search electrician, plumber, AC...',
      AppLanguage.gu: 'ઇલેક્ટ્રિશિયન, પ્લમ્બર, એસી સર્ચ કરો...',
      AppLanguage.hi: 'इलेक्ट्रीशियन, प्लंबर, एसी खोजें...',
    },
    'instantDispatch': {
      AppLanguage.en: '⚡ Instant Dispatch (15-30 Mins)',
      AppLanguage.gu: '⚡ તાત્કાલિક સેવા (15-30 મિનિટ)',
      AppLanguage.hi: '⚡ तत्काल सेवा (15-30 मिनट)',
    },
    'rateReview': {
      AppLanguage.en: 'Rate Service',
      AppLanguage.gu: 'રેટિંગ આપો',
      AppLanguage.hi: 'रेटिंग दें',
    },
    'rebook': {
      AppLanguage.en: 'Rebook',
      AppLanguage.gu: 'ફરીથી બુક કરો',
      AppLanguage.hi: 'दोबारा बुक करें',
    },
    'platformFeeNote': {
      AppLanguage.en: '₹25 platform fee • Technician receives 100% of service charge',
      AppLanguage.gu: '₹25 પ્લેટફોર્મ ફી • ટેકનિશિયનને 100% સર્વિસ ચાર્જ મળે છે',
      AppLanguage.hi: '₹25 प्लेटफॉर्म शुल्क • तकनीशियन को 100% सेवा शुल्क मिलता है',
    },
    'myBookings': {
      AppLanguage.en: 'My Bookings',
      AppLanguage.gu: 'મારા બુકિંગ',
      AppLanguage.hi: 'मेरी बुकिंग',
    },
    'all': {
      AppLanguage.en: 'All',
      AppLanguage.gu: 'બધું',
      AppLanguage.hi: 'सभी',
    },
    'upcoming': {
      AppLanguage.en: 'Upcoming',
      AppLanguage.gu: 'આગામી',
      AppLanguage.hi: 'आगामी',
    },
    'completed': {
      AppLanguage.en: 'Completed',
      AppLanguage.gu: 'પૂર્ણ',
      AppLanguage.hi: 'पूर्ण',
    },
    'cancelled': {
      AppLanguage.en: 'Cancelled',
      AppLanguage.gu: 'રદ થયેલ',
      AppLanguage.hi: 'रद्द',
    },
    'rateAndReview': {
      AppLanguage.en: 'Rate & Review',
      AppLanguage.gu: 'રેટિંગ અને સમીક્ષા',
      AppLanguage.hi: 'रेटिंग और समीक्षा',
    },
    'changeLanguage': {
      AppLanguage.en: 'App Language',
      AppLanguage.gu: 'એપ્લિકેશન ભાષા',
      AppLanguage.hi: 'ऐप भाषा',
    },
    'selectLanguage': {
      AppLanguage.en: 'Select Preferred Language',
      AppLanguage.gu: 'પસંદગીની ભાષા પસંદ કરો',
      AppLanguage.hi: 'पसंदीदा भाषा चुनें',
    },
    'adminConsole': {
      AppLanguage.en: 'Admin Console',
      AppLanguage.gu: 'એડમિન કન્સોલ',
      AppLanguage.hi: 'एडमिन कंसोल',
    },
    'servicerApp': {
      AppLanguage.en: 'Servicer App',
      AppLanguage.gu: 'સર્વિસ પાર્ટનર',
      AppLanguage.hi: 'सर्विस पार्टनर',
    },
    'savedAddresses': {
      AppLanguage.en: 'Saved Addresses',
      AppLanguage.gu: 'સાચવેલ સરનામા',
      AppLanguage.hi: 'सहेजे गए पते',
    },
    'guarantee': {
      AppLanguage.en: '30-Day FixIt Guarantee',
      AppLanguage.gu: '૩૦ દિવસની ફિક્સઇટ ગેરંટી',
      AppLanguage.hi: '30 दिनों की फिक्सइट गारंटी',
    },
    'support': {
      AppLanguage.en: 'Customer Support',
      AppLanguage.gu: 'ગ્રાહક સહાય',
      AppLanguage.hi: 'ग्राहक सहायता',
    },
  };

  String tr(String key) {
    if (_localizedValues.containsKey(key)) {
      return _localizedValues[key]?[_currentLanguage] ?? _localizedValues[key]?[AppLanguage.en] ?? key;
    }
    return key;
  }
}
