import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart'; 
import '../controllers/invoice_controller.dart';
import '../../../core/theme/app_colors.dart';

import 'create_invoice_view.dart'; 
import 'invoice_detail_view.dart'; 

class InvoicesView extends GetView<InvoiceController> {
  const InvoicesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(InvoiceController());

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, left: 20, right: 20), 
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: FloatingActionButton.extended(
                  heroTag: "manualCreateBtn", 
                  onPressed: () => Get.to(() => const CreateInvoiceView()),
                  backgroundColor: Colors.transparent, 
                  elevation: 0, 
                  icon: const Icon(Icons.edit_document, color: AppColors.primary),
                  label: Text('manual_create'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ),
            
            const SizedBox(width: 15),

            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: FloatingActionButton.extended(
                  heroTag: "scanInvoiceBtn", 
                  onPressed: () => _showOcrBottomSheet(context),
                  backgroundColor: Colors.transparent, 
                  elevation: 0, 
                  icon: const Icon(Icons.document_scanner, color: Colors.white),
                  label: Text('scan_invoice'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
      
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('recent_invoices'.tr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)), 
                  const SizedBox(height: 8),
                  Text('track_manage_invoices'.tr, style: TextStyle(fontSize: 14, color: Colors.grey[600])), 
                ],
              ),
            ),
          ),
          
          Obx(() {
            if (controller.invoices.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                        child: Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.primary.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 20),
                      Text('no_invoices_yet'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('create_or_scan_first_invoice'.tr, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      const SizedBox(height: 100), 
                    ],
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 150), 
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final invoice = controller.invoices[index];
                    return _buildPremiumInvoiceCard(invoice)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                  },
                  childCount: controller.invoices.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPremiumInvoiceCard(invoice) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => InvoiceDetailView(invoice: invoice));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 50, width: 50,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.receipt_long, color: AppColors.primary),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(invoice.id, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(controller.currencyFormatter.format(invoice.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: controller.getStatusColor(invoice.status).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        _translateStatus(invoice.status), 
                        style: TextStyle(color: controller.getStatusColor(invoice.status), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    // Dynamically translates "Paid", "Pending", "Overdue" using GetX .tr
    return status.toLowerCase().tr;
  }

  void _showOcrBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('smart_invoice_scan'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 30),
            _buildOptionButton(Icons.camera_alt, 'scan_camera'.tr, () {
              controller.processInvoice(ImageSource.camera);
            }),
            const SizedBox(height: 15),
            _buildOptionButton(Icons.photo_library, 'upload_gallery'.tr, () {
              controller.processInvoice(ImageSource.gallery);
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}