import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/settings_controller.dart';
import '../../../core/theme/app_colors.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferences"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader("Appearance"),
          const SizedBox(height: 10),
          _buildThemeToggleCard().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 30),
          
          _buildSectionHeader("Localization"),
          const SizedBox(height: 10),
          _buildLanguageSelectorCard().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 40),
          
          // Danger Zone
          _buildActionCard(
            title: "Clear App Data",
            icon: Icons.delete_forever,
            color: AppColors.error,
            onTap: () {
              // Implementation to clear Hive boxes
            },
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  Widget _buildThemeToggleCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Obx(() => SwitchListTile(
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text("Switch to a darker aesthetic"),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode, color: AppColors.primary),
        ),
        value: controller.isDarkMode.value,
        onChanged: (val) => controller.toggleTheme(),
      )),
    );
  }

  Widget _buildLanguageSelectorCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildLangOption('ar', 'العربية (الجزائر)', '🇩🇿'),
          const Divider(height: 30),
          _buildLangOption('fr', 'Français', '🇫🇷'),
          const Divider(height: 30),
          _buildLangOption('en', 'English', '🇬🇧'),
        ],
      ),
    );
  }

  Widget _buildLangOption(String code, String title, String flag) {
    return Obx(() {
      bool isSelected = controller.currentLanguage.value == code;
      return InkWell(
        onTap: () => controller.changeLanguage(code),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      );
    });
  }

  Widget _buildActionCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white, // Will dynamically map to dark theme via GetX in a real build
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
    );
  }
}