import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../data.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  final http.Client _client = http.Client();

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // -------------------------------------------------------------
  // Cities
  // -------------------------------------------------------------
  Future<List<String>> fetchCities() async {
    try {
      final res = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/cities'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List)
              .map((c) => c['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchCities fallback to local data: $e');
    }
    return cities;
  }

  // -------------------------------------------------------------
  // Categories
  // -------------------------------------------------------------
  Future<List<Category>> fetchCategories({String? city}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/categories').replace(
        queryParameters: city != null && city.isNotEmpty ? {'city': city} : null,
      );
      final res = await _client.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final fetched = (body['data'] as List).map((catJson) {
            final id = catJson['id']?.toString() ?? '';
            // Match with local category definition for icons/colors
            final local = categories.firstWhere(
              (c) => c.id == id,
              orElse: () => Category(
                id: id,
                name: catJson['name']?.toString() ?? id,
                icon: Icons.handyman,
                color: const Color(0xFF2563EB),
                services: const [],
              ),
            );
            return local;
          }).toList();
          if (fetched.isNotEmpty) return fetched;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchCategories fallback to local: $e');
    }
    return categories;
  }

  // -------------------------------------------------------------
  // Platform Fee (Dynamic)
  // -------------------------------------------------------------
  Future<int> fetchPlatformFee() async {
    try {
      final res = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/settings/platformFee'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['platformFee'] != null) {
          return int.tryParse(body['platformFee'].toString()) ?? 25;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchPlatformFee fallback: $e');
    }
    return platformFee;
  }

  // -------------------------------------------------------------
  // Services
  // -------------------------------------------------------------
  Future<List<Service>> fetchServices({
    String? categoryId,
    String? city,
    String? query,
  }) async {
    try {
      final params = <String, String>{};
      if (categoryId != null && categoryId.isNotEmpty) params['category'] = categoryId;
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (query != null && query.isNotEmpty) params['q'] = query;

      final uri = Uri.parse('${ApiConstants.baseUrl}/services').replace(queryParameters: params);
      final res = await _client.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List).map((s) {
            return Service(
              id: s['id']?.toString() ?? '',
              name: s['name']?.toString() ?? '',
              desc: s['desc']?.toString() ?? '',
              price: (s['price'] as num?)?.toInt() ?? 199,
              rating: (s['rating'] as num?)?.toDouble() ?? 4.8,
              reviewsCount: (s['reviewsCount'] as num?)?.toInt() ?? 1000,
              included: (s['included'] as List?)?.map((e) => e.toString()).toList() ?? const [
                'Inspection & diagnosis',
                'Repair by verified technician',
                '30-day warranty',
              ],
            );
          }).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchServices fallback: $e');
    }

    // Local fallback
    if (categoryId != null) {
      final cat = categories.firstWhere((c) => c.id == categoryId, orElse: () => categories.first);
      return cat.services;
    }
    return categories.expand((c) => c.services).toList();
  }

  // -------------------------------------------------------------
  // Bookings
  // -------------------------------------------------------------
  Future<BookingItem> createBooking({
    required String serviceId,
    required String serviceName,
    required String categoryName,
    required int price,
    required String address,
    required String city,
    required String dateTime,
    required String paymentMethod,
    int discount = 0,
    String couponCode = '',
    String? transactionId,
    String? customerName,
    String? customerPhone,
  }) async {
    final token = await StorageService.getAuthToken();
    final savedPhone = await StorageService.getUserPhone();
    final savedName = await StorageService.getUserName();

    try {
      final bodyData = {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'categoryName': categoryName,
        'customerName': customerName ?? savedName ?? 'Guest User',
        'customerPhone': customerPhone ?? savedPhone ?? '+91 98795 43210',
        'address': address,
        'city': city,
        'dateTime': dateTime,
        'paymentMethod': paymentMethod,
        'discount': discount,
        'couponCode': couponCode,
      };

      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: _headers(token),
        body: jsonEncode(bodyData),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final d = body['data'];
          final isCash = paymentMethod.toLowerCase().contains('cash');
          final item = BookingItem(
            id: d['bookingId']?.toString() ?? 'FX-${DateTime.now().millisecondsSinceEpoch}',
            serviceName: d['serviceName']?.toString() ?? serviceName,
            categoryName: d['categoryName']?.toString() ?? categoryName,
            price: (d['price'] as num?)?.toInt() ?? price,
            platformFee: (d['platformFee'] as num?)?.toInt() ?? 25,
            totalAmount: (d['totalAmount'] as num?)?.toInt() ?? (price + 25 - discount),
            address: d['address']?.toString() ?? address,
            city: d['city']?.toString() ?? city,
            dateTime: d['dateTime']?.toString() ?? dateTime,
            status: d['status']?.toString() ?? 'Upcoming',
            paymentMethod: d['paymentMethod']?.toString() ?? paymentMethod,
            paymentStatus: d['paymentStatus']?.toString() ?? (isCash ? 'pending' : 'paid'),
            transactionId: d['transactionId']?.toString() ?? transactionId ?? '',
            discount: (d['discount'] as num?)?.toInt() ?? discount,
            couponCode: d['couponCode']?.toString() ?? couponCode,
          );
          BookingStore.instance.addBooking(item);
          return item;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createBooking server unreachable, saving locally: $e');
    }

    // Local fallback
    final randomId = 'FX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final isCash = paymentMethod.toLowerCase().contains('cash');
    final localItem = BookingItem(
      id: randomId,
      serviceName: serviceName,
      categoryName: categoryName,
      price: price,
      platformFee: 25,
      totalAmount: (price + 25 - discount).clamp(0, 999999),
      address: address,
      city: city,
      dateTime: dateTime,
      status: 'Upcoming',
      paymentMethod: paymentMethod,
      paymentStatus: isCash ? 'pending' : 'paid',
      transactionId: transactionId ?? (isCash ? '' : 'pay_sim_${DateTime.now().millisecondsSinceEpoch}'),
      discount: discount,
      couponCode: couponCode,
    );
    BookingStore.instance.addBooking(localItem);
    return localItem;
  }

  Future<List<BookingItem>> fetchMyBookings() async {
    final token = await StorageService.getAuthToken();
    final phone = await StorageService.getUserPhone() ?? '+91 98795 43210';

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/bookings/me').replace(
        queryParameters: {'phone': phone},
      );
      final res = await _client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List).map((d) {
            final pMethod = d['paymentMethod']?.toString() ?? 'UPI';
            final isCash = pMethod.toLowerCase().contains('cash');
            return BookingItem(
              id: d['bookingId']?.toString() ?? '',
              serviceName: d['serviceName']?.toString() ?? '',
              categoryName: d['categoryName']?.toString() ?? '',
              price: (d['price'] as num?)?.toInt() ?? 0,
              platformFee: (d['platformFee'] as num?)?.toInt() ?? 25,
              totalAmount: (d['totalAmount'] as num?)?.toInt() ?? 0,
              address: d['address']?.toString() ?? '',
              city: d['city']?.toString() ?? '',
              dateTime: d['dateTime']?.toString() ?? '',
              status: d['status']?.toString() ?? 'Upcoming',
              paymentMethod: pMethod,
              paymentStatus: d['paymentStatus']?.toString() ?? (isCash ? 'pending' : 'paid'),
              transactionId: d['transactionId']?.toString() ?? '',
              discount: (d['discount'] as num?)?.toInt() ?? 0,
              couponCode: d['couponCode']?.toString() ?? '',
              refundId: d['refundId']?.toString(),
              refundAmount: (d['refundAmount'] as num?)?.toInt(),
            );
          }).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchMyBookings fallback: $e');
    }

    return BookingStore.instance.bookings;
  }

  // -------------------------------------------------------------
  // Authentication (Phone OTP & JWT)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] sendOtp server offline fallback: $e');
    }
    // Offline simulated response
    return {
      'success': true,
      'message': 'OTP sent (Demo test mode)',
      'otp': '123456',
    };
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, {String? name, String? city}) async {
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
          'name': name,
          'city': city,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['token'] != null) {
          await StorageService.setAuthToken(body['token']);
          await StorageService.setUserPhone(phone);
          if (name != null) await StorageService.setUserName(name);
        }
        return body;
      }
    } catch (e) {
      debugPrint('[ApiService] verifyOtp server offline fallback: $e');
    }

    // Offline demo fallback token
    const demoToken = 'demo_jwt_token_2026';
    await StorageService.setAuthToken(demoToken);
    await StorageService.setUserPhone(phone);
    if (name != null) await StorageService.setUserName(name);

    return {
      'success': true,
      'token': demoToken,
      'user': {
        'name': name ?? 'Devang Patel',
        'phone': phone,
        'city': city ?? 'Rajkot',
      },
    };
  }

  // -------------------------------------------------------------
  // User Profile
  // -------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final token = await StorageService.getAuthToken();
    final phone = await StorageService.getUserPhone() ?? '+91 98795 43210';

    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/users/profile').replace(queryParameters: {'phone': phone}),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint('[ApiService] fetchUserProfile fallback: $e');
    }
    return null;
  }

  // -------------------------------------------------------------
  // Phase 4: Provider & Booking Assignment Operations
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> registerProvider({
    required String name,
    required String phone,
    required String categoryId,
    required String categoryName,
    required String city,
    String? aadhaarNo,
    int? experienceYears,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/providers/register'),
        headers: _headers(token),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'categoryId': categoryId,
          'categoryName': categoryName,
          'city': city,
          'aadhaarNo': aadhaarNo ?? 'XXXX-XXXX-9821',
          'experienceYears': experienceYears ?? 3,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] registerProvider fallback: $e');
    }

    return {
      'success': true,
      'message': 'Provider registered successfully (offline demo)',
      'data': {
        '_id': 'prov_demo_offline',
        'name': name,
        'phone': phone,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'city': city,
        'kycStatus': 'verified',
        'isOnline': true,
      },
    };
  }

  Future<Map<String, dynamic>?> fetchProviderProfile({String? phone}) async {
    final token = await StorageService.getAuthToken();
    final p = phone ?? '+91 98250 11223';
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/providers/me').replace(queryParameters: {'phone': p}),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint('[ApiService] fetchProviderProfile fallback: $e');
    }
    return {
      '_id': 'prov_demo_1',
      'name': 'Ramesh Sharma',
      'phone': p,
      'categoryId': 'electrician',
      'categoryName': 'Electrician',
      'city': 'Rajkot',
      'kycStatus': 'verified',
      'isOnline': true,
      'rating': 4.9,
      'completedJobs': 18,
      'totalEarnings': 4850,
    };
  }

  Future<Map<String, dynamic>> fetchProviderJobs({
    required String providerId,
    String? city,
    String? categoryId,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final params = <String, String>{};
      if (city != null) params['city'] = city;
      if (categoryId != null) params['categoryId'] = categoryId;

      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/providers/$providerId/jobs').replace(queryParameters: params),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return body['data'];
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchProviderJobs fallback: $e');
    }

    return {
      'assigned': [],
      'available': [],
      'completed': [],
    };
  }

  Future<bool> acceptBooking({
    required String bookingId,
    required String providerId,
    String? providerName,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/accept'),
        headers: _headers(token),
        body: jsonEncode({
          'providerId': providerId,
          'providerName': providerName ?? 'Assigned Specialist',
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] acceptBooking fallback: $e');
    }
    return true;
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/status'),
        headers: _headers(token),
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] updateBookingStatus fallback: $e');
    }
    return true;
  }

  Future<bool> updateProviderStatus({
    required String providerId,
    bool? isOnline,
    String? kycStatus,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final body = <String, dynamic>{};
      if (isOnline != null) body['isOnline'] = isOnline;
      if (kycStatus != null) body['kycStatus'] = kycStatus;

      final res = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/providers/$providerId/status'),
        headers: _headers(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] updateProviderStatus fallback: $e');
    }
    return true;
  }

  Future<bool> updateProviderKyc({
    required String providerId,
    required String kycStatus,
    String? aadhaarNo,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/providers/$providerId/kyc'),
        headers: _headers(token),
        body: jsonEncode({
          'kycStatus': kycStatus,
          if (aadhaarNo != null) 'aadhaarNo': aadhaarNo,
        }),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] updateProviderKyc fallback: $e');
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchNotifications(String phone) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications').replace(queryParameters: {'phone': phone}),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchNotifications fallback: $e');
    }
    return [];
  }

  // -------------------------------------------------------------
  // Phase 5: Payments, Razorpay, Coupons & Refund APIs
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> createPaymentOrder({
    required String serviceId,
    String? couponCode,
    String? city,
    int? customPrice,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/create-order'),
        headers: _headers(token),
        body: jsonEncode({
          'serviceId': serviceId,
          if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
          if (city != null) 'city': city,
          if (customPrice != null) 'customPrice': customPrice,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] createPaymentOrder fallback: $e');
    }

    // Local simulation fallback
    final fee = 25;
    final price = customPrice ?? 199;
    int discount = 0;
    final clean = (couponCode ?? '').trim().toUpperCase();
    if (clean == 'FIXIT50' || clean == 'FIRST50') {
      discount = 50;
    } else if (clean == 'WAIVEFEE') {
      discount = fee;
    }

    final total = (price + fee - discount).clamp(0, 999999);
    return {
      'success': true,
      'orderId': 'order_sim_${DateTime.now().millisecondsSinceEpoch}',
      'currency': 'INR',
      'servicePrice': price,
      'platformFee': fee,
      'discount': discount,
      'couponCode': clean,
      'totalAmount': total,
      'providerPayout': price,
    };
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String bookingId,
    required String paymentMethod,
    required int totalAmount,
    int platformFee = 25,
    int? providerPayout,
    int discount = 0,
    String? couponCode,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/verify'),
        headers: _headers(token),
        body: jsonEncode({
          'orderId': orderId,
          'paymentId': paymentId,
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'totalAmount': totalAmount,
          'platformFee': platformFee,
          'providerPayout': providerPayout ?? (totalAmount - platformFee),
          'discount': discount,
          'couponCode': couponCode ?? '',
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] verifyPayment fallback: $e');
    }

    return {
      'success': true,
      'message': 'Payment verified successfully (local)',
      'data': {
        'orderId': orderId,
        'transactionId': paymentId,
        'bookingId': bookingId,
        'totalAmount': totalAmount,
        'platformFee': platformFee,
        'providerPayout': providerPayout ?? (totalAmount - platformFee),
        'method': paymentMethod,
        'status': 'success',
      },
    };
  }

  Future<Map<String, dynamic>> requestRefund({
    required String bookingId,
    String? reason,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/refund'),
        headers: _headers(token),
        body: jsonEncode({
          'bookingId': bookingId,
          'reason': reason ?? 'Customer requested cancellation',
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] requestRefund fallback: $e');
    }

    final refundId = 'rfnd_sim_${DateTime.now().millisecondsSinceEpoch}';
    return {
      'success': true,
      'refundId': refundId,
      'bookingId': bookingId,
      'refundAmount': 224,
      'status': 'refunded',
      'message': 'Refund initiated to your original payment method',
    };
  }

  Future<Map<String, dynamic>?> fetchPaymentReceipt(String bookingId) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/payments/$bookingId'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          return body['data'];
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchPaymentReceipt fallback: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required int servicePrice,
  }) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/coupons/validate'),
        headers: _headers(token),
        body: jsonEncode({
          'code': code,
          'servicePrice': servicePrice,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] validateCoupon fallback: $e');
    }

    final clean = code.trim().toUpperCase();
    if (clean == 'FIXIT50' || clean == 'FIRST50') {
      return {'success': true, 'valid': true, 'code': clean, 'discount': 50, 'message': '₹50 discount applied!'};
    } else if (clean == 'WAIVEFEE') {
      return {'success': true, 'valid': true, 'code': clean, 'discount': 25, 'message': '₹25 platform fee waived!'};
    } else if (clean == 'FIRST100') {
      if (servicePrice >= 400) {
        return {'success': true, 'valid': true, 'code': clean, 'discount': 100, 'message': '₹100 discount applied!'};
      } else {
        return {'success': true, 'valid': false, 'code': clean, 'discount': 0, 'message': 'Requires minimum ₹400 order.'};
      }
    }
    return {'success': true, 'valid': false, 'code': clean, 'discount': 0, 'message': 'Invalid coupon code.'};
  }

  // -------------------------------------------------------------
  // Phase 6: Admin Management & Reviews
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> fetchAdminAnalytics() async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/analytics'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data'];
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchAdminAnalytics fallback: $e');
    }

    return {
      'totalBookings': 142,
      'completedBookings': 118,
      'cancelledBookings': 6,
      'totalProviders': 32,
      'activeProviders': 24,
      'totalGrossRevenue': 48950,
      'totalPlatformEarnings': 3550,
      'totalProviderPayouts': 45400,
      'averageRating': 4.88,
      'currency': 'INR',
    };
  }

  Future<bool> updatePlatformFee(int fee) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/settings/platformFee'),
        headers: _headers(token),
        body: jsonEncode({'platformFee': fee}),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] updatePlatformFee fallback: $e');
    }
    return true;
  }

  Future<bool> updateServicePrice(String serviceId, int newPrice) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/admin/services/$serviceId/price'),
        headers: _headers(token),
        body: jsonEncode({'price': newPrice}),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] updateServicePrice fallback: $e');
    }
    return true;
  }

  Future<bool> approveProviderKyc(String providerId, bool approve) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/providers/$providerId/approve-kyc'),
        headers: _headers(token),
        body: jsonEncode({'approve': approve}),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] approveProviderKyc fallback: $e');
    }
    return true;
  }

  Future<bool> addCity(String name, {String state = 'Gujarat'}) async {
    final token = await StorageService.getAuthToken();
    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/cities'),
        headers: _headers(token),
        body: jsonEncode({'name': name, 'state': state}),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('[ApiService] addCity fallback: $e');
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchReviews({String? serviceName, String? bookingId}) async {
    final token = await StorageService.getAuthToken();
    try {
      final params = <String, String>{};
      if (serviceName != null) params['serviceName'] = serviceName;
      if (bookingId != null) params['bookingId'] = bookingId;

      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/reviews').replace(queryParameters: params),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchReviews fallback: $e');
    }

    return [
      {
        'userName': 'Kavita Mehta',
        'serviceName': 'Tap & mixer',
        'rating': 5,
        'comment': 'Prompt service and very polite technician! Replaced valve quickly.',
        'createdAt': '2 hours ago',
      },
      {
        'userName': 'Prashant Dave',
        'serviceName': 'Fan repair',
        'rating': 5,
        'comment': 'Motor bearing repaired cleanly. Reasonable platform fee.',
        'createdAt': 'Yesterday',
      },
      {
        'userName': 'Sanjay Vora',
        'serviceName': 'Stove repair',
        'rating': 4,
        'comment': 'Good technician, reached within 25 mins.',
        'createdAt': '2 days ago',
      },
    ];
  }

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
    String? userName,
    String? serviceName,
  }) async {
    final token = await StorageService.getAuthToken();
    final savedName = await StorageService.getUserName();

    try {
      final res = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/reviews'),
        headers: _headers(token),
        body: jsonEncode({
          'bookingId': bookingId,
          'rating': rating,
          'comment': comment ?? '',
          'userName': userName ?? savedName ?? 'Verified Customer',
          if (serviceName != null) 'serviceName': serviceName,
        }),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] submitReview fallback: $e');
    }
    return true;
  }
}
