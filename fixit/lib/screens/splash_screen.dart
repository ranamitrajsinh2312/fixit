import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'main_shell.dart';
import 'select_city_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    final results = await Future.wait([
      StorageService.getSelectedCity(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;
    final savedCity = results[0] as String?;

    if (savedCity != null && savedCity.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainShell(city: savedCity)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectCityScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_repair_service_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'FixIt',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Home repairs, sorted.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
