import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/views/login_view.dart';

import '../../main_layout/views/main_layout_view.dart';

class SplashView extends StatefulWidget {
  final bool isLoggedIn;

  const SplashView({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));
    if (widget.isLoggedIn) {
      Get.offAll(() => const MainLayoutView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800));
    } else {
      Get.offAll(() => const LoginView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? AppColors.backgroundDark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/images/logo.png',
              width: 350,
              height: 350,
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 800.ms)
                .shimmer(delay: 1000.ms, duration: 1500.ms)
                .moveY(
                    begin: 20, end: 0, duration: 800.ms, curve: Curves.easeOut),

          //  const SizedBox(height: 30),

            // App Name
            const Text(
              'وثيق',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(
                begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: 10),

            Text(
              'app_name'.tr, // "Invoice & Finance Manager"
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),

            const SizedBox(height: 60),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ).animate().fadeIn(delay: 1800.ms),
          ],
        ),
      ),
    );
  }
}
