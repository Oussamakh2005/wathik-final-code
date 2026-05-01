import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wathiq/modules/auth/views/login_view.dart';
import '../../../data/models/user_model.dart';
import '../../main_layout/views/main_layout_view.dart';

// IMPORTANT: Import the new subscription view!
import '../../subscription/views/subscription_view.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  late Box<UserModel> _usersBox;
  late Box _sessionBox;

  static const int tokenValidityDays = 30;

  @override
  void onInit() async {
    super.onInit();
    _usersBox = await Hive.openBox<UserModel>('users_box');
    _sessionBox = Hive.box('session');
  }

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  // --- SIGN UP LOGIC ---
  Future<void> register(String fullName, String email, String phone, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final cleanEmail = email.toLowerCase().trim();
      final cleanPassword = password.trim(); 
      
      final userExists = _usersBox.values.any((user) => user.email == cleanEmail);
      if (userExists) {
        _showError('email_exists'.tr);
        isLoading.value = false;
        return;
      }

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: fullName.trim(),
        email: cleanEmail,
        phone: phone.trim(),
        password: cleanPassword, 
      );

      await _usersBox.put(newUser.id, newUser);

      Get.snackbar(
        'register_success'.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(seconds: 2));
      
      // Auto-login after register and go to Subscription
      await _createSession(newUser);
      Get.offAll(() => const LoginView(), transition: Transition.fadeIn);
      
    } catch (e) {
      _showError("حدث خطأ أثناء إنشاء الحساب"); 
    } finally {
      isLoading.value = false;
    }
  }

  // --- SIGN IN LOGIC ---
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final cleanEmail = email.toLowerCase().trim();
      final cleanPassword = password.trim(); 

      UserModel? matchedUser;
      for (var u in _usersBox.values) {
        if (u.email == cleanEmail && u.password == cleanPassword) {
          matchedUser = u;
          break; 
        }
      }

      if (matchedUser != null) {
        await _createSession(matchedUser);
        
        // --- REDIRECT TO SUBSCRIPTION SCREEN ---
        Get.offAll(() => const SubscriptionView(), transition: Transition.fadeIn);
      } else {
        _showError('invalid_credentials'.tr); 
      }
      
    } catch (e) {
      debugPrint("Login Error: $e");
      _showError('invalid_credentials'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createSession(UserModel user) async {
    final expiresAt = DateTime.now().add(const Duration(days: tokenValidityDays));
    
    await _sessionBox.put('token', 'auth_${user.id}');
    await _sessionBox.put('token_expires_at', expiresAt.toIso8601String());
    await _sessionBox.put('user_id', user.id);
    
    await _sessionBox.put('userName', user.fullName);
    await _sessionBox.put('userEmail', user.email);
  }

  static bool isTokenValid(Box sessionBox) {
    final token = sessionBox.get('token');
    if (token == null) return false;

    final expiryStr = sessionBox.get('token_expires_at');
    if (expiryStr == null) return false;

    try {
      final expiresAt = DateTime.parse(expiryStr);
      return DateTime.now().isBefore(expiresAt);
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _sessionBox.clear();
    Get.offAll(() => const LoginView(), transition: Transition.fadeIn);
  }

  void _showError(String message) {
    Get.snackbar(
      'auth_error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}