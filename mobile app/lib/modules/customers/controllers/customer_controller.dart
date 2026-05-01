import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../data/models/customer_model.dart';

class CustomerController extends GetxController {
  final currencyFormatter = NumberFormat.currency(locale: 'fr_DZ', symbol: 'DA', decimalDigits: 0);
  final customers = <CustomerModel>[].obs;
  late Box<CustomerModel> _customersBox;

  @override
  void onInit() async {
    super.onInit();
    _customersBox = Hive.box<CustomerModel>('customers_box');
    _loadCustomers();
  }

  void _loadCustomers() {
    customers.assignAll(_customersBox.values.toList());
  }

  Future<void> addCustomer({
    required String fullName,
    required String phoneNumber,
    double initialDebt = 0.0,
  }) async {
    final newCustomer = CustomerModel(
      id: 'CUST-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      phoneNumber: phoneNumber,
      totalDebt: initialDebt,
      totalInvoices: 0,
      overdueInvoices: 0,
      reminderCount: 0, // NEW
    );

    await _customersBox.put(newCustomer.id, newCustomer);
    customers.add(newCustomer);

    // Green Snackbar
    Get.snackbar(
      'نجاح', // Arabic 'Success'
      'تم إضافة العميل بنجاح', // Arabic 'Client added successfully'
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> deleteCustomer(String id) async {
    await _customersBox.delete(id);
    customers.removeWhere((c) => c.id == id);
  }

  int calculateTrustScore(CustomerModel customer) {
    if (customer.totalInvoices == 0) return 70;
    double penalty = (customer.overdueInvoices / customer.totalInvoices) * 100;
    double debtPenalty = customer.totalDebt > 100000 ? 20 : (customer.totalDebt > 0 ? 10 : 0);
    int score = (100 - penalty - debtPenalty).round();
    return score.clamp(0, 100);
  }

  Color getTrustScoreColor(int score) {
    if (score >= 80) return const Color(0xFF00C853);
    if (score >= 50) return const Color(0xFFFFC107);
    return const Color(0xFFFF3D00);
  }

  List<CustomerModel> get debtors => customers.where((c) => c.totalDebt > 0).toList();

  // Updated to track reminders
  Future<void> sendWhatsAppReminder(CustomerModel customer) async {
    customer.reminderCount += 1;
    customer.lastReminderDate = DateTime.now();
    await customer.save(); // Save to Hive
    customers.refresh(); // Update UI

    Get.snackbar(
      'تذكير',
      'تم إرسال تذكير إلى ${customer.phoneNumber}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF25D366).withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.message, color: Colors.white),
      margin: const EdgeInsets.all(15),
    );
  }
}