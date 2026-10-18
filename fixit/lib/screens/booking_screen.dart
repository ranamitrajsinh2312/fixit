import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import 'checkout_screen.dart';

class BookingScreen extends StatefulWidget {
  final Category category;
  final Service service;
  final String city;

  const BookingScreen({
    super.key,
    required this.category,
    required this.service,
    required this.city,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isInstant = false;
  late DateTime selectedDate;
  int selectedSlotIndex = 0;
  String timeMode = 'Standard'; // 'Standard', 'Exact', 'Flexible'
  TimeOfDay customTime = const TimeOfDay(hour: 11, minute: 30);
  String selectedFlexibleWindow = 'Morning (9 AM - 1 PM)';
  String addressType = 'Home';
  late final TextEditingController addressController;
  final TextEditingController instructionsController = TextEditingController();

  final List<String> flexibleWindows = [
    'Morning (9 AM - 1 PM)',
    'Afternoon (1 PM - 5 PM)',
    'Evening (5 PM - 9 PM)',
    'Anytime Today (9 AM - 8 PM)',
  ];

  @override
  void initState() {
    super.initState();
    final isRoadside = widget.category.id == 'on_road_mechanic';
    isInstant = isRoadside;
    selectedDate = isRoadside ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
    addressType = isRoadside ? 'On-Road (GPS)' : 'Home';
    addressController = TextEditingController(
      text: isRoadside
          ? '📍 Current Breakdown Spot: 150ft Ring Road, near Big Bazaar, ${widget.city}'
          : 'Flat 402, Radhe Residency, 150ft Ring Road, ${widget.city}',
    );

    final now = DateTime.now();
    customTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
  }

  @override
  void dispose() {
    addressController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  Future<void> pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickExactTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: customTime,
      helpText: 'Select exact preferred arrival time',
    );
    if (picked != null) {
      setState(() {
        customTime = picked;
        timeMode = 'Exact';
      });
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final min = tod.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  String computeWhenString() {
    if (isInstant) {
      return '⚡ Instant Dispatch (Arrives in 15–30 Mins)';
    }

    final dateStr =
        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

    if (timeMode == 'Exact') {
      return '$dateStr, Exact Time: ${formatTimeOfDay(customTime)}';
    } else if (timeMode == 'Flexible') {
      return '$dateStr, Window: $selectedFlexibleWindow';
    } else {
      return '$dateStr, ${timeSlots[selectedSlotIndex]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    final isCustomDateSelected = !dates.any((d) =>
        d.day == selectedDate.day &&
        d.month == selectedDate.month &&
        d.year == selectedDate.year);

    final totalPreview = widget.service.price + platformFee;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: const Text('Schedule Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Service Snapshot Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
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
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Booking Timing Mode Switcher (Blinkit Instant vs Scheduled)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isInstant = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isInstant ? const Color(0xFFF59E0B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isInstant ? AppTheme.softShadow : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 18,
                            color: isInstant ? Colors.black : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '⚡ Instant (15-30 Mins)',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: isInstant ? Colors.black : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isInstant = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isInstant ? AppTheme.primaryBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !isInstant ? AppTheme.softShadow : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: !isInstant ? Colors.white : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '📅 Schedule Later',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: !isInstant ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Instant Dispatch View (Blinkit style)
          if (isInstant) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on_rounded, size: 14, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              'BLINKIT-STYLE QUICK DISPATCH',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.4),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Verified Pros Active', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '⚡ Specialist Arriving in 15–30 Mins',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Our priority dispatch matches the nearest verified technician within 5–10 km in ${widget.city}. Track their live ride en route.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const Divider(height: 24, color: Colors.white12),
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler_rounded, color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estimated Arrival Window: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} – ${(DateTime.now().hour + ((DateTime.now().minute + 30) ~/ 60)) % 24}:${((DateTime.now().minute + 30) % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // 4. Flexible Schedule for Later (Date & Time Picker)
            // A. Date Selection Card
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
                      const Text('Select Service Date', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      TextButton.icon(
                        onPressed: pickCustomDate,
                        icon: const Icon(Icons.calendar_month_rounded, size: 16),
                        label: const Text('Calendar Picker', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 75,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, i) {
                        final d = dates[i];
                        final isSelected = d.day == selectedDate.day &&
                            d.month == selectedDate.month &&
                            d.year == selectedDate.year;

                        final dayName = i == 0 ? 'Today' : i == 1 ? 'Tomorrow' : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

                        return GestureDetector(
                          onTap: () => setState(() => selectedDate = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 65,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white70 : AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${d.day}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isCustomDateSelected) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_available_rounded, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            'Custom Date Selected: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // B. Flexible Arrival Time Section
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
                      const Text('Arrival Time & Flexibility', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      if (timeMode == 'Exact')
                        TextButton.icon(
                          onPressed: pickExactTime,
                          icon: const Icon(Icons.access_time_rounded, size: 16),
                          label: const Text('Change Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Pick a fixed window, exact time, or flexible half-day bracket', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 12),

                  // Sub-mode tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final mode in [
                          {'id': 'Standard', 'label': '2-Hr Window'},
                          {'id': 'Exact', 'label': 'Exact Custom Time'},
                          {'id': 'Flexible', 'label': 'Flexible (Half-Day)'},
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(mode['label']!),
                              selected: timeMode == mode['id'],
                              selectedColor: AppTheme.primaryBlue,
                              labelStyle: TextStyle(
                                color: timeMode == mode['id'] ? Colors.white : AppTheme.textDark,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() => timeMode = mode['id']!);
                                  if (mode['id'] == 'Exact') {
                                    pickExactTime();
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Options based on selected mode
                  if (timeMode == 'Standard') ...[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var i = 0; i < timeSlots.length; i++)
                          ChoiceChip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 14,
                                    color: selectedSlotIndex == i ? Colors.white : AppTheme.primaryBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(timeSlots[i]),
                                ],
                              ),
                            ),
                            selected: selectedSlotIndex == i,
                            selectedColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(
                              color: selectedSlotIndex == i ? Colors.white : AppTheme.textDark,
                              fontWeight: selectedSlotIndex == i ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (sel) {
                              if (sel) setState(() => selectedSlotIndex = i);
                            },
                          ),
                      ],
                    ),
                  ] else if (timeMode == 'Exact') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.schedule_rounded, color: AppTheme.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Exact Requested Time', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                                Text(
                                  formatTimeOfDay(customTime),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: pickExactTime,
                            icon: const Icon(Icons.edit_calendar_rounded, size: 14),
                            label: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Flexible Half-Day
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final window in flexibleWindows)
                          ChoiceChip(
                            label: Text(window),
                            selected: selectedFlexibleWindow == window,
                            selectedColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(
                              color: selectedFlexibleWindow == window ? Colors.white : AppTheme.textDark,
                              fontWeight: selectedFlexibleWindow == window ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (sel) {
                              if (sel) setState(() => selectedFlexibleWindow = window);
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),

          // 5. Address Section (With On-Road GPS support)
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
                    const Text('Service Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final type in ['Home', 'Office', 'On-Road (GPS)', 'Other'])
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: addressType == type,
                                selectedColor: type == 'On-Road (GPS)' ? Colors.red : AppTheme.primaryBlue,
                                labelStyle: TextStyle(
                                  color: addressType == type ? Colors.white : AppTheme.textDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      addressType = type;
                                      if (type == 'On-Road (GPS)') {
                                        addressController.text =
                                            '📍 Current Breakdown Spot: 150ft Ring Road, near Big Bazaar, ${widget.city}';
                                        isInstant = true;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: addressType == 'On-Road (GPS)'
                        ? 'Pinpoint road, highway bypass, mile marker or landmark...'
                        : 'House no, building name, street, landmark...',
                    helperText: addressType == 'On-Road (GPS)'
                        ? 'Mobile mechanic equipped with toolkit dispatched to this spot'
                        : 'Technician will arrive at this address',
                  ),
                ),
                if (addressType == 'On-Road (GPS)' || widget.category.id == 'on_road_mechanic') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.radar_rounded, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚡ 24x7 Emergency RSA: Nearest mobile mechanic with toolkit & jump-starter dispatched directly to this road spot.',
                            style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 6. Special Instructions & Notes
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
                const Text('Special Instructions (Optional)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Help the specialist reach you quicker with landmark or access notes', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 10),
                TextField(
                  controller: instructionsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ring bell twice, enter from south gate, landmark near ICICI bank...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
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
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Bill', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                  Text(
                    '₹$totalPreview',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isInstant ? const Color(0xFFD97706) : AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final baseAddr = addressController.text.trim().isEmpty
                        ? 'Address not specified (${widget.city})'
                        : addressController.text.trim();

                    final note = instructionsController.text.trim();
                    final finalAddr = note.isNotEmpty ? '$baseAddr (Note: $note)' : baseAddr;

                    final whenStr = computeWhenString();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          category: widget.category,
                          service: widget.service,
                          address: finalAddr,
                          when: whenStr,
                          city: widget.city,
                        ),
                      ),
                    );
                  },
                  icon: Icon(isInstant ? Icons.flash_on_rounded : Icons.check_circle_rounded, size: 18),
                  label: Text(
                    isInstant ? 'Book Instant Dispatch' : 'Proceed to Checkout',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
