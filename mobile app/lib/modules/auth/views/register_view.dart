import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>(); 
    
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ).animate().fadeIn(delay: 200.ms),
      ),
      body: Stack(
        children: [
          // Premium Animated Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Color(0xFFE94057),
                  Color(0xFF8A2387), 
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 5000.ms, color: Colors.white12),

          // Floating decorative circles
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            ).animate().slide(duration: 3500.ms, curve: Curves.easeInOutSine).scale(),
          ),
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            ).animate().slide(duration: 4500.ms, curve: Curves.easeInOutSine),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 25,
                            spreadRadius: -5,
                          )
                        ]
                      ),
                      child: Form(
                        key: controller.registerFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 15, spreadRadius: 3)
                                  ]
                                ),
                                child: Image.asset('assets/images/logo.png', width: 60, height: 60),
                              ),
                            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                            
                            const SizedBox(height: 15),

                            const Text("إنشاء حساب", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)).animate().fadeIn(delay: 100.ms),
                            Text("ابدأ في إدارة عملك اليوم.", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))).animate().fadeIn(delay: 200.ms),
                            
                            const SizedBox(height: 30),
                            
                            _buildTextField(
                              controller: nameCtrl, 
                              label: "الاسم الكامل", 
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء إدخال الاسم';
                                return null;
                              },
                            ).animate().slideX(begin: 0.2, delay: 300.ms).fadeIn(),
                            const SizedBox(height: 16),
                            
                            _buildTextField(
                              controller: emailCtrl, 
                              label: "البريد الإلكتروني", 
                              icon: Icons.email_outlined, 
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                                if (!GetUtils.isEmail(value)) return 'بريد إلكتروني غير صالح';
                                return null;
                              },
                            ).animate().slideX(begin: 0.2, delay: 400.ms).fadeIn(),
                            const SizedBox(height: 16),
                            
                            _buildTextField(
                              controller: phoneCtrl, 
                              label: "رقم الهاتف", 
                              icon: Icons.phone_outlined, 
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء إدخال رقم الهاتف';
                                return null;
                              },
                            ).animate().slideX(begin: 0.2, delay: 500.ms).fadeIn(),
                            const SizedBox(height: 16),
                            
                            Obx(() => _buildTextField(
                              controller: passwordCtrl,
                              label: "كلمة المرور",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: controller.isPasswordHidden.value,
                              onTogglePassword: controller.togglePasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                                if (value.length < 6) return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
                                return null;
                              },
                            )).animate().slideX(begin: 0.2, delay: 600.ms).fadeIn(),
                            
                            const SizedBox(height: 16),

                            Obx(() => _buildTextField(
                              controller: confirmPasswordCtrl,
                              label: "تأكيد كلمة المرور",
                              icon: Icons.lock_reset_outlined,
                              isPassword: true,
                              obscureText: controller.isPasswordHidden.value,
                              onTogglePassword: controller.togglePasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء تأكيد كلمة المرور';
                                if (value != passwordCtrl.text) return 'كلمات المرور غير متطابقة';
                                return null;
                              },
                            )).animate().slideX(begin: 0.2, delay: 650.ms).fadeIn(),
                            
                            const SizedBox(height: 35),
                            
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value 
                                  ? null 
                                  : () {
                                      if (controller.registerFormKey.currentState!.validate()) {
                                        controller.register(nameCtrl.text.trim(), emailCtrl.text.trim(), phoneCtrl.text.trim(), passwordCtrl.text);
                                      }
                                    },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  shadowColor: Colors.black45,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: controller.isLoading.value 
                                  ? const CircularProgressIndicator(color: AppColors.primary)
                                  : const Text("إنشاء حساب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            )).animate().fadeIn(delay: 700.ms).scale(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().shimmer(duration: 2000.ms, color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white),
              onPressed: onTogglePassword,
            )
          : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        errorStyle: const TextStyle(color: Colors.amberAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white24, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white24, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.amberAccent, width: 1)),
      ),
    );
  }
}