import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/invoice_model.dart';
import '../controllers/invoice_controller.dart';
import 'invoice_detail_view.dart';

class InvoiceItemData {
  TextEditingController nameCtrl;
  TextEditingController qtyCtrl;
  TextEditingController priceCtrl;
  InvoiceItemData(this.nameCtrl, this.qtyCtrl, this.priceCtrl);
}

class CreateInvoiceView extends StatefulWidget {
  final Map<String, dynamic>? apiResponseData; 

  const CreateInvoiceView({Key? key, this.apiResponseData}) : super(key: key);

  @override
  State<CreateInvoiceView> createState() => _CreateInvoiceViewState();
}

class _CreateInvoiceViewState extends State<CreateInvoiceView> {
  final TextEditingController customerCtrl = TextEditingController();
  final List<InvoiceItemData> items = [];
  List<CustomerModel> savedCustomers = [];
  
  // Variables to hold server match data
  int? _matchedCustomerId;
  String? _originalMatchedName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _initializeData();
  }

  void _loadCustomers() {
    final box = Hive.box<CustomerModel>('customers_box');
    savedCustomers = box.values.toList();
  }

  void _initializeData() {
    if (widget.apiResponseData != null) {
      final structured = widget.apiResponseData!['structured'] ?? {};
      final customerMatch = widget.apiResponseData!['customerMatch'] ?? {};

      // 1. Fill Customer Name safely
      customerCtrl.text = structured['customerName']?.toString() ?? '';
      
      // 2. Track API Match Data
      if (customerMatch['status'] == 'matched' && customerMatch['customerId'] != null) {
        _matchedCustomerId = customerMatch['customerId'];
        _originalMatchedName = customerMatch['name'];
      }

      // 3. Fill Items Safely
      List<dynamic> extractedItems = structured['items'] ?? [];
      for (var item in extractedItems) {
        items.add(InvoiceItemData(
          TextEditingController(text: item['name']?.toString() ?? ''),
          TextEditingController(text: item['amount']?.toString() ?? '1'),
          TextEditingController(text: item['price']?.toString() ?? '0'),
        ));
      }
    } 
    
    // Always ensure at least one empty row if no items exist
    if (items.isEmpty) {
      _addNewItemRow();
    }
  }

  void _addNewItemRow() {
    setState(() {
      items.add(InvoiceItemData(TextEditingController(), TextEditingController(text: '1'), TextEditingController()));
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in items) {
      double price = double.tryParse(item.priceCtrl.text) ?? 0;
      double qty = double.tryParse(item.qtyCtrl.text) ?? 0;
      total += (price * qty);
    }
    return total;
  }

  Future<void> _saveInvoice() async {
    if (customerCtrl.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_customer_name'.tr, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    double calculatedTotal = _calculateTotal();
    String finalCustomerName = customerCtrl.text.trim();

    // ==========================================
    // 1. PREPARE THE PAYLOAD FOR THE SERVER API
    // ==========================================
    List<Map<String, dynamic>> itemsPayload = items.map((item) {
      return {
        "name": item.nameCtrl.text.trim(),
        "price": double.tryParse(item.priceCtrl.text) ?? 0.0,
        "amount": int.tryParse(item.qtyCtrl.text) ?? 1,
      };
    }).toList();

    Map<String, dynamic> apiBody = {
      "customerName": finalCustomerName,
      "items": itemsPayload,
      "total": calculatedTotal,
    };

    // Apply the exact logic from your API Docs for linking
    if (_matchedCustomerId != null) {
      apiBody["customerId"] = _matchedCustomerId;
      if (finalCustomerName != _originalMatchedName) {
        apiBody["updateCustomer"] = true;
      } else {
        apiBody["updateCustomer"] = false;
      }
    }

    // Call the server
    final controller = Get.find<InvoiceController>();
    
    // نستقبل الـ ID القادم من السيرفر بدلاً من قيمة منطقية (bool)
    String? serverInvoiceId = await controller.saveInvoiceToServer(apiBody);

    if (serverInvoiceId == null) {
      setState(() => _isSaving = false);
      Get.snackbar('error'.tr, "فشل حفظ الفاتورة في السيرفر", backgroundColor: Colors.red, colorText: Colors.white);
      return; 
    }

    // ==========================================
    // 2. SAVE LOCALLY TO HIVE
    // ==========================================
    final newInvoice = InvoiceModel(
      id: serverInvoiceId, // نستخدم هنا الـ ID الخاص بالسيرفر!
      customerName: finalCustomerName,
      date: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      subTotal: calculatedTotal,
      taxAmount: 0.0,
      discount: 0.0,
      total: calculatedTotal,
      status: 'Pending',
    );

    final box = await Hive.openBox<InvoiceModel>('invoices_box');
    await box.put(newInvoice.id, newInvoice);
    controller.invoices.add(newInvoice);

    setState(() => _isSaving = false);
    
    Get.back(); // Close form
    Get.snackbar(
      'saved'.tr, 
      'invoice_created_successfully'.tr,
      backgroundColor: const Color(0xFF00C853),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    // Open Preview
    Get.to(() => InvoiceDetailView(invoice: newInvoice, items: items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('create_invoice'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('customer_info'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
            const SizedBox(height: 15),
            
            Autocomplete<CustomerModel>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<CustomerModel>.empty();
                return savedCustomers.where((CustomerModel option) {
                  return option.fullName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (CustomerModel option) => option.fullName,
              onSelected: (CustomerModel selection) {
                customerCtrl.text = selection.fullName;
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                if (customerCtrl.text.isNotEmpty && textEditingController.text.isEmpty) {
                  textEditingController.text = customerCtrl.text;
                }
                textEditingController.addListener(() { customerCtrl.text = textEditingController.text; });

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'customer_name'.tr,
                    prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('products'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
                TextButton.icon(
                  onPressed: _addNewItemRow,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  label: Text('add'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 10),

            ...items.asMap().entries.map((entry) {
              int index = entry.key;
              InvoiceItemData item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: item.nameCtrl,
                            decoration: InputDecoration(labelText: 'product_name'.tr, border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => setState(() => items.removeAt(index)),
                        )
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.qtyCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setState((){}), 
                            decoration: InputDecoration(labelText: 'quantity'.tr, border: InputBorder.none),
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.grey[300]),
                        Expanded(
                          child: TextField(
                            controller: item.priceCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setState((){}), 
                            decoration: InputDecoration(labelText: 'price_da'.tr, border: InputBorder.none, contentPadding: const EdgeInsets.only(right: 15)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 100), 
          ],
        ),
      ),
      
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('total'.tr, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    "${_calculateTotal().toStringAsFixed(2)} DA", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primaryDark)
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: _isSaving ? null : _saveInvoice,
                icon: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, color: Colors.white),
                label: Text(_isSaving ? "جاري الحفظ..." : 'save_invoice'.tr, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
