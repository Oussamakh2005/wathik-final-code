import 'package:get/get.dart';

class Validators {
  static String? validateAlgerianPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    // Matches 05..., 06..., 07... or +213...
    final RegExp phoneExp = RegExp(r'^(0|\+213)(5|6|7)[0-9]{8}$');
    if (!phoneExp.hasMatch(value)) {
      return 'invalid_phone'.tr; // Use localization key
    }
    return null;
  }
}