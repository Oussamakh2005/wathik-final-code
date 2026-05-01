import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; 
import '../controllers/customer_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/customer_model.dart';

class CustomersView extends GetView<CustomerController> {
  const CustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            bottom: TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'all_clients'.tr),
                Tab(text: 'outstanding_debts'.tr),
              ],
            ),
          ),
        ),
        
        // --- UPGRADED PREMIUM UI: ADD CLIENT BUTTON ---
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0), 
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showAddClientSheet(context),
              backgroundColor: Colors.transparent, 
              elevation: 0, 
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: Text('add_client'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
        ),
        
        body: TabBarView(
          children: [
            _buildCustomerList(isDebtView: false),
            _buildCustomerList(isDebtView: true),
          ],
        ),
      ),
    );
  }

  void _showAddClientSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final debtCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person_add, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('add_client'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ).animate().fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 24),

                TextFormField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'full_name'.tr,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'phone_number'.tr,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'field_required'.tr;
                    if (v.trim().length < 9) return 'invalid_phone'.tr;
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),

                const SizedBox(height: 16),

                TextFormField(
                  controller: debtCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'initial_debt'.tr,
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                    suffixText: 'DA',
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: Text('cancel'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final debt = double.tryParse(debtCtrl.text) ?? 0.0;
                            await controller.addCustomer(
                              fullName: nameCtrl.text.trim(),
                              phoneNumber: phoneCtrl.text.trim(),
                              initialDebt: debt,
                            );
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text('save'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCustomerList({required bool isDebtView}) {
    return Obx(() {
      final list = isDebtView ? controller.debtors : controller.customers;

      if (list.isEmpty) {
        return _buildEmptyState(isDebtView);
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildCustomerCard(list[index], isDebtView)
              .animate()
              .fadeIn(duration: 400.ms, delay: (index * 60).ms)
              .slideX(begin: 0.1, end: 0);
        },
      );
    });
  }

  Widget _buildCustomerCard(CustomerModel customer, bool isDebtView) {
    final trustScore = controller.calculateTrustScore(customer);
    final scoreColor = controller.getTrustScoreColor(trustScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(customer.phoneNumber, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: scoreColor),
                      const SizedBox(width: 4),
                      Text("$trustScore", style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (customer.totalDebt > 0) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('total_debt'.tr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        controller.currencyFormatter.format(customer.totalDebt),
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  if (isDebtView)
                    ElevatedButton.icon(
                      onPressed: () => controller.sendWhatsAppReminder(customer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366).withOpacity(0.1),
                        foregroundColor: const Color(0xFF25D366),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: Text('remind'.tr),
                    ),
                ],
              ),
              if (isDebtView && (customer.reminderCount ?? 0) > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 14, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'تم التذكير: ${customer.reminderCount} مرة | آخر مرة: ${customer.lastReminderDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(customer.lastReminderDate!) : ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF00C853)),
                  const SizedBox(width: 6),
                  Text('no_debt'.tr, style: const TextStyle(color: Color(0xFF00C853), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDebtView) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(isDebtView ? Icons.receipt_long_outlined : Icons.people_outline, size: 60, color: AppColors.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text('no_clients'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (!isDebtView) Text('add_first_client'.tr, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}