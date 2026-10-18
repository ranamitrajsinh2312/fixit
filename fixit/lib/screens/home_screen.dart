import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data.dart';
import 'category_screen.dart';
import 'service_detail_screen.dart';
import 'select_city_screen.dart';
import 'admin_panel_screen.dart';
import 'servicer_screen.dart';

class HomeScreen extends StatefulWidget {
  final String city;
  final ValueChanged<String>? onCityChanged;
  final VoidCallback? onGoToBookings;

  const HomeScreen({
    super.key,
    required this.city,
    this.onCityChanged,
    this.onGoToBookings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  String _selectedCategoryTab = 'All';

  final List<Map<String, dynamic>> banners = [
    {
      'tag': '24x7 EMERGENCY RSA',
      'title': 'On-Road Breakdown & Mechanic',
      'subtitle': 'Bike & car breakdown, puncture, jump-start & fuel delivery in 15-25 mins.',
      'gradient': [Color(0xFF991B1B), Color(0xFFDC2626)],
      'icon': Icons.car_repair_rounded,
      'badge': 'Rapid GPS Dispatch',
    },
    {
      'tag': 'FIXIT PROMISE',
      'title': 'Verified Experts at Your Door',
      'subtitle': 'Flat ₹$platformFee platform fee per booking. 30-day rework warranty.',
      'gradient': [Color(0xFF1E3A8A), Color(0xFF2563EB)],
      'icon': Icons.verified_user_rounded,
      'badge': '100% Background Checked',
    },
    {
      'tag': 'SUMMER SPECIAL',
      'title': 'AC Servicing & Gas Refill',
      'subtitle': 'High-pressure jet wash from ₹499. Instant slot booking today.',
      'gradient': [Color(0xFF065F46), Color(0xFF059669)],
      'icon': Icons.ac_unit_rounded,
      'badge': 'Flat 20% Off',
    },
    {
      'tag': 'FAST DISPATCH',
      'title': 'Emergency Leak & Spark Fix',
      'subtitle': 'Verified plumber or electrician arrives in 45-60 minutes.',
      'gradient': [Color(0xFF831843), Color(0xFFBE185D)],
      'icon': Icons.bolt_rounded,
      'badge': 'Under 60 Mins',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void openCitySelector() async {
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

  List<Category> get filteredCategories {
    if (_selectedCategoryTab == 'Emergency RSA') {
      return categories.where((c) => ['on_road_mechanic', 'generic_mechanic', 'emergency_locksmith', 'vehicle_care'].contains(c.id)).toList();
    } else if (_selectedCategoryTab == 'Repairs') {
      return categories.where((c) => ['electrician', 'plumber', 'gas_repair', 'furniture', 'appliance_repair', 'ac_repair', 'on_road_mechanic', 'generic_mechanic', 'emergency_locksmith'].contains(c.id)).toList();
    } else if (_selectedCategoryTab == 'Cleaning') {
      return categories.where((c) => ['home_cleaning', 'pest_control', 'ro_purifier'].contains(c.id)).toList();
    } else if (_selectedCategoryTab == 'Installation') {
      return categories.where((c) => ['cctv_security', 'painting', 'mason_civil', 'mobile_laptop'].contains(c.id)).toList();
    } else if (_selectedCategoryTab == 'Lifestyle') {
      return categories.where((c) => ['salon_wellness', 'vehicle_care', 'packers_movers'].contains(c.id)).toList();
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    // Search index
    final allServices = <Map<String, dynamic>>[];
    for (final cat in categories) {
      for (final s in cat.services) {
        allServices.add({'service': s, 'category': cat});
      }
    }

    final searchResults = searchQuery.isEmpty
        ? <Map<String, dynamic>>[]
        : allServices.where((item) {
            final s = item['service'] as Service;
            final cat = item['category'] as Category;
            final q = searchQuery.toLowerCase();
            return s.name.toLowerCase().contains(q) ||
                s.desc.toLowerCase().contains(q) ||
                cat.name.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Top Bar: Location & Notifications
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: openCitySelector,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CURRENT CITY',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.city,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textDark),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Portal Switcher Button
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: PopupMenuButton<String>(
                      tooltip: 'Switch Portal',
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.swap_horiz_rounded, color: AppTheme.primaryBlue, size: 20),
                          SizedBox(width: 4),
                          Text('Portals', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          Icon(Icons.arrow_drop_down, color: AppTheme.textMuted, size: 18),
                        ],
                      ),
                      onSelected: (val) {
                        if (val == 'servicer') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ServicerScreen(city: widget.city)),
                          );
                        } else if (val == 'admin') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdminPanelScreen(city: widget.city)),
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'servicer',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.handyman_rounded, color: Colors.orange, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Servicer (Partner) App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                                    Text('Job feed & technician tasks', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'admin',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF0F172A), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                                    Text('Metrics, fee settings & orders', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification button with badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardBorder),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark, size: 22),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🔔 No pending alerts. Technicians available in your area.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar with Clean Elevated Container
            Container(
              decoration: BoxDecoration(
                boxShadow: AppTheme.softShadow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search "fan repair", "gas leak", "ac", "cleaning"...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Search Results Mode
            if (searchQuery.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Results (${searchResults.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Showing matches for "$searchQuery"',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (searchResults.isEmpty)
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
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.black26),
                        SizedBox(height: 12),
                        Text(
                          'No services found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try searching "repair", "pipe", "ac", "cleaning", or "battery"',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final res in searchResults) ...[
                  Builder(
                    builder: (context) {
                      final s = res['service'] as Service;
                      final cat = res['category'] as Category;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          boxShadow: AppTheme.softShadow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppTheme.cardBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 24),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          subtitle: Text(
                            '${cat.name} • ★ ${s.rating}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${s.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const Text('+ ₹25 fee', style: TextStyle(fontSize: 10, color: Colors.black38)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(
                                  category: cat,
                                  service: s,
                                  city: widget.city,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  ),
                ],
              const SizedBox(height: 16),
            ] else ...[
              // Modern Hero Banner Carousel
              SizedBox(
                height: 165,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: banners.length,
                  onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
                  itemBuilder: (context, idx) {
                    final b = banners[idx];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: b['gradient'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: (b['gradient'] as List<Color>)[1].withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b['tag'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  b['title'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b['subtitle'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(b['icon'] as IconData, color: Colors.white, size: 38),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Banner Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < banners.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentBannerIndex == i ? 22 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == i ? AppTheme.primaryBlue : AppTheme.cardBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Category Filter Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${categories.length} Categories',
                      style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Category Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tab in ['All', 'Emergency RSA', 'Repairs', 'Cleaning', 'Installation', 'Lifestyle'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tab),
                          selected: _selectedCategoryTab == tab,
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: _selectedCategoryTab == tab ? Colors.white : AppTheme.textDark,
                            fontWeight: _selectedCategoryTab == tab ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedCategoryTab = tab);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4-Column Modern Icon Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.74,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, i) {
                  final c = filteredCategories[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(category: c, city: widget.city),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: c.color.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.color.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(c.icon, color: c.color, size: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            height: 1.15,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Trending & Most Booked Services
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Most Booked Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'In ${widget.city}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Card Scroll for Quick Booking
              SizedBox(
                height: 195,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFeaturedCard(
                      category: categories[0], // Electrician
                      service: categories[0].services[0], // Fan repair
                      mrp: 299,
                      discount: '33% OFF',
                    ),
                    _buildFeaturedCard(
                      category: categories[4], // AC Repair
                      service: categories[4].services[0], // AC Service
                      mrp: 699,
                      discount: '28% OFF',
                    ),
                    _buildFeaturedCard(
                      category: categories[1], // Plumber
                      service: categories[1].services[0], // Tap & mixer
                      mrp: 249,
                      discount: '40% OFF',
                    ),
                    _buildFeaturedCard(
                      category: categories[7], // Cleaning
                      service: categories[7].services[2], // Bathroom clean
                      mrp: 699,
                      discount: '28% OFF',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // FixIt Quality Guarantee Card
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
                      children: const [
                        Icon(Icons.shield_rounded, color: AppTheme.primaryBlue, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'The FixIt Assurance',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTrustRow(Icons.check_circle_rounded, '100% Background-Verified Specialists'),
                    _buildTrustRow(Icons.published_with_changes_rounded, '30-Day Free Reservice Guarantee'),
                    _buildTrustRow(Icons.price_check_rounded, 'Flat ₹$platformFee Platform Fee • Zero Hidden Charges'),
                    _buildTrustRow(Icons.support_agent_rounded, 'Dedicated WhatsApp & Call Support'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard({
    required Category category,
    required Service service,
    required int mrp,
    required String discount,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: AppTheme.softShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(
                category: category,
                service: service,
                city: widget.city,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(category.icon, color: category.color, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    '${service.rating} (${service.reviewsCount})',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '₹${service.price}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹$mrp',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
