import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keySelectedCity = 'selected_city';
  static const String _keyAuthToken = 'jwt_auth_token';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserName = 'user_name';
  static const String _keySavedAddresses = 'saved_addresses';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // City Persistence
  static Future<String?> getSelectedCity() async {
    final prefs = await _instance;
    return prefs.getString(_keySelectedCity);
  }

  static Future<void> setSelectedCity(String city) async {
    final prefs = await _instance;
    await prefs.setString(_keySelectedCity, city);
  }

  static Future<void> clearSelectedCity() async {
    final prefs = await _instance;
    await prefs.remove(_keySelectedCity);
  }

  // Auth Persistence
  static Future<String?> getAuthToken() async {
    final prefs = await _instance;
    return prefs.getString(_keyAuthToken);
  }

  static Future<void> setAuthToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_keyAuthToken, token);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await _instance;
    return prefs.getString(_keyUserPhone);
  }

  static Future<void> setUserPhone(String phone) async {
    final prefs = await _instance;
    await prefs.setString(_keyUserPhone, phone);
  }

  static Future<String?> getUserName() async {
    final prefs = await _instance;
    return prefs.getString(_keyUserName);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await _instance;
    await prefs.setString(_keyUserName, name);
  }

  static Future<void> clearAuth() async {
    final prefs = await _instance;
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserName);
  }

  // Saved Addresses Persistence
  static Future<List<String>> getSavedAddresses() async {
    final prefs = await _instance;
    return prefs.getStringList(_keySavedAddresses) ?? [
      'Flat 402, Radhe Residency, 150ft Ring Road',
      'Shop 12, Crystal Mall, Kalawad Road',
    ];
  }

  static Future<void> setSavedAddresses(List<String> addresses) async {
    final prefs = await _instance;
    await prefs.setStringList(_keySavedAddresses, addresses);
  }

  static Future<void> addSavedAddress(String address) async {
    final list = await getSavedAddresses();
    if (!list.contains(address)) {
      list.add(address);
      await setSavedAddresses(list);
    }
  }
}
