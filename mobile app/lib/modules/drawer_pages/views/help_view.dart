import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class HelpView extends StatelessWidget {
  const HelpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('help'.tr),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, size: 40, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('help'.tr, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('help_subtitle'.tr, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
          
          const SizedBox(height: 32),
          
          _buildFaqItem('faq_q1'.tr, 'faq_a1'.tr).animate().fadeIn(delay: 200.ms),
          _buildFaqItem('faq_q2'.tr, 'faq_a2'.tr).animate().fadeIn(delay: 300.ms),
          _buildFaqItem('faq_q3'.tr, 'faq_a3'.tr).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 40),
          
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.email, color: Colors.white,),
            label: Text('contact_support'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ).animate().fadeIn(delay: 600.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: TextStyle(color: Colors.grey[600], height: 1.5)),
          ),
        ],
      ),
    );
  }
}
