import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';

class AdminPanelScreen extends StatefulWidget {
  final String city;

  const AdminPanelScreen({super.key, this.city = 'Rajkot'});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentPlatformFee = platformFee;
  final TextEditingController _feeController = TextEditingController();
  String bookingFilter = 'All';

  // Mock Providers for Admin
  final List<Map<String, dynamic>> providers = [
    {'name': 'Ramesh Sharma', 'skill': 'Electrician', 'city': 'Rajkot', 'phone': '+91 98250 11223', 'status': 'Verified', 'online': true, 'jobs': 142, 'rating': 4.9},
    {'name': 'Haresh Solanki', 'skill': 'Plumber', 'city': 'Rajkot', 'phone': '+91 98250 22334', 'status': 'Verified', 'online': true, 'jobs': 98, 'rating': 4.8},
    {'name': 'Kanti Mistry', 'skill': 'Carpenter', 'city': 'Rajkot', 'phone': '+91 98250 33445', 'status': 'Verified', 'online': false, 'jobs': 76, 'rating': 4.9},
    {'name': 'Jignesh Makwana', 'skill': 'Gas Repair', 'city': 'Rajkot', 'phone': '+91 98250 44556', 'status': 'Verified', 'online': true, 'jobs': 64, 'rating': 4.7},
    {'name': 'Deepak Vaghela', 'skill': 'AC Repair', 'city': 'Rajkot', 'phone': '+91 98250 55667', 'status': 'Pending Approval', 'online': false, 'jobs': 0, 'rating': 5.0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _feeController.text = currentPlatformFee.toString();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void updatePlatformFee() {
    final parsed = int.tryParse(_feeController.text.trim());
    if (parsed != null && parsed >= 0) {
      setState(() {
        currentPlatformFee = parsed;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Platform Fee updated to ₹$parsed per service successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('FixIt Admin Console', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                Text('HQ Dashboard • Gujarat Operations', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined, size: 20), text: 'Overview'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'All Bookings'),
            Tab(icon: Icon(Icons.badge_outlined, size: 20), text: 'Providers'),
            Tab(icon: Icon(Icons.tune_rounded, size: 20), text: 'Platform Fee'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildBookingsTab(),
          _buildProvidersTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: OVERVIEW ANALYTICS
  // -------------------------------------------------------------
  Widget _buildOverviewTab() {
    return ListenableBuilder(
      listenable: BookingStore.instance,
      builder: (context, _) {
        final all = BookingStore.instance.bookings;
        final completed = all.where((b) => b.status == 'Completed').length;
        final upcoming = all.where((b) => b.status == 'Upcoming').length;
        final totalGmv = all.where((b) => b.status != 'Cancelled').fold<int>(0, (sum, b) => sum + b.totalAmount);
        final totalFees = all.where((b) => b.status != 'Cancelled').fold<int>(0, (sum, b) => sum + b.platformFee);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Revenue Highlights
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Gross Booking Value',
                    value: '₹$totalGmv',
                    subtext: '${all.length} Total Bookings',
                    icon: Icons.payments_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Platform Earnings',
                    value: '₹$totalFees',
                    subtext: '₹$currentPlatformFee Fee/Order',
                    icon: Icons.account_balance_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Orders',
                    value: '$upcoming',
                    subtext: 'In Progress / Assigned',
                    icon: Icons.pending_actions_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Completed Orders',
                    value: '$completed',
                    subtext: '99.2% Satisfaction',
                    icon: Icons.task_alt_rounded,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live Network Status
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
                  const Text('Marketplace Health & Live Operations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 14),
                  _buildHealthRow('Operating Cities', '${cities.length} Active Hubs', Colors.green),
                  _buildHealthRow('Active Service Categories', '${categories.length} Categories Live', AppTheme.primaryBlue),
                  _buildHealthRow('Verified Technicians Online', '4 Active in Rajkot', Colors.green),
                  _buildHealthRow('Average Customer Rating', '★ 4.88 / 5.00', Colors.amber),
                  _buildHealthRow('Current Platform Fee Policy', '₹$currentPlatformFee per confirmed service', AppTheme.primaryBlue),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            const Text('Quick Operations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tabController.animateTo(1),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text('View Orders'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tabController.animateTo(3),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Update Fee'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: LIVE BOOKINGS
  // -------------------------------------------------------------
  Widget _buildBookingsTab() {
    return ListenableBuilder(
      listenable: BookingStore.instance,
      builder: (context, _) {
        final all = BookingStore.instance.bookings;
        final list = bookingFilter == 'All'
            ? all
            : all.where((b) => b.status == bookingFilter).toList();

        return Column(
          children: [
            // Filter Bar
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in ['All', 'Upcoming', 'Completed', 'Cancelled'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: bookingFilter == f,
                        selectedColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: bookingFilter == f ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (sel) {
                          if (sel) setState(() => bookingFilter = f);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            Expanded(
              child: list.isEmpty
                  ? Center(child: Text('No $bookingFilter orders found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final b = list[i];
                        final isUpcoming = b.status == 'Upcoming';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.cardBorder),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    b.id,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (b.status == 'Completed'
                                              ? Colors.green
                                              : b.status == 'Cancelled'
                                                  ? Colors.red
                                                  : Colors.blue)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      b.status,
                                      style: TextStyle(
                                        color: b.status == 'Completed'
                                            ? Colors.green
                                            : b.status == 'Cancelled'
                                                ? Colors.red
                                                : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b.serviceName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${b.dateTime} • ${b.city}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              const Divider(height: 20, color: Color(0xFFF1F5F9)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Service: ₹${b.price} + Fee: ₹${b.platformFee}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                      Text(
                                        'Total: ₹${b.totalAmount} (${b.paymentMethod})',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  if (isUpcoming)
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        // Mark as completed from admin
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Order ${b.id} marked as Completed by Admin.'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: const Text('Mark Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 3: PROVIDER MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildProvidersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Registered Technicians', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${providers.length} Partners in ${widget.city}',
                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final p in providers)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.handyman_rounded, color: AppTheme.primaryBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: (p['online'] as bool) ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${p['skill']} • ${p['phone']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          Text(' ${p['rating']} • ${p['jobs']} jobs completed', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (p['status'] == 'Verified' ? Colors.green : Colors.orange).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p['status'] as String,
                    style: TextStyle(
                      color: p['status'] == 'Verified' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: PLATFORM FEE CONFIGURATION
  // -------------------------------------------------------------
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                children: const [
                  Icon(Icons.monetization_on_rounded, color: AppTheme.primaryBlue, size: 24),
                  SizedBox(width: 10),
                  Text('Dynamic Platform Fee Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'This fee is added to every customer booking across all 16 categories. The platform earns 100% of this fee without deducting provider earnings.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CURRENT LIVE FEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                        SizedBox(height: 2),
                        Text('Active Across All Hubs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      '₹$currentPlatformFee',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Update New Platform Fee (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter amount (e.g. 25, 30, 50)',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: updatePlatformFee,
                    child: const Text('Update Fee'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Fee Economics Breakdown
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
              const Text('Fee Economics Projection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              _buildEconomicsRow('100 Bookings / Day', '₹${100 * currentPlatformFee} / day platform revenue'),
              _buildEconomicsRow('500 Bookings / Day', '₹${500 * currentPlatformFee} / day platform revenue'),
              _buildEconomicsRow('2,000 Bookings / Day', '₹${2000 * currentPlatformFee} / day platform revenue'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: color)),
          const SizedBox(height: 4),
          Text(subtext, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _buildEconomicsRow(String volume, String earning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(volume, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          Text(earning, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
        ],
      ),
    );
  }
}
