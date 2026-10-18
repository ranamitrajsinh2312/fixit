import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_services_provider.dart';
import '../services/storage_service.dart';
import 'select_city_screen.dart';
import 'admin_panel_screen.dart';
import 'servicer_screen.dart';
import 'login_screen.dart';
import '../core/localization/app_strings.dart';

class ProfileScreen extends StatefulWidget {
  final String city;
  final ValueChanged<String>? onCityChanged;

  const ProfileScreen({
    super.key,
    required this.city,
    this.onCityChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final list = await StorageService.getSavedAddresses();
    if (mounted) {
      setState(() => _savedAddresses = list);
    }
  }

  void _handleChangeCity(BuildContext context) async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectCityScreen(currentCity: widget.city),
      ),
    );
    if (selected != null && widget.onCityChanged != null) {
      widget.onCityChanged!(selected);
    }
  }

  void _showSavedAddressesDialog(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_savedAddresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No saved addresses yet. Add one below:'),
                )
              else
                ..._savedAddresses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final addr = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                      title: Text(addr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () async {
                          final updated = List<String>.from(_savedAddresses)..removeAt(idx);
                          await StorageService.setSavedAddresses(updated);
                          setSheetState(() => _savedAddresses = updated);
                          setState(() => _savedAddresses = updated);
                        },
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter new address...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        await StorageService.addSavedAddress(text);
                        await _loadAddresses();
                        setSheetState(() {});
                        controller.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(height: 1.4)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ListenableBuilder(
        listenable: AppStrings.instance,
        builder: (ctx, _) {
          final current = AppStrings.instance.currentLanguage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Language / ભાષા પસંદ કરો',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildLanguageOption(
                  ctx,
                  title: 'English (Default)',
                  subtitle: 'International English',
                  flag: '🇬🇧',
                  isSelected: current == AppLanguage.en,
                  onTap: () {
                    AppStrings.instance.setLanguage(AppLanguage.en);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  ctx,
                  title: 'ગુજરાતી (Gujarati)',
                  subtitle: 'ગુજરાતમાં ઘરગથ્થુ સેવાઓ',
                  flag: '🇮🇳',
                  isSelected: current == AppLanguage.gu,
                  onTap: () {
                    AppStrings.instance.setLanguage(AppLanguage.gu);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  ctx,
                  title: 'हिंदी (Hindi)',
                  subtitle: 'घर की मरम्मत और सेवाएं',
                  flag: '🇮🇳',
                  isSelected: current == AppLanguage.hi,
                  onTap: () {
                    AppStrings.instance.setLanguage(AppLanguage.hi);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final servicesProvider = context.watch<AppServicesProvider>();

    final userName = auth.isLoggedIn ? (auth.name ?? 'Devang Patel') : 'Guest User';
    final userPhone = auth.isLoggedIn ? (auth.phone ?? '+91 98795 43210') : 'Not logged in';

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile User Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          child: Icon(
                            auth.isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                            size: 40,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        if (auth.isLoggedIn)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                              ),
                              if (auth.isLoggedIn) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 18, color: AppTheme.primaryBlue),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$userPhone • ${widget.city}, IN',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          if (auth.isLoggedIn)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'FixIt Prime Member',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () => auth.logout(),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            )
                          else
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Login with Mobile OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('Active City', widget.city, Icons.location_city_rounded),
                    Container(height: 28, width: 1, color: AppTheme.cardBorder),
                    _buildMetric('Platform Fee', '₹${servicesProvider.dynamicPlatformFee}', Icons.bolt_rounded),
                    Container(height: 28, width: 1, color: AppTheme.cardBorder),
                    _buildMetric('Warranty', '30 Days', Icons.shield_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // City Quick Switcher Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browsing services in ${widget.city}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark),
                      ),
                      const Text(
                        'Change to view prices and pros in another city',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _handleChangeCity(context),
                  child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // App Portals & Role Switcher
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
                    const Text('Switch Role / Portal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Live Mode', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Experience FixIt as a Service Partner or Platform Administrator.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ServicerScreen(city: widget.city)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.handyman_rounded, color: Colors.orange, size: 28),
                              SizedBox(height: 6),
                              Text('Servicer App', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                              SizedBox(height: 2),
                              Text('Job Feed & Payouts', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdminPanelScreen(city: widget.city)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.15)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF0F172A), size: 28),
                              SizedBox(height: 6),
                              Text('Admin Console', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                              SizedBox(height: 2),
                              Text('Metrics & Fee Settings', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Menu Options Group
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: _savedAddresses.isNotEmpty
                        ? '${_savedAddresses.length} saved addresses (Tap to edit)'
                        : 'Manage home & office delivery addresses',
                    onTap: () => _showSavedAddressesDialog(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods & Wallet',
                    subtitle: 'UPI, Debit/Credit Cards, Cash on Service',
                    onTap: () => _showInfoDialog(
                      context,
                      'Payment Methods',
                      'Supported options:\n• UPI (GPay, PhonePe, Paytm, BHIM)\n• All major Debit & Credit Cards\n• Cash after service completion',
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: '30-Day FixIt Guarantee',
                    subtitle: 'Free rework on any service quality concerns',
                    onTap: () => _showInfoDialog(
                      context,
                      'FixIt Quality Guarantee',
                      'Every service completed through FixIt comes with an unconditional 30-day rework warranty. If you face any issues, our technician will revisit free of charge.',
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Customer Support & Helpdesk',
                    subtitle: '24/7 WhatsApp & Phone assistance',
                    onTap: () => _showInfoDialog(
                      context,
                      'Customer Care',
                      'Need assistance with your booking?\n\nWhatsApp: +91 98795 00000\nEmail: care@fixitapp.in\nHours: 8:00 AM - 9:00 PM Daily',
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuItem(
                    icon: Icons.language_rounded,
                    title: 'App Language / ભાષા / भाषा',
                    subtitle: AppStrings.instance.languageName,
                    onTap: () => _showLanguageModal(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch City',
                    subtitle: 'Select from 12 operational cities',
                    onTap: () => _handleChangeCity(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Footer
          const Center(
            child: Column(
              children: [
                Text(
                  'FixIt Home Services',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textMuted),
                ),
                SizedBox(height: 2),
                Text(
                  'Version 1.2.0 • Phase 3 (Auth & API Integration)',
                  style: TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 20),
        onTap: onTap,
      ),
    );
  }
}
