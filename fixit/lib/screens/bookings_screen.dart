import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';

class BookingsScreen extends StatefulWidget {
  final String city;
  final VoidCallback? onExploreServices;

  const BookingsScreen({
    super.key,
    this.city = 'Rajkot',
    this.onExploreServices,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String selectedFilter = 'All';
  final Set<String> _reviewedBookingIds = {'FX-87341'};

  @override
  void initState() {
    super.initState();
    _fetchRemoteBookings();
  }

  Future<void> _fetchRemoteBookings() async {
    final list = await ApiService.instance.fetchMyBookings();
    if (mounted && list.isNotEmpty) {
      BookingStore.instance.setBookings(list);
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed')) return Colors.green;
    if (s.contains('cancel')) return Colors.red;
    if (s.contains('progress')) return Colors.orange;
    if (s.contains('way')) return const Color(0xFF0284C7);
    return AppTheme.primaryBlue;
  }

  int _getStatusStepIndex(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed')) return 3;
    if (s.contains('progress')) return 2;
    if (s.contains('way')) return 1;
    return 0; // Assigned / Upcoming / Pending
  }

  Widget _buildStatusTracker(BookingItem booking) {
    final isCancelled = booking.status.toLowerCase().contains('cancel');
    if (isCancelled) {
      final isRefunded = booking.paymentStatus == 'refunded' || booking.refundId != null;
      final isCash = booking.paymentMethod.toLowerCase().contains('cash');

      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'Booking Cancelled',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            if (isRefunded) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee_rounded, size: 13, color: Colors.green),
                    Expanded(
                      child: Text(
                        'Refund of ₹${booking.refundAmount ?? booking.totalAmount} processed (${booking.refundId ?? 'Reference: active'})',
                        style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!isCash) ...[
              const SizedBox(height: 4),
              Text(
                'Refund will be credited to original payment method (${booking.paymentMethod}).',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ],
        ),
      );
    }

    final activeIndex = _getStatusStepIndex(booking.status);
    final steps = [
      {'title': 'Assigned', 'icon': Icons.assignment_turned_in_rounded},
      {'title': 'On Way', 'icon': Icons.two_wheeler_rounded},
      {'title': 'In Progress', 'icon': Icons.handyman_rounded},
      {'title': 'Done', 'icon': Icons.verified_rounded},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= activeIndex ? (i == 3 ? Colors.green : AppTheme.primaryBlue) : Colors.grey.shade300,
                  ),
                  child: Icon(
                    steps[i]['icon'] as IconData,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  steps[i]['title'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: i <= activeIndex ? FontWeight.bold : FontWeight.normal,
                    color: i <= activeIndex ? AppTheme.textDark : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: i < activeIndex ? AppTheme.primaryBlue : Colors.grey.shade300,
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingItem booking) {
    final isOnlinePayment = !booking.paymentMethod.toLowerCase().contains('cash');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel the booking for "${booking.serviceName}" scheduled on ${booking.dateTime}?',
            ),
            if (isOnlinePayment) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Full 100% refund of ₹${booking.totalAmount} will be immediately reversed to your original payment method (${booking.paymentMethod}).',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);

              if (isOnlinePayment) {
                final refundRes = await ApiService.instance.requestRefund(
                  bookingId: booking.id,
                  reason: 'Customer cancelled from app',
                );

                final refId = refundRes['refundId']?.toString() ?? 'rfnd_${DateTime.now().millisecondsSinceEpoch}';
                BookingStore.instance.refundBooking(booking.id, refundId: refId, refundAmount: booking.totalAmount);
                ApiService.instance.updateBookingStatus(booking.id, 'cancelled');

                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (diagCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Refund Processed! 💸'),
                    content: Text(
                      'Your booking has been cancelled and a full refund of ₹${booking.totalAmount} has been credited to your ${booking.paymentMethod}.\n\nRefund Reference: $refId',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(diagCtx),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              } else {
                BookingStore.instance.cancelBooking(booking.id);
                ApiService.instance.updateBookingStatus(booking.id, 'cancelled');

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking ${booking.id} has been cancelled.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Yes, Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _handleRebook(BookingItem booking) {
    Category? matchedCategory;
    Service? matchedService;

    for (final cat in categories) {
      if (cat.name.toLowerCase() == booking.categoryName.toLowerCase() ||
          cat.id.toLowerCase() == booking.categoryName.toLowerCase()) {
        matchedCategory = cat;
        for (final s in cat.services) {
          if (s.name.toLowerCase() == booking.serviceName.toLowerCase()) {
            matchedService = s;
            break;
          }
        }
        break;
      }
    }

    matchedCategory ??= categories.first;
    matchedService ??= Service(
      id: 'srv_rebook_${booking.serviceName.toLowerCase().replaceAll(' ', '_')}',
      name: booking.serviceName,
      desc: 'Doorstep service with 30-day warranty',
      price: booking.price,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          category: matchedCategory!,
          service: matchedService!,
          city: booking.city.isNotEmpty ? booking.city : widget.city,
        ),
      ),
    );
  }

  void _showRatingModal(BuildContext context, BookingItem booking) {
    int rating = 5;
    final commentController = TextEditingController();
    final selectedTags = <String>{};
    final tags = ['⚡ Fast Arrival', '🔧 Flawless Repair', '😊 Polite Pro', '🧼 Cleaned Up Area', '💯 Honest Pricing'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rate Your Experience', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'How was your ${booking.serviceName} service on ${booking.dateTime}?',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),

              // Interactive Stars
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (idx) {
                    final starIndex = idx + 1;
                    return IconButton(
                      iconSize: 38,
                      splashRadius: 24,
                      icon: Icon(
                        starIndex <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                      ),
                      onPressed: () => setSheetState(() => rating = starIndex),
                    );
                  }),
                ),
              ),
              Center(
                child: Text(
                  rating == 5
                      ? 'Excellent! (5/5)'
                      : rating == 4
                          ? 'Very Good (4/5)'
                          : rating == 3
                              ? 'Average (3/5)'
                              : 'Needs Improvement',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Tag Chips
              const Text('What went well?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((t) {
                  final isSelected = selectedTags.contains(t);
                  return FilterChip(
                    label: Text(t, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppTheme.textDark)),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryBlue,
                    checkmarkColor: Colors.white,
                    onSelected: (val) {
                      setSheetState(() {
                        if (val) {
                          selectedTags.add(t);
                        } else {
                          selectedTags.remove(t);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Comment TextField
              TextField(
                controller: commentController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Share a few words about the technician & service...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final fullComment = [
                      if (selectedTags.isNotEmpty) selectedTags.join(', '),
                      if (commentController.text.trim().isNotEmpty) commentController.text.trim(),
                    ].join('. ');

                    await ApiService.instance.submitReview(
                      bookingId: booking.id,
                      rating: rating,
                      comment: fullComment.isNotEmpty ? fullComment : 'Great job by technician!',
                      serviceName: booking.serviceName,
                    );

                    setState(() {
                      _reviewedBookingIds.add(booking.id);
                    });

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Thank you! Your $rating★ review for ${booking.serviceName} has been submitted.'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: ListenableBuilder(
        listenable: BookingStore.instance,
        builder: (context, _) {
          final allBookings = BookingStore.instance.bookings;
          final filtered = selectedFilter == 'All'
              ? allBookings
              : allBookings.where((b) => b.status == selectedFilter).toList();

          return Column(
            children: [
              // Filter Chips Row
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final filter in ['All', 'Upcoming', 'Completed', 'Cancelled'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: selectedFilter == filter ? Colors.white : AppTheme.textDark,
                            fontWeight: selectedFilter == filter ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (sel) {
                            if (sel) setState(() => selectedFilter = filter);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Booking List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  size: 52,
                                  color: Colors.black26,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No $selectedFilter Bookings',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Schedule a repair or maintenance service anytime to track its live status here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.3),
                              ),
                              const SizedBox(height: 20),
                              if (widget.onExploreServices != null)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(180, 46),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: widget.onExploreServices,
                                  child: const Text('Explore Services'),
                                ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchRemoteBookings,
                        child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final b = filtered[i];
                          final statusColor = _getStatusColor(b.status);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.cardBorder),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        b.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          b.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.serviceName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              b.categoryName,
                                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${b.totalAmount}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          ),
                                          Text(
                                            b.paymentMethod,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 15, color: AppTheme.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(b.dateTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 15, color: AppTheme.primaryBlue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          b.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Live Status Stepper Lifecycle
                                  _buildStatusTracker(b),

                                  if (!b.status.toLowerCase().contains('cancel') &&
                                      !b.status.toLowerCase().contains('completed')) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            b.status.toLowerCase().contains('way')
                                                ? '🛵 Specialist is on the way'
                                                : b.status.toLowerCase().contains('progress')
                                                    ? '🔧 Work currently in progress'
                                                    : '⚡ Specialist assigned',
                                            style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            minimumSize: Size.zero,
                                          ),
                                          onPressed: () => _showCancelDialog(context, b),
                                          child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (b.status.toLowerCase().contains('completed')) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (_reviewedBookingIds.contains(b.id))
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Reviewed ★',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          OutlinedButton.icon(
                                            onPressed: () => _showRatingModal(context, b),
                                            icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                            label: const Text(
                                              'Rate & Review',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              minimumSize: Size.zero,
                                              side: const BorderSide(color: Colors.amber),
                                              foregroundColor: const Color(0xFFB45309),
                                            ),
                                          ),
                                        FilledButton.icon(
                                          onPressed: () => _handleRebook(b),
                                          icon: const Icon(Icons.repeat_rounded, size: 14),
                                          label: const Text(
                                            'Rebook',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppTheme.primaryBlue,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            minimumSize: Size.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
