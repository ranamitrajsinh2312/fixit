import 'package:flutter/foundation.dart' hide Category;
import '../data.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AppServicesProvider extends ChangeNotifier {
  String _selectedCity = 'Rajkot';
  int _dynamicPlatformFee = 25;
  List<String> _cities = cities;
  List<Category> _categories = categories;
  List<BookingItem> _bookings = BookingStore.instance.bookings;
  bool _isLoading = false;

  String get selectedCity => _selectedCity;
  int get dynamicPlatformFee => _dynamicPlatformFee;
  List<String> get citiesList => _cities;
  List<Category> get categoriesList => _categories;
  List<BookingItem> get bookingsList => _bookings;
  bool get isLoading => _isLoading;

  AppServicesProvider({String initialCity = 'Rajkot'}) {
    _selectedCity = initialCity;
    init();
  }

  Future<void> init() async {
    final savedCity = await StorageService.getSelectedCity();
    if (savedCity != null && savedCity.isNotEmpty) {
      _selectedCity = savedCity;
    }
    await loadData();
  }

  Future<void> changeCity(String city) async {
    _selectedCity = city;
    await StorageService.setSelectedCity(city);
    notifyListeners();
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedFee = await ApiService.instance.fetchPlatformFee();
      _dynamicPlatformFee = fetchedFee;

      final fetchedCities = await ApiService.instance.fetchCities();
      _cities = fetchedCities;

      final fetchedCats = await ApiService.instance.fetchCategories(city: _selectedCity);
      _categories = fetchedCats;

      final fetchedBookings = await ApiService.instance.fetchMyBookings();
      _bookings = fetchedBookings;
    } catch (e) {
      debugPrint('[AppServicesProvider] loadData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBookings() async {
    try {
      final list = await ApiService.instance.fetchMyBookings();
      _bookings = list;
      notifyListeners();
    } catch (e) {
      debugPrint('[AppServicesProvider] refreshBookings error: $e');
    }
  }
}
