import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixit/data.dart';
import 'package:fixit/services/api_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 5: Payments, Coupons & Fee Calculations', () {
    test('Platform fee is set to 25 and BookingItem retains labor & fee breakdown', () {
      expect(platformFee, 25);

      final booking = BookingItem(
        id: 'FX-TEST-001',
        serviceName: 'Fan repair',
        categoryName: 'Electrician',
        price: 199,
        platformFee: 25,
        totalAmount: 224,
        address: 'Radhe Residency, Rajkot',
        city: 'Rajkot',
        dateTime: 'Tomorrow, 10 AM',
        paymentMethod: 'UPI',
        paymentStatus: 'paid',
        transactionId: 'pay_test_001',
      );

      expect(booking.price, 199);
      expect(booking.platformFee, 25);
      expect(booking.totalAmount, 224);
      expect(booking.paymentStatus, 'paid');
      expect(booking.transactionId, 'pay_test_001');
    });

    test('BookingItem defaults cash payments to pending status', () {
      final cashBooking = BookingItem(
        id: 'FX-TEST-CASH',
        serviceName: 'Tap repair',
        categoryName: 'Plumber',
        price: 149,
        platformFee: 25,
        totalAmount: 174,
        address: 'Crystal Mall, Rajkot',
        city: 'Rajkot',
        dateTime: 'Today, 2 PM',
        paymentMethod: 'Cash after service',
      );

      expect(cashBooking.paymentStatus, 'pending');
      expect(cashBooking.paymentMethod, 'Cash after service');
    });

    test('BookingStore cancels and records online refund', () {
      final store = BookingStore.instance;
      final testBooking = BookingItem(
        id: 'FX-REFUND-99',
        serviceName: 'MCB Fix',
        categoryName: 'Electrician',
        price: 299,
        platformFee: 25,
        totalAmount: 324,
        address: 'Kalawad Road, Rajkot',
        city: 'Rajkot',
        dateTime: 'Tomorrow, 11 AM',
        paymentMethod: 'UPI (Google Pay)',
        paymentStatus: 'paid',
        transactionId: 'pay_9999',
      );

      store.addBooking(testBooking);
      expect(store.bookings.any((b) => b.id == 'FX-REFUND-99'), isTrue);

      // Trigger refund
      store.refundBooking('FX-REFUND-99', refundId: 'rfnd_custom_123', refundAmount: 324);

      final refunded = store.bookings.firstWhere((b) => b.id == 'FX-REFUND-99');
      expect(refunded.status, 'Cancelled');
      expect(refunded.paymentStatus, 'refunded');
      expect(refunded.refundId, 'rfnd_custom_123');
      expect(refunded.refundAmount, 324);
    });

    test('ApiService validateCoupon calculates discounts for FIXIT50 and WAIVEFEE', () async {
      final res50 = await ApiService.instance.validateCoupon(code: 'FIXIT50', servicePrice: 199);
      expect(res50['valid'], isTrue);
      expect(res50['discount'], 50);

      final resFee = await ApiService.instance.validateCoupon(code: 'WAIVEFEE', servicePrice: 199);
      expect(resFee['valid'], isTrue);
      expect(resFee['discount'], 25);

      final resInvalid = await ApiService.instance.validateCoupon(code: 'FAKECODE', servicePrice: 199);
      expect(resInvalid['valid'], isFalse);
    });

    test('ApiService createPaymentOrder generates valid order breakdown', () async {
      final order = await ApiService.instance.createPaymentOrder(
        serviceId: 'fan_repair',
        customPrice: 200,
        couponCode: 'FIXIT50',
      );

      expect(order['success'], isTrue);
      expect(order['servicePrice'], 200);
      expect(order['platformFee'], 25);
      expect(order['discount'], 50);
      expect(order['totalAmount'], 175); // 200 + 25 - 50 = 175
      expect(order['providerPayout'], 200); // Technician keeps 100% of quote
    });

    test('ApiService requestRefund generates refund reference', () async {
      final refund = await ApiService.instance.requestRefund(
        bookingId: 'FX-91204',
        reason: 'Customer cancelled',
      );

      expect(refund['success'], isTrue);
      expect(refund['status'], 'refunded');
      expect(refund['refundId'] != null, isTrue);
    });
  });
}
