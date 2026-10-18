import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import '../services/api_service.dart';

class ServicerScreen extends StatefulWidget {
  final String city;

  const ServicerScreen({super.key, this.city = 'Rajkot'});

  @override
  State<ServicerScreen> createState() => _ServicerScreenState();
}

class _ServicerScreenState extends State<ServicerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isOnline = true;
  String providerId = 'prov_demo_1';
  String partnerName = 'Ramesh Sharma';
  String partnerSkill = 'Electrician';
  String partnerPhone = '+91 98250 11223';
  String kycStatus = 'verified';
  String aadhaarNo = 'XXXX-XXXX-9821';
  int completedJobsCount = 18;
  int totalEarnings = 4850;

  // Local job state tracker for provider workflow simulation
  Map<String, String> jobStatuses = {};

  // Broadcast job pool for technicians in city
  List<BookingItem> broadcastJobs = [
    BookingItem(
      id: 'FX-65120',
      serviceName: 'Switch & socket installation',
      categoryName: 'Electrician',
      price: 149,
      platformFee: 25,
      totalAmount: 174,
      address: 'Plot 45, Mavdi Main Road',
      city: 'Rajkot',
      dateTime: 'Today, 4 PM - 6 PM',
      status: 'pending',
      paymentMethod: 'UPI',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProviderProfile();
  }

  Future<void> _loadProviderProfile() async {
    try {
      final profile = await ApiService.instance.fetchProviderProfile(phone: partnerPhone);
      if (profile != null && mounted) {
        setState(() {
          providerId = profile['_id']?.toString() ?? providerId;
          partnerName = profile['name']?.toString() ?? partnerName;
          partnerSkill = profile['categoryName']?.toString() ?? partnerSkill;
          kycStatus = profile['kycStatus']?.toString() ?? kycStatus;
          isOnline = profile['isOnline'] == true;
          if (profile['completedJobs'] != null) {
            completedJobsCount = (profile['completedJobs'] as num).toInt();
          }
          if (profile['totalEarnings'] != null) {
            totalEarnings = (profile['totalEarnings'] as num).toInt();
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getStatus(BookingItem b) {
    return jobStatuses[b.id] ?? b.status;
  }

  void advanceJobStatus(BookingItem b) async {
    final current = getStatus(b);
    String nextStatus;
    String apiStatus;
    if (current == 'Upcoming' || current == 'assigned' || current == 'pending') {
      nextStatus = 'On the way';
      apiStatus = 'on_the_way';
    } else if (current == 'On the way' || current == 'on_the_way') {
      nextStatus = 'In progress';
      apiStatus = 'in_progress';
    } else if (current == 'In progress' || current == 'in_progress') {
      nextStatus = 'Completed';
      apiStatus = 'completed';
    } else {
      return;
    }

    setState(() {
      jobStatuses[b.id] = nextStatus;
      if (nextStatus == 'Completed') {
        completedJobsCount += 1;
        totalEarnings += b.price;
      }
    });

    BookingStore.instance.updateBookingStatus(b.id, nextStatus);

    // Call live API in background
    await ApiService.instance.updateBookingStatus(b.id, apiStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ Job #${b.id} status updated to "$nextStatus"'),
          backgroundColor: nextStatus == 'Completed' ? Colors.green : AppTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void acceptBroadcastJob(BookingItem b) async {
    final updated = BookingItem(
      id: b.id,
      serviceName: b.serviceName,
      categoryName: b.categoryName,
      price: b.price,
      platformFee: b.platformFee,
      totalAmount: b.totalAmount,
      address: b.address,
      city: b.city,
      dateTime: b.dateTime,
      status: 'Upcoming',
      paymentMethod: b.paymentMethod,
    );

    setState(() {
      broadcastJobs.removeWhere((item) => item.id == b.id);
      jobStatuses[b.id] = 'Upcoming';
    });

    BookingStore.instance.addBooking(updated);

    await ApiService.instance.acceptBooking(
      bookingId: b.id,
      providerId: providerId,
      providerName: partnerName,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Job #${b.id} accepted! Added to your today schedule.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void toggleOnline(bool val) async {
    setState(() => isOnline = val);
    await ApiService.instance.updateProviderStatus(providerId: providerId, isOnline: val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? '🟢 You are Online and receiving live job broadcasts.' : '⚪ You are now Offline.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void showKycDialog() {
    final controller = TextEditingController(text: aadhaarNo);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update KYC Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter 12-digit Aadhaar Number or National ID for partner verification:',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Aadhaar / ID Card No.',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final newId = controller.text.trim();
              Navigator.pop(ctx);
              if (newId.isNotEmpty) {
                setState(() {
                  aadhaarNo = newId;
                  kycStatus = 'verified';
                });
                await ApiService.instance.updateProviderKyc(
                  providerId: providerId,
                  kycStatus: 'verified',
                  aadhaarNo: newId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Aadhaar KYC verified successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Verify & Save'),
          ),
        ],
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
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.amber.withValues(alpha: 0.2),
              child: const Icon(Icons.handyman_rounded, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partnerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text('$partnerSkill • ${widget.city}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                Switch(
                  value: isOnline,
                  activeThumbColor: Colors.green,
                  onChanged: toggleOnline,
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.assignment_outlined, size: 20), text: 'Job Tasks'),
            Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 20), text: 'Earnings'),
            Tab(icon: Icon(Icons.badge_outlined, size: 20), text: 'KYC & Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobTasksTab(),
          _buildEarningsTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: JOB TASKS & LIFECYCLE
  // -------------------------------------------------------------
  Widget _buildJobTasksTab() {
    return ListenableBuilder(
      listenable: BookingStore.instance,
      builder: (context, _) {
        final all = BookingStore.instance.bookings;
        final activeJobs = all.where((b) {
          final s = getStatus(b);
          return s != 'Completed' && s != 'Cancelled';
        }).toList();

        final completedJobs = all.where((b) => getStatus(b) == 'Completed').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Strip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOnline
                      ? [const Color(0xFF065F46), const Color(0xFF059669)]
                      : [const Color(0xFF475569), const Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOnline ? Icons.radar_rounded : Icons.pause_circle_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'Accepting Instant Orders' : 'You are currently Offline',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          isOnline ? 'Jobs in ${widget.city} will be dispatched directly to your app.' : 'Switch online to receive new customer bookings.',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Tasks Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Assigned Work Orders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${activeJobs.length} Active',
                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (activeJobs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green),
                      SizedBox(height: 12),
                      Text('No Pending Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('All assigned tasks for today have been completed!', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              for (final b in activeJobs) ...[
                Builder(
                  builder: (context) {
                    final status = getStatus(b);
                    final payout = b.price; // Provider earns base price, platform keeps platform fee

                    String nextActionTitle = 'Start Travel (On the way)';
                    if (status == 'On the way') {
                      nextActionTitle = 'Reach Customer (Start Work)';
                    } else if (status == 'In progress') {
                      nextActionTitle = 'Mark Done & Collect ₹${b.totalAmount}';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: status == 'In progress' ? Colors.orange : AppTheme.cardBorder,
                          width: status == 'In progress' ? 1.5 : 1,
                        ),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(b.serviceName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primaryBlue),
                              const SizedBox(width: 6),
                              Text(b.dateTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.black45),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(b.address, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Your Net Payout', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  Text(
                                    '₹$payout',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.green),
                                  ),
                                ],
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: status == 'In progress' ? Colors.green : AppTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => advanceJobStatus(b),
                                child: Text(
                                  nextActionTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

            if (broadcastJobs.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Live Job Broadcasts (Instant Accept)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${broadcastJobs.length} Available',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final bj in broadcastJobs)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('BROADCAST LEAD', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          Text('₹${bj.price} net labor', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(bj.serviceName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(bj.dateTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Colors.black45),
                          const SizedBox(width: 6),
                          Expanded(child: Text(bj.address, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => acceptBroadcastJob(bj),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: const Text('Accept Job Order', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 24),
            const Text('Completed Jobs Today', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            for (final cb in completedJobs)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cb.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(cb.dateTime, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      '+₹${cb.price}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: EARNINGS & PAYOUTS
  // -------------------------------------------------------------
  Widget _buildEarningsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Balance Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WEEKLY EARNINGS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(
                '₹$totalEarnings',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text('Includes $completedJobsCount completed service jobs in ${widget.city}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Divider(height: 24, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Payout: ₹$totalEarnings', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('💸 Payout request submitted! ₹$totalEarnings transferred to linked bank account.'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Transparent Commission Notice
        Container(
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
              const Text('Transparent Earnings Structure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              _buildPayoutDetail('Customer Service Charge', '100% credited to Partner', Colors.green),
              _buildPayoutDetail('FixIt Platform Fee', '₹25 billed separately to customer', AppTheme.primaryBlue),
              _buildPayoutDetail('Hidden Commission Cut', '0% (Partner keeps full labor quote)', Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: KYC & PARTNER PROFILE
  // -------------------------------------------------------------
  Widget _buildProfileTab() {
    final isVerified = kycStatus == 'verified';

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
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
                child: const Icon(Icons.handyman_rounded, size: 40, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 10),
              Text(partnerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Text('Specialist $partnerSkill • $partnerPhone', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green.withValues(alpha: 0.12) : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded, size: 16, color: isVerified ? Colors.green : Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Aadhaar & Police Verified Specialist' : 'KYC Verification Pending',
                      style: TextStyle(color: isVerified ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30, color: Color(0xFFF1F5F9)),
              _buildKYCRow('Aadhaar Verification', '$aadhaarNo (${isVerified ? 'Verified' : 'Pending'})', isVerified ? Icons.check_circle_rounded : Icons.access_time_rounded, isVerified ? Colors.green : Colors.orange),
              _buildKYCRow('Skill Certification', 'National Skill Development (NSDC)', Icons.check_circle_rounded, Colors.green),
              _buildKYCRow('Operating Zone', '${widget.city} (15 km Radius)', Icons.location_on_rounded, AppTheme.primaryBlue),
              _buildKYCRow('Payout Bank Account', 'HDFC Bank (A/C: ****5412)', Icons.account_balance_rounded, AppTheme.primaryBlue),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: showKycDialog,
                  icon: const Icon(Icons.security_rounded, size: 18),
                  label: const Text('Update KYC / Aadhaar Details'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutDetail(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
          Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildKYCRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
