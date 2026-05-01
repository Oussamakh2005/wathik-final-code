import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // IMPORTANT: Added for Clipboard
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/invoice_model.dart';
import 'create_invoice_view.dart'; 

class InvoiceDetailView extends StatelessWidget {
  final InvoiceModel invoice;
  final List<InvoiceItemData>? items; 
  
  const InvoiceDetailView({Key? key, required this.invoice, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      appBar: AppBar(
        title: Text('invoice_preview'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white,),
            tooltip: 'share'.tr,
            onPressed: () async {
              // 1. Create the dynamic link
              final String shareLink = 'https://phenomenal-medovik-221775.netlify.app/?id=${invoice.id}';
              
              // 2. Copy to clipboard
              await Clipboard.setData(ClipboardData(text: shareLink));
              
              // 3. Show success message
              Get.snackbar(
                'share'.tr, 
                'تم نسخ الرابط بنجاح', // Link copied successfully
                backgroundColor: AppColors.primary, 
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(15),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            tooltip: 'print'.tr,
            onPressed: () {
              // TODO: Add 'printing' & 'pdf' packages later
              Get.snackbar('print'.tr, 'connecting_printer'.tr, backgroundColor: AppColors.primary, colorText: Colors.white);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("WATHIQ", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 2)),
                        const SizedBox(height: 5),
                        Text('app_name'.tr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('invoice'.tr, style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(thickness: 1.5),
                ),

                // --- INVOICE INFO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('invoice_to'.tr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(invoice.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${'invoice_num_label'.tr}${invoice.id}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text("${'date_label'.tr}${DateFormat('yyyy/MM/dd').format(DateTime.now())}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                // --- TABLE HEADER ---
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('product'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('quantity'.tr, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('price'.tr, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // --- TABLE ITEMS ---
                if (items != null && items!.isNotEmpty) 
                  ...items!.map((item) {
                    double qty = double.tryParse(item.qtyCtrl.text) ?? 1;
                    double price = double.tryParse(item.priceCtrl.text) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(item.nameCtrl.text.isEmpty ? 'product'.tr : item.nameCtrl.text)),
                          Expanded(flex: 1, child: Text(qty.toStringAsFixed(0), textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("${price.toStringAsFixed(2)} DA", textAlign: TextAlign.end)),
                        ],
                      ),
                    );
                  }).toList()
                else
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('only_total_imported'.tr, style: const TextStyle(color: Colors.grey)),
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(thickness: 1.5),
                ),

                // --- TOTAL ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('total'.tr, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(width: 20),
                    Text(
                      "${invoice.total.toStringAsFixed(2)} DA", 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                // --- FOOTER ---
                Center(
                  child: Text('thank_you_business'.tr, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}