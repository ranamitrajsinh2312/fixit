import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import '../services/api_service.dart';

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
  final TextEditingController _newCityController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();

  String bookingFilter = 'All';
  String _selectedServiceId = 'elec_fan';
  String _selectedServiceName = 'Ceiling Fan Repair & Installation';

  Map<String, dynamic>? _remoteAnalytics;
  bool _isLoadingAnalytics = false;

  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = false;
  String _reviewFilter = 'All';

  // Technicians / Service Partners
  late List<Map<String, dynamic>> providers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _feeController.text = currentPlatformFee.toString();

    providers = [
      {'id': 'p1', 'name': 'Ramesh Sharma', 'skill': 'Electrician', 'city': 'Rajkot', 'phone': '+91 98250 11223', 'status': 'Verified', 'online': true, 'jobs': 142, 'rating': 4.9},
      {'id': 'p2', 'name': 'Haresh Solanki', 'skill': 'Plumber', 'city': 'Rajkot', 'phone': '+91 98250 22334', 'status': 'Verified', 'online': true, 'jobs': 98, 'rating': 4.8},
      {'id': 'p3', 'name': 'Kanti Mistry', 'skill': 'Carpenter', 'city': 'Rajkot', 'phone': '+91 98250 33445', 'status': 'Verified', 'online': false, 'jobs': 76, 'rating': 4.9},
      {'id': 'p4', 'name': 'Jignesh Makwana', 'skill': 'Gas Repair', 'city': 'Rajkot', 'phone': '+91 98250 44556', 'status': 'Verified', 'online': true, 'jobs': 64, 'rating': 4.7},
      {'id': 'p5', 'name': 'Deepak Vaghela', 'skill': 'AC Repair', 'city': 'Rajkot', 'phone': '+91 98250 55667', 'status': 'Pending Approval', 'online': false, 'jobs': 0, 'rating': 5.0},
      {'id': 'p6', 'name': 'Mahesh Chudasama', 'skill': 'Towing & RSA', 'city': 'Rajkot', 'phone': '+91 98250 66778', 'status': 'Pending Approval', 'online': true, 'jobs': 12, 'rating': 4.6},
    ];

    _initSelectedService();
    _fetchAnalytics();
    _fetchReviews();
  }

  void _initSelectedService() {
    for (final cat in categories) {
      for (final s in cat.services) {
        if (s.id == _selectedServiceId) {
          _selectedServiceName = s.name;
          _servicePriceController.text = s.price.toString();
          return;
        }
      }
    }
    final firstService = categories.first.services.first;
    _selectedServiceId = firstService.id;
    _selectedServiceName = firstService.name;
    _servicePriceController.text = firstService.price.toString();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feeController.dispose();
    _newCityController.dispose();
    _servicePriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    final data = await ApiService.instance.fetchAdminAnalytics();
    if (mounted) {
      setState(() {
        _remoteAnalytics = data;
        _isLoadingAnalytics = false;
      });
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    final list = await ApiService.instance.fetchReviews();
    if (mounted) {
      setState(() {
        _reviews = list;
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _handleUpdatePlatformFee() async {
    final parsed = int.tryParse(_feeController.text.trim());
    if (parsed != null && parsed >= 0) {
      await ApiService.instance.updatePlatformFee(parsed);
      setState(() {
        currentPlatformFee = parsed;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Dynamic Platform Fee updated to ₹$parsed per service!'),
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

  Future<void> _handleUpdateServicePrice() async {
    final parsedPrice = int.tryParse(_servicePriceController.text.trim());
    if (parsedPrice == null || parsedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid service price'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    await ApiService.instance.updateServicePrice(_selectedServiceId, parsedPrice);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Catalog price for "$_selectedServiceName" updated to ₹$parsedPrice!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleAddCity() async {
    final name = _newCityController.text.trim();
    if (name.isEmpty) return;

    final success = await ApiService.instance.addCity(name);
    if (success) {
      if (!cities.contains(name)) {
        setState(() {
          cities.add(name);
        });
      }
      _newCityController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 $name added to FixIt operational hubs!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleProviderKyc(Map<String, dynamic> provider, bool approve) async {
    final providerId = provider['id'] as String? ?? 'p1';
    final newStatus = approve ? 'Verified' : 'Rejected';

    await ApiService.instance.approveProviderKyc(providerId, approve);

    setState(() {
      provider['status'] = newStatus;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approve
            ? '✅ ${provider['name']} KYC approved & verified for service dispatches!'
            : '⚠️ ${provider['name']} KYC rejected.'),
        backgroundColor: approve ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        actions: [
          IconButton(
            tooltip: 'Refresh Analytics & Reviews',
            icon: _isLoadingAnalytics
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue))
                : const Icon(Icons.refresh_rounded),
            onPressed: () {
              _fetchAnalytics();
              _fetchReviews();
            },
          ),
        ],
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
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'Bookings'),
            Tab(icon: Icon(Icons.badge_outlined, size: 20), text: 'Technicians & KYC'),
            Tab(icon: Icon(Icons.tune_rounded, size: 20), text: 'Catalog & Fees'),
            Tab(icon: Icon(Icons.star_half_rounded, size: 20), text: 'Reviews'),
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
          _buildReviewsTab(),
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
        final localGmv = all.where((b) => b.status != 'Cancelled').fold<int>(0, (sum, b) => sum + b.totalAmount);
        final localFees = all.where((b) => b.status != 'Cancelled').fold<int>(0, (sum, b) => sum + b.platformFee);

        final displayGmv = _remoteAnalytics != null && _remoteAnalytics!['totalGrossRevenue'] != null
            ? _remoteAnalytics!['totalGrossRevenue']
            : localGmv;
        final displayEarnings = _remoteAnalytics != null && _remoteAnalytics!['totalPlatformEarnings'] != null
            ? _remoteAnalytics!['totalPlatformEarnings']
            : localFees;
        final displayRating = _remoteAnalytics != null && _remoteAnalytics!['averageRating'] != null
            ? _remoteAnalytics!['averageRating']
            : 4.88;
        final displayActivePros = _remoteAnalytics != null && _remoteAnalytics!['activeProviders'] != null
            ? _remoteAnalytics!['activeProviders']
            : 24;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Revenue Highlights
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Gross Booking Value',
                    value: '₹$displayGmv',
                    subtext: '${all.length} Orders Recorded',
                    icon: Icons.payments_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Platform Earnings',
                    value: '₹$displayEarnings',
                    subtext: '₹$currentPlatformFee Platform Fee',
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
                    subtext: 'Assigned / In Progress',
                    icon: Icons.pending_actions_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Customer Rating',
                    value: '★ $displayRating',
                    subtext: 'Across Verified Jobs',
                    icon: Icons.star_rounded,
                    color: Colors.amber,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Marketplace Health & Live Operations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Live Sync', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildHealthRow('Operating Cities', '${cities.length} Active Hubs', Colors.green),
                  _buildHealthRow('Active Service Categories', '${categories.length} Categories Live', AppTheme.primaryBlue),
                  _buildHealthRow('Verified Technicians Online', '$displayActivePros Active in Gujarat', Colors.green),
                  _buildHealthRow('Average Customer Rating', '★ $displayRating / 5.00', Colors.amber),
                  _buildHealthRow('Current Platform Fee Policy', '₹$currentPlatformFee per confirmed service', AppTheme.primaryBlue),
                  _buildHealthRow('Completed Jobs', '$completed Orders Done', Colors.teal),
                  _buildHealthRow('Provider Payout Share', '100% of Base Service Price', Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Operations Row
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
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tabController.animateTo(2),
                    icon: const Icon(Icons.verified_user_rounded, size: 18),
                    label: const Text('Review KYC'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tabController.animateTo(3),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Pricing'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: BOOKINGS LIST
  // -------------------------------------------------------------
  Widget _buildBookingsTab() {
    return ListenableBuilder(
      listenable: BookingStore.instance,
      builder: (context, _) {
        final all = BookingStore.instance.bookings;
        final filtered = bookingFilter == 'All' ? all : all.where((b) => b.status == bookingFilter).toList();

        return Column(
          children: [
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
                          fontWeight: bookingFilter == f ? FontWeight.bold : FontWeight.normal,
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
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No orders matching filter', style: TextStyle(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        final isUpcoming = b.status == 'Upcoming';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                        'Technician: ₹${b.price} + Fee: ₹${b.platformFee}',
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
                                        BookingStore.instance.updateBookingStatus(b.id, 'Completed');
                                        ApiService.instance.updateBookingStatus(b.id, 'completed');
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
  // TAB 3: PROVIDER MANAGEMENT & KYC
  // -------------------------------------------------------------
  Widget _buildProvidersTab() {
    final pendingCount = providers.where((p) => p['status'] != 'Verified').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Technician Network & KYC', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (pendingCount > 0 ? Colors.orange : Colors.green).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                pendingCount > 0 ? '$pendingCount Pending KYC' : 'All Verified',
                style: TextStyle(
                  color: pendingCount > 0 ? Colors.orange.shade800 : Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
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
            child: Column(
              children: [
                Row(
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
                        color: (p['status'] == 'Verified' ? Colors.green : (p['status'] == 'Rejected' ? Colors.red : Colors.orange))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p['status'] as String,
                        style: TextStyle(
                          color: p['status'] == 'Verified' ? Colors.green : (p['status'] == 'Rejected' ? Colors.red : Colors.orange),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (p['status'] != 'Verified') ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _toggleProviderKyc(p, false),
                        child: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 14),
                        onPressed: () => _toggleProviderKyc(p, true),
                        label: const Text('Approve KYC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        icon: const Icon(Icons.block_rounded, size: 14),
                        onPressed: () => _toggleProviderKyc(p, false),
                        label: const Text('Revoke Verification', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: CATALOG PRICING & PLATFORM FEE SETTINGS
  // -------------------------------------------------------------
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Platform Fee Card
        Container(
          padding: const EdgeInsets.all(18),
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
                  Icon(Icons.monetization_on_rounded, color: AppTheme.primaryBlue, size: 22),
                  SizedBox(width: 10),
                  Text('Dynamic Platform Fee Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'This fee is added to every customer booking. 100% of this fee goes directly to platform operations without deducting provider earnings.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
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
                        Text('Active Across All Hubs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      '₹$currentPlatformFee',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'New Fee (e.g. 25, 30)',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _handleUpdatePlatformFee,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Update Fee'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Service Catalog Price Adjustment
        Container(
          padding: const EdgeInsets.all(18),
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
                  Icon(Icons.sell_rounded, color: AppTheme.primaryBlue, size: 22),
                  SizedBox(width: 10),
                  Text('Service Catalog Price Modifier', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Adjust the base price for specific catalog services. Technician receives 100% of this adjusted rate.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              // Service Selector Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedServiceId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Service to Update',
                ),
                items: [
                  for (final cat in categories)
                    for (final s in cat.services.take(2))
                      DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} (Current: ₹${s.price})', style: const TextStyle(fontSize: 13)),
                      ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedServiceId = val;
                      for (final cat in categories) {
                        for (final s in cat.services) {
                          if (s.id == val) {
                            _selectedServiceName = s.name;
                            _servicePriceController.text = s.price.toString();
                            break;
                          }
                        }
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _servicePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'New Base Price',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _handleUpdateServicePrice,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Update Price'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Add City Card
        Container(
          padding: const EdgeInsets.all(18),
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
                  Icon(Icons.add_location_alt_rounded, color: AppTheme.primaryBlue, size: 22),
                  SizedBox(width: 10),
                  Text('Expand Operational Cities', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Add new cities to FixIt network (currently ${cities.length} operational hubs across Gujarat).',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCityController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Navsari, Anand, Morbi',
                        prefixIcon: Icon(Icons.location_city_rounded, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _handleAddCity,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Add City'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 5: REVIEWS MODERATION & FEEDBACK
  // -------------------------------------------------------------
  Widget _buildReviewsTab() {
    final filtered = _reviewFilter == 'All'
        ? _reviews
        : _reviews.where((r) => '${r['rating']} Stars' == _reviewFilter || (r['rating'] as int) == int.tryParse(_reviewFilter.split(' ').first)).toList();

    return Column(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final f in ['All', '5 Stars', '4 Stars', '3 Stars'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _reviewFilter == f,
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: _reviewFilter == f ? Colors.white : AppTheme.textDark,
                      fontWeight: _reviewFilter == f ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (sel) {
                      if (sel) setState(() => _reviewFilter = f);
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingReviews
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('No reviews found for this filter.', style: TextStyle(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        final rating = (r['rating'] as num?)?.toInt() ?? 5;
                        final userName = r['userName'] as String? ?? 'Verified Customer';
                        final serviceName = r['serviceName'] as String? ?? 'Home Repair';
                        final comment = r['comment'] as String? ?? 'Great experience!';
                        final date = r['createdAt'] as String? ?? 'Recently';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                        child: Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text(date, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                        const SizedBox(width: 2),
                                        Text('$rating.0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFB45309))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Service: $serviceName', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comment,
                                style: const TextStyle(fontSize: 13, height: 1.3, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        );
                      },
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
}
