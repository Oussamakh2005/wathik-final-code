import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('about_us'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo / Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rocket_launch, size: 60, color: AppColors.primary),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 24),
            
            Text(
              'app_name'.tr,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 12),
            
            Text(
              'about_us_description'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 40),
            
            // Team Section
            Text(
              'meet_founders'.tr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 20),
            
            _buildTeamMember('Chiahni Mohammed Elamine', Icons.person).animate().slideX(delay: 700.ms),
            const SizedBox(height: 16),
            _buildTeamMember('Necib Amara', Icons.person).animate().slideX(delay: 800.ms),
            const SizedBox(height: 16),
            _buildTeamMember('Oussama Khalef', Icons.person).animate().slideX(delay: 900.ms),
            
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'built_with_passion'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms).shimmer(duration: 2000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
