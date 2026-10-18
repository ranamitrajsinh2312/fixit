import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import 'booking_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Category category;
  final Service service;
  final String city;

  const ServiceDetailScreen({
    super.key,
    required this.category,
    required this.service,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    final mrp = (service.price * 1.35).round();
    final total = service.price + platformFee;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: Text(service.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Banner
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withValues(alpha: 0.18),
                  category.color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: category.color.withValues(alpha: 0.2)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: category.color.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(category.icon, size: 60, color: category.color),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          city,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Title & Pricing Row
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.desc,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹${service.price}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹$mrp',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 13,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '+ ₹25 platform fee',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${service.rating} (${service.reviewsCount} verified reviews)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '30-Day Guarantee',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // What's Included Card
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
                  "What's Included",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 12),
                for (final item in service.included)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.green, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Spare parts or major replacement components are charged extra at MRP.',
                          style: TextStyle(fontSize: 11, color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // How It Works Timeline
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
                  'How FixIt Works',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 14),
                _buildTimelineStep('1', 'Schedule your slot', 'Select your address and 2-hour convenient arrival window.'),
                _buildTimelineStep('2', 'Expert visits & inspects', 'Background-verified pro arrives with safety gear and diagnosis tools.'),
                _buildTimelineStep('3', 'Pay after completion', 'Pay securely with UPI/Card or Cash. 30-day rework warranty begins.'),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated Total', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  Text(
                    '₹$total',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(
                        category: category,
                        service: service,
                        city: city,
                      ),
                    ),
                  ),
                  child: const Text('Schedule Service'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String number, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
