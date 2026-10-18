import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import '../services/api_service.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Category category;
  final Service service;
  final String address;
  final String when;
  final String city;

  const CheckoutScreen({
    super.key,
    required this.category,
    required this.service,
    required this.address,
    required this.when,
    required this.city,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentCategory = 'UPI'; // 'UPI', 'Card', 'NetBanking', 'Cash'
  String selectedUpiApp = 'Google Pay';
  String customUpiId = '';
  String cardLast4 = '4242';
  String cardHolder = 'DEVANG PATEL';
  String cardExpiry = '12/28';
  String selectedBank = 'HDFC Bank';

  int dynamicFee = platformFee;
  int discount = 0;
  String appliedCoupon = '';
  bool _isSubmitting = false;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFee();
  }

  Future<void> _loadFee() async {
    final fee = await ApiService.instance.fetchPlatformFee();
    if (mounted) {
      setState(() => dynamicFee = fee);
    }
  }

  Future<void> applyCoupon(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return;

    final result = await ApiService.instance.validateCoupon(
      code: clean,
      servicePrice: widget.service.price,
    );

    if (!mounted) return;

    if (result['valid'] == true) {
      final disc = (result['discount'] as num?)?.toInt() ?? 0;
      setState(() {
        discount = disc;
        appliedCoupon = clean;
        _couponController.text = clean;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${result['message']}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Invalid coupon code.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void removeCoupon() {
    setState(() {
      discount = 0;
      appliedCoupon = '';
      _couponController.clear();
    });
  }

  String get computedPaymentMethodLabel {
    switch (paymentCategory) {
      case 'UPI':
        return customUpiId.isNotEmpty ? 'UPI ($customUpiId)' : 'UPI ($selectedUpiApp)';
      case 'Card':
        return 'Card (ending in $cardLast4)';
      case 'NetBanking':
        return 'Net Banking ($selectedBank)';
      case 'Cash':
      default:
        return 'Cash after service';
    }
  }

  void _showUpiSelectionSheet() {
    final upiApps = [
      {'name': 'Google Pay', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF4285F4)},
      {'name': 'PhonePe', 'icon': Icons.mobile_friendly_rounded, 'color': Color(0xFF5F259F)},
      {'name': 'Paytm UPI', 'icon': Icons.payment_rounded, 'color': Color(0xFF00B9F5)},
      {'name': 'BHIM UPI', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF00796B)},
    ];

    final upiInputController = TextEditingController(text: customUpiId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select UPI App or ID',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final app in upiApps) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (app['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(app['icon'] as IconData, color: app['color'] as Color, size: 22),
                  ),
                  title: Text(
                    app['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  trailing: selectedUpiApp == app['name'] && customUpiId.isEmpty
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                      : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      paymentCategory = 'UPI';
                      selectedUpiApp = app['name'] as String;
                      customUpiId = '';
                    });
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 8, color: Color(0xFFF1F5F9)),
              ],
              const SizedBox(height: 12),
              const Text(
                'Or Enter UPI ID (VPA)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: upiInputController,
                      decoration: InputDecoration(
                        hintText: 'e.g. yourname@okhdfcbank',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final val = upiInputController.text.trim();
                      if (val.isNotEmpty && val.contains('@')) {
                        setState(() {
                          paymentCategory = 'UPI';
                          customUpiId = val;
                          selectedUpiApp = 'Custom UPI';
                        });
                        Navigator.pop(ctx);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid UPI ID with @')),
                        );
                      }
                    },
                    child: const Text('Verify'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCardDetailsModal() {
    final numController = TextEditingController(text: '4242 4242 4242 $cardLast4');
    final expController = TextEditingController(text: cardExpiry);
    final cvvController = TextEditingController(text: '888');
    final nameController = TextEditingController(text: cardHolder);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Card Payment (Razorpay)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Virtual Card Visualizer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.nfc_rounded, color: Colors.white70, size: 28),
                        Text('VISA / RuPay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      numController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cardHolder, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('EXP: $cardExpiry', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: const Icon(Icons.credit_card_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expController,
                      decoration: InputDecoration(
                        labelText: 'Valid Thru (MM/YY)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final cleanNum = numController.text.replaceAll(' ', '');
                    setState(() {
                      paymentCategory = 'Card';
                      cardLast4 = cleanNum.length >= 4 ? cleanNum.substring(cleanNum.length - 4) : '4242';
                      cardExpiry = expController.text;
                      cardHolder = nameController.text.toUpperCase();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Card & Proceed'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNetBankingModal() {
    final banks = ['HDFC Bank', 'State Bank of India', 'ICICI Bank', 'Axis Bank', 'Kotak Mahindra Bank', 'Bank of Baroda'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Your Bank', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 12),
              for (final bank in banks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryBlue),
                  title: Text(bank, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: selectedBank == bank
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      paymentCategory = 'NetBanking';
                      selectedBank = bank;
                    });
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> confirmBooking() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final subtotal = widget.service.price + dynamicFee;
    final total = (subtotal - discount).clamp(0, 999999);
    final chosenMethod = computedPaymentMethodLabel;

    // Show gateway processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Securing Transaction...',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              paymentCategory == 'Cash'
                  ? 'Confirming cash on delivery booking...'
                  : 'Connecting to Razorpay & verifying $chosenMethod...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    try {
      // 1. Create Gateway Order
      final orderResult = await ApiService.instance.createPaymentOrder(
        serviceId: widget.service.id,
        couponCode: appliedCoupon,
        city: widget.city,
        customPrice: widget.service.price,
      );

      final orderId = orderResult['orderId']?.toString() ?? 'order_sim_${DateTime.now().millisecondsSinceEpoch}';

      // 2. Create Booking
      final booking = await ApiService.instance.createBooking(
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        categoryName: widget.category.name,
        price: widget.service.price,
        address: widget.address,
        city: widget.city,
        dateTime: widget.when,
        paymentMethod: chosenMethod,
        discount: discount,
        couponCode: appliedCoupon,
        transactionId: paymentCategory == 'Cash' ? '' : 'pay_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 3. Verify Payment if online
      if (paymentCategory != 'Cash') {
        await ApiService.instance.verifyPayment(
          orderId: orderId,
          paymentId: 'pay_rzp_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          bookingId: booking.id,
          paymentMethod: chosenMethod,
          totalAmount: total,
          platformFee: dynamicFee,
          providerPayout: widget.service.price,
          discount: discount,
          couponCode: appliedCoupon,
        );
      }

      if (!mounted) return;
      Navigator.pop(context); // Close processing dialog

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            booking: booking,
            city: widget.city,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment or booking failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.service.price + dynamicFee;
    final total = (subtotal - discount).clamp(0, 999999);

    final paymentOptions = [
      {
        'key': 'UPI',
        'title': 'UPI (Instant & Free)',
        'subtitle': customUpiId.isNotEmpty ? customUpiId : '$selectedUpiApp • GPay, PhonePe, Paytm',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF4F46E5),
        'onTap': _showUpiSelectionSheet,
      },
      {
        'key': 'Card',
        'title': 'Credit / Debit Card',
        'subtitle': 'Visa, Mastercard, RuPay (ending in $cardLast4)',
        'icon': Icons.credit_card_rounded,
        'color': const Color(0xFF2563EB),
        'onTap': _showCardDetailsModal,
      },
      {
        'key': 'NetBanking',
        'title': 'Net Banking',
        'subtitle': selectedBank,
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF0284C7),
        'onTap': _showNetBankingModal,
      },
      {
        'key': 'Cash',
        'title': 'Cash after service',
        'subtitle': 'Pay directly to technician after job completion',
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF059669),
        'onTap': () => setState(() => paymentCategory = 'Cash'),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: const Text('Review & Pay'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.category.icon, color: widget.category.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
                          ),
                          Text(
                            '${widget.category.name} • ${widget.city}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${widget.service.price}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.when,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                          ),
                          if (widget.when.contains('Instant')) ...[
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF59E0B)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFB45309)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Blinkit-Style Instant Dispatch: Tech arrives in 15–30 mins',
                                    style: TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Coupon Code Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.local_offer_rounded, color: AppTheme.primaryBlue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Coupons & Offers',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (appliedCoupon.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '"$appliedCoupon" applied! Saved ₹$discount',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: removeCoupon,
                          child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Enter coupon (e.g. FIXIT50)',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(80, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => applyCoupon(_couponController.text),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick coupon tags
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.primaryBlue),
                        label: const Text('FIXIT50 (Save ₹50)', style: TextStyle(fontSize: 11)),
                        onPressed: () => applyCoupon('FIXIT50'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.money_off_rounded, size: 14, color: Colors.green),
                        label: const Text('WAIVEFEE (Zero Fee)', style: TextStyle(fontSize: 11)),
                        onPressed: () => applyCoupon('WAIVEFEE'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Invoice Receipt Breakdown Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark),
                ),
                const SizedBox(height: 12),
                _buildPriceRow('Service Charge (Labor)', '₹${widget.service.price}'),
                _buildPriceRow('Platform Booking Fee', '₹$dynamicFee'),
                if (discount > 0)
                  _buildPriceRow('Coupon Discount ($appliedCoupon)', '-₹$discount', color: Colors.green),
                _buildPriceRow('Technician Insurance & Warranty', 'FREE', color: Colors.green),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildPriceRow('Total Payable', '₹$total', isBold: true),
                const SizedBox(height: 6),
                Text(
                  '100% of service charge (₹${widget.service.price}) goes directly to your verified technician.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark),
              ),
              Text(
                'Razorpay Gateway',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 10),

          for (final opt in paymentOptions) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                boxShadow: AppTheme.softShadow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: paymentCategory == opt['key'] ? AppTheme.primaryBlue : AppTheme.cardBorder,
                    width: paymentCategory == opt['key'] ? 1.5 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () {
                    setState(() => paymentCategory = opt['key'] as String);
                    final cb = opt['onTap'] as VoidCallback?;
                    if (cb != null) cb();
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (opt['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 20),
                  ),
                  title: Text(
                    opt['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    opt['subtitle'] as String,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  trailing: paymentCategory == opt['key']
                      ? const Icon(Icons.radio_button_checked_rounded, color: AppTheme.primaryBlue)
                      : const Icon(Icons.radio_button_off_rounded, color: Colors.grey),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Security Shield Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user_rounded, color: AppTheme.primaryBlue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '256-bit Encrypted Checkout • Instant Refund Guarantee on Cancellation',
                    style: TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            boxShadow: AppTheme.softShadow,
          ),
          child: FilledButton(
            onPressed: confirmBooking,
            child: Text(
              paymentCategory == 'Cash'
                  ? 'Confirm Booking • Pay ₹$total on Service'
                  : 'Pay & Confirm Booking • ₹$total',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              fontSize: isBold ? 16 : 13,
              color: color ?? (isBold ? AppTheme.textDark : AppTheme.textMuted),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: isBold ? 19 : 13,
              color: color ?? (isBold ? AppTheme.primaryBlue : AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
