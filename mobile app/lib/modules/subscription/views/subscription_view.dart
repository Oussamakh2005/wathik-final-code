import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../main_layout/views/main_layout_view.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Premium Dark Background
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // --- Ambient Glowing Orbs ---
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 4000.ms, color: Colors.purple.withOpacity(0.5)),
          ),
          Positioned(
            bottom: -50, left: -100,
            child: Container(
              width: 250, height: 250,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8A2387)),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 5000.ms, color: Colors.blue.withOpacity(0.5)),
          ),
          
          // --- Main Content ---
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('choose_plan'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 1)),
                    ],
                  ),
                ),
                Text('upgrade_finance'.tr, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                const SizedBox(height: 20),

                // Pricing Cards List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      // 1. FREE PLAN
                      _buildGlassPricingCard(
                        context: context,
                        title: 'plan_free_title'.tr,
                        price: '0 DA',
                        subtitle: 'plan_free_sub'.tr,
                        features: [
                          'free_feat_1'.tr,
                          'free_feat_2'.tr,
                          'free_feat_3'.tr,
                          'free_feat_4'.tr,
                        ],
                        accentColor: Colors.white70,
                        isPremium: false,
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 25),

                      // 2. STARTER PLAN
                      _buildGlassPricingCard(
                        context: context,
                        title: 'plan_starter_title'.tr,
                        price: '4\$ / ${'month'.tr}',
                        subtitle: 'plan_starter_sub'.tr,
                        features: [
                          'starter_feat_1'.tr,
                          'starter_feat_2'.tr,
                          'starter_feat_3'.tr,
                          'starter_feat_4'.tr,
                          'starter_feat_5'.tr,
                        ],
                        accentColor: Colors.blueAccent,
                        isPremium: true,
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 25),

                      // 3. PRO PLAN (Popular)
                      _buildGlassPricingCard(
                        context: context,
                        title: 'plan_pro_title'.tr,
                        price: '8\$ / ${'month'.tr}',
                        subtitle: 'plan_pro_sub'.tr,
                        features: [
                          'pro_feat_1'.tr,
                          'pro_feat_2'.tr,
                          'pro_feat_3'.tr,
                          'pro_feat_4'.tr,
                          'pro_feat_5'.tr,
                        ],
                        accentColor: AppColors.primary,
                        isPremium: true,
                        isPopular: true,
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 25),

                      // 4. BUSINESS PLAN
                      _buildGlassPricingCard(
                        context: context,
                        title: 'plan_business_title'.tr,
                        price: '15\$ / ${'month'.tr}',
                        subtitle: 'plan_business_sub'.tr,
                        features: [
                          'business_feat_1'.tr,
                          'business_feat_2'.tr,
                          'business_feat_3'.tr,
                          'business_feat_4'.tr,
                          'business_feat_5'.tr,
                        ],
                        accentColor: const Color(0xFFFFB300),
                        isPremium: true,
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- GLASSMORPHISM PRICING CARD ---
  Widget _buildGlassPricingCard({
    required BuildContext context,
    required String title,
    required String price,
    required String subtitle,
    required List<String> features,
    required Color accentColor,
    required bool isPremium,
    bool isPopular = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, spreadRadius: -5)
            ]
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isPopular)
                Positioned(
                  top: -10, right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE94057), Color(0xFF8A2387)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Text('most_popular'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ).animate().shimmer(duration: 2000.ms, delay: 1000.ms),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4)),
                  const SizedBox(height: 15),
                  Text(price, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                  ),
                  
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: accentColor, size: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4))),
                      ],
                    ),
                  )).toList(),
                  
                  const SizedBox(height: 25),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPremium ? accentColor : Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        elevation: isPremium ? 10 : 0,
                        shadowColor: accentColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isPremium ? Colors.transparent : Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      onPressed: () {
                        if (!isPremium) {
                          Get.offAll(() => const MainLayoutView(), transition: Transition.fadeIn);
                        } else {
                          _showPaymentSheet(context, title, price, accentColor);
                        }
                      },
                      child: Text(isPremium ? 'subscribe_now'.tr : 'start_free'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // ===============================================
  // ALGERIAN PAYMENT BOTTOM SHEET (PREMIUM UX)
  // ===============================================
  void _showPaymentSheet(BuildContext context, String planName, String price, Color accentColor) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 25),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('checkout'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("${'selected_plan'.tr} $planName", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 30),

              // Modern Pill-Shaped Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[600],
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        tabs: const [
                          Tab(text: "EDAHABIA / CIB"),
                          Tab(text: "BaridiMob"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 220, 
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Tab 1: EDAHABIA / CIB
                          Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'card_number'.tr,
                                  prefixIcon: const Icon(Icons.credit_card, color: AppColors.primary),
                                  filled: true, fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "MM/YY",
                                        filled: true, fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "CVV2",
                                        filled: true, fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).animate().fadeIn().slideX(begin: 0.1),
                          
                          // Tab 2: BARIDIMOB
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('baridimob_pay'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                              const SizedBox(height: 8),
                              Text('transfer_to_account'.tr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.white]),
                                  borderRadius: BorderRadius.circular(16), 
                                  border: Border.all(color: Colors.blue[200]!)
                                ),
                                child: const SelectableText("RIP: 007 99999 0000000000 12\nName: WATHIQ APP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark, height: 1.5)),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'enter_phone_rip'.tr,
                                  prefixIcon: const Icon(Icons.phone_android, color: Colors.blue),
                                  filled: true, fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ).animate().fadeIn().slideX(begin: 0.1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853), 
                    elevation: 5,
                    shadowColor: const Color(0xFF00C853).withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Get.back(); 
                    Get.dialog(
                      Center(child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const CircularProgressIndicator(color: AppColors.primary),
                      )), 
                      barrierDismissible: false
                    );
                    
                    Future.delayed(const Duration(seconds: 2), () {
                      Get.back(); 
                      Get.snackbar(
                        'payment_success'.tr, 'plan_activated'.tr,
                        backgroundColor: const Color(0xFF00C853), colorText: Colors.white, 
                        snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(20),
                        icon: const Icon(Icons.check_circle, color: Colors.white)
                      );
                      Get.offAll(() => const MainLayoutView(), transition: Transition.zoom);
                    });
                  },
                  child: Text('confirm_payment'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Required for curved top corners
    );
  }
}