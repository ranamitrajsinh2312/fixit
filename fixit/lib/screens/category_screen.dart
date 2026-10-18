import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import 'service_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  final Category category;
  final String city;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.primaryBlue),
                const SizedBox(width: 4),
                Text(
                  city,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Category Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withValues(alpha: 0.15),
                  category.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: category.color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: category.color.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(category.icon, color: category.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${category.name} in $city',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Verified experts • Transparent pricing • 30-day warranty',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Services',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '${category.services.length} items',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Services List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = category.services[i];
              final mrp = (s.price * 1.35).round();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: AppTheme.softShadow,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(
                        category: category,
                        service: s,
                        city: city,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.desc,
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
                                      '₹${s.price}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 19,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '₹$mrp',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '+ ₹25 fee',
                                  style: TextStyle(fontSize: 10, color: Colors.black45),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${s.rating} (${s.reviewsCount})',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '30-Day Warranty',
                                style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailScreen(
                                    category: category,
                                    service: s,
                                    city: city,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'View & Book',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
