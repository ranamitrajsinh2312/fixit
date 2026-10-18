import 'package:flutter/material.dart';
import '../data.dart';
import '../services/storage_service.dart';
import 'main_shell.dart';

class SelectCityScreen extends StatefulWidget {
  final String? currentCity;
  const SelectCityScreen({super.key, this.currentCity});

  @override
  State<SelectCityScreen> createState() => _SelectCityScreenState();
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  String query = '';
  final TextEditingController _controller = TextEditingController();

  void selectCity(String city) {
    StorageService.setSelectedCity(city);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainShell(city: city)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = cities
        .where((c) => c.toLowerCase().contains(query.trim().toLowerCase()))
        .toList();

    const popularCities = ['Rajkot', 'Ahmedabad', 'Surat', 'Mumbai', 'Bengaluru'];

    return Scaffold(
      appBar: widget.currentCity != null
          ? AppBar(
              title: const Text('Change City'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.currentCity == null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Select your city',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We show verified professionals & prices available in your area.',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
              TextField(
                controller: _controller,
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  hintText: 'Search city or area...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black45),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _controller.clear();
                            setState(() => query = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => selectCity('Rajkot'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.my_location, color: Color(0xFF2563EB)),
                label: const Text(
                  'Use current location (Rajkot)',
                  style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              if (query.isEmpty) ...[
                const Text(
                  'Popular Cities',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in popularCities)
                      ActionChip(
                        label: Text(c),
                        backgroundColor: widget.currentCity == c
                            ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                            : Colors.white,
                        side: BorderSide(
                          color: widget.currentCity == c
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                        ),
                        labelStyle: TextStyle(
                          color: widget.currentCity == c
                              ? const Color(0xFF2563EB)
                              : Colors.black87,
                          fontWeight: widget.currentCity == c
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        onPressed: () => selectCity(c),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'All Cities',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No cities found.\nTry another search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final c = filtered[i];
                          final isSelected = widget.currentCity == c;
                          return Material(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_city,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                c,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Color(0xFF2563EB))
                                  : const Icon(Icons.chevron_right, color: Colors.black38),
                              onTap: () => selectCity(c),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
