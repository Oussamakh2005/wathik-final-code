import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models/invoice_model.dart';
import '../views/create_invoice_view.dart';

class InvoiceController extends GetxController {
  final isLoading = false.obs;
  final isOcrProcessing = false.obs;

  final invoices = <InvoiceModel>[].obs;

  final currencyFormatter =
      NumberFormat.currency(locale: 'fr_DZ', symbol: 'DA', decimalDigits: 2);
  final ImagePicker _picker = ImagePicker();

  // YOUR ACTUAL API URL
  final String apiUrl = 'https://api.wathik.amara57.com/api';

  @override
  void onInit() {
    super.onInit();
    _loadSavedInvoices();
  }

  Future<void> _loadSavedInvoices() async {
    try {
      final box = await Hive.openBox<InvoiceModel>('invoices_box');
      final savedInvoices = box.values.toList();
      savedInvoices.sort((a, b) => b.date.compareTo(a.date));
      invoices.assignAll(savedInvoices);
    } catch (e) {
      debugPrint("Error loading invoices: $e");
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF00C853);
      case 'Pending':
        return const Color(0xFFFFC107);
      case 'Overdue':
        return const Color(0xFFFF3D00);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  // --- API 1: PROCESS INVOICE (OCR + AI STRUCTURING) ---
  Future<void> processInvoice(ImageSource source) async {
    try {
      // 1. OPTIMIZE IMAGE FOR OCR (Prevents server timeout on large images)
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image != null) {
        Get.back(); // Close bottom sheet

        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        // 2. SEND TO SERVER (With OCR + LLM structuring)
        try {
          var request = http.MultipartRequest(
              'POST', Uri.parse('$apiUrl/invoice'));
          var multipartFile = await http.MultipartFile.fromPath('file', image.path);
          request.files.add(multipartFile);

          debugPrint("Sending invoice to API: ${image.path}");

          // Let it take up to 60 seconds since LLMs can be slow
          var response =
              await request.send().timeout(const Duration(seconds: 60));
          var responseData = await response.stream.bytesToString();
          
          debugPrint("API Response Status: ${response.statusCode}");
          debugPrint("API Response Body: $responseData");

          Get.back(); // Close Loading dialog

          // 3. HANDLE RESPONSE
          if (response.statusCode == 200) {
            try {
              var json = jsonDecode(responseData);
              
              if (json != null && json['status'] == 'ok') {
                Get.snackbar(
                  'نجاح'.tr,
                  'تم استخراج البيانات بنجاح'.tr,
                  backgroundColor: const Color(0xFF00C853).withOpacity(0.9),
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );

                // Pass the WHOLE JSON response to the Create screen
                Get.to(() => CreateInvoiceView(apiResponseData: json));
              } else {
                var errorMsg = json?['msg'] ?? 'فشل في معالجة الفاتورة'.tr;
                Get.snackbar('error'.tr, errorMsg,
                    backgroundColor: Colors.red, colorText: Colors.white);
                debugPrint("API Error Message: $errorMsg");
              }
            } catch (parseError) {
              Get.snackbar('error'.tr, 'خطأ في معالجة البيانات المرجعة'.tr,
                  backgroundColor: Colors.red, colorText: Colors.white);
              debugPrint("JSON Parse Error: $parseError");
            }
          } else {
            Get.snackbar('error'.tr, 'خطأ من الخادم: ${response.statusCode}'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
            debugPrint("Server Error: ${response.statusCode}");
          }
        } catch (requestError) {
          Get.back();
          debugPrint("Request ERROR: $requestError");
          Get.snackbar('error'.tr, 'فشل الاتصال بالخادم'.tr,
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.back();
      debugPrint("OCR ERROR: $e");
      Get.snackbar('error'.tr, 'حدث خطأ في اختيار الصورة'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- API 2: SAVE INVOICE TO SERVER ---// --- API 2: SAVE INVOICE TO SERVER ---
  Future<String?> saveInvoiceToServer(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/invoice/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // فك تشفير استجابة السيرفر
        final jsonResponse = jsonDecode(response.body);
        
        // استخراج الـ ID القادم من السيرفر (حسب شكل الـ JSON الخاص بك)
        // يبحث في المفاتيح الشائعة: id أو invoiceId أو داخل كائن data أو invoice
        String serverId = jsonResponse['id']?.toString() ?? 
                          jsonResponse['invoiceId']?.toString() ??
                          jsonResponse['invoice']?['id']?.toString() ??
                          jsonResponse['data']?['id']?.toString() ?? 
                          '';

        if (serverId.isNotEmpty) {
          return serverId; // إرجاع الـ ID بنجاح
        } else {
          debugPrint("Server Save Success, but couldn't find ID in response: ${response.body}");
          return "SERVER-ID-MISSING"; // لتفادي الأخطاء إذا كان الرد لا يحتوي على ID صريح
        }
      } else {
        debugPrint("Server Save Failed: ${response.statusCode} - ${response.body}");
        return null; // فشل الحفظ
      }
    } catch (e) {
      debugPrint("Server Save Network Error: $e");
      return null;
    }
  }
}
