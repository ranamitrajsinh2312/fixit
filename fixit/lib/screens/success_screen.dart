import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import 'main_shell.dart';

class SuccessScreen extends StatelessWidget {
  final BookingItem booking;
  final String city;

  const SuccessScreen({
    super.key,
    required this.booking,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = booking.paymentStatus == 'paid';
    final txnRef = booking.transactionId.isNotEmpty
        ? booking.transactionId
        : 'TXN-${booking.id.replaceAll('FX-', '')}';

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated / Glowing Success Ring
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your service request has been registered.\nA verified technician is being assigned to your location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 22),

                // Order Receipt Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BOOKING ID',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),

                      // Payment Mode & Verification Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.withValues(alpha: 0.08) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPaid ? Colors.green.withValues(alpha: 0.25) : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPaid ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                  size: 16,
                                  color: isPaid ? Colors.green : const Color(0xFFB45309),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPaid ? 'Payment Verified (Online)' : 'Pay Cash After Service',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isPaid ? Colors.green : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              booking.paymentMethod,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildReceiptRow('Service', booking.serviceName),
                      const SizedBox(height: 6),
                      _buildReceiptRow('Slot', booking.dateTime),
                      const SizedBox(height: 6),
                      _buildReceiptRow('City', '$city (Doorstep Pro)'),
                      const SizedBox(height: 6),
                      _buildReceiptRow('Txn Ref', txnRef),

                      const Divider(height: 22, color: Color(0xFFF1F5F9)),

                      // Itemized Breakdown
                      _buildFeeLine('Service Charge (Labor)', '₹${booking.price}'),
                      _buildFeeLine('Platform Booking Fee', '₹${booking.platformFee}'),
                      if (booking.discount > 0)
                        _buildFeeLine(
                          'Coupon Discount (${booking.couponCode.isNotEmpty ? booking.couponCode : "OFFER"})',
                          '-₹${booking.discount}',
                          color: Colors.green,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                          ),
                          Text(
                            '₹${booking.totalAmount}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Technician receives 100% of the labor charge directly.',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                      ),

                      const Divider(height: 22, color: Color(0xFFF1F5F9)),

                      // Live Status Stepper
                      const Text(
                        'Live Order Dispatch',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 10),
                      _buildStatusStep(Icons.check_circle_rounded, 'Order Placed', 'Payment confirmed & slot reserved', true),
                      const SizedBox(height: 8),
                      _buildStatusStep(Icons.sync_rounded, 'Assigning Technician', 'Matching nearest pro in $city', false, isPulsing: true),
                      const SizedBox(height: 8),
                      _buildStatusStep(Icons.home_repair_service_outlined, 'Service Delivery', 'Scheduled for ${booking.dateTime}', false),

                      const SizedBox(height: 14),

                      // Download Tax Invoice simulation
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          side: const BorderSide(color: AppTheme.cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Download Official Tax Invoice', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📄 Tax Invoice for ${booking.id} downloaded successfully.'),
                              backgroundColor: AppTheme.primaryBlue,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                FilledButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainShell(city: city, initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('View in My Bookings'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainShell(city: city, initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeLine(String label, String amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color ?? AppTheme.textMuted)),
          Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildStatusStep(IconData icon, String title, String subtitle, bool isDone, {bool isPulsing = false}) {
    final color = isDone
        ? Colors.green
        : isPulsing
            ? AppTheme.primaryBlue
            : AppTheme.textMuted;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDone || isPulsing ? AppTheme.textDark : AppTheme.textMuted,
                ),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
