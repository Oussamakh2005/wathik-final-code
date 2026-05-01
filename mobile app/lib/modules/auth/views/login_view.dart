import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
import '../../../core/theme/app_colors.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    
    // Form Controllers
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // Premium Animated Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  Color(0xFF8A2387), 
                  Color(0xFFE94057),
                ],
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 5000.ms, color: Colors.white12),

          // Floating decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            ).animate().slide(duration: 3000.ms, curve: Curves.easeInOutSine).scale(),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            ).animate().slide(duration: 4000.ms, curve: Curves.easeInOutSine),
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
                        key: controller.loginFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Premium Logo
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                                  ]
                                ),
                                child: Image.asset('assets/images/logo.png', width: 80, height: 80),
                              ),
                            ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                            
                            const SizedBox(height: 20),
                            
                            // App Name
                            const Text(
                              "وثيق", 
                              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                            const SizedBox(height: 8),

                            Text('welcome_back'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)).animate().fadeIn(delay: 400.ms),
                            Text('login_subtitle'.tr, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))).animate().fadeIn(delay: 500.ms),
                            
                            const SizedBox(height: 35),
                            
                            // Email Field
                            _buildTextField(
                              controller: emailCtrl,
                              label: 'email'.tr,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                                if (!GetUtils.isEmail(value)) return 'بريد إلكتروني غير صالح';
                                return null;
                              },
                            ).animate().slideX(begin: 0.2, delay: 600.ms).fadeIn(),
                            
                            const SizedBox(height: 20),
                            
                            // Password Field
                            Obx(() => _buildTextField(
                              controller: passwordCtrl,
                              label: 'password'.tr,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: controller.isPasswordHidden.value,
                              onTogglePassword: controller.togglePasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                                if (value.length < 6) return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
                                return null;
                              },
                            )).animate().slideX(begin: 0.2, delay: 700.ms).fadeIn(),
                            
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                child: Text('forgot_password'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            
                            const SizedBox(height: 25),
                            
                            // Login Button
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value 
                                  ? null 
                                  : () {
                                      if (controller.loginFormKey.currentState!.validate()) {
                                        controller.login(emailCtrl.text.trim(), passwordCtrl.text);
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
                                  : Text('login'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            )).animate().fadeIn(delay: 800.ms).scale(),
                            
                            const SizedBox(height: 25),
                            
                            // Go to Register
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('no_account'.tr, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                TextButton(
                                  onPressed: () => Get.to(() => const RegisterView(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 600)),
                                  child: Text('create_account'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ],
                            ).animate().fadeIn(delay: 900.ms),
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