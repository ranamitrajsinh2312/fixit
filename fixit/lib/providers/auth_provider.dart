import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _token;
  String? _phone;
  String? _name;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get phone => _phone;
  String? get name => _name;
  String? get error => _error;

  AuthProvider() {
    init();
  }

  Future<void> init() async {
    _token = await StorageService.getAuthToken();
    _phone = await StorageService.getUserPhone();
    _name = await StorageService.getUserName();
    _isLoggedIn = _token != null && _token!.isNotEmpty;
    notifyListeners();
  }

  Future<Map<String, dynamic>> sendOtp(String inputPhone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.instance.sendOtp(inputPhone);
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> verifyOtp(String inputPhone, String otp, {String? inputName, String? city}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.instance.verifyOtp(
        inputPhone,
        otp,
        name: inputName,
        city: city,
      );

      if (res['success'] == true && res['token'] != null) {
        _token = res['token'];
        _phone = inputPhone;
        _name = inputName ?? (res['user'] != null ? res['user']['name'] : 'Devang Patel');
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = res['message'] ?? 'OTP Verification failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    _token = null;
    _phone = null;
    _name = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
