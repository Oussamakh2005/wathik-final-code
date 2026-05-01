import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/invoice_model.dart';
import '../views/business_ai_analysis_view.dart';

class StatisticsController extends GetxController {
  final currencyFormatter =
      NumberFormat.currency(locale: 'fr_DZ', symbol: 'DA', decimalDigits: 2);
  final _settingsBox = Hive.box('settings');

  // === إعدادات Groq API ===
  static const String _groqModel = 'llama-3.3-70b-versatile';
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  //static const String _groqApiKey = 'apikey'; 

  // --- UI STATE ---
  final isLoading = true.obs;
  final isAiAnalyzing = false.obs;
  final selectedFilter = 'شهر'.obs;
  final filters = ['يوم', 'أسبوع', 'شهر', 'سنة'];

  // --- DASHBOARD DATA ---
  final totalInvoices = 0.obs;
  final paidInvoices = 0.obs;
  final totalSales = 0.0.obs;
  final pendingDebt = 0.0.obs;
  final successRate = 0.obs;
  final averageInvoiceValue = 0.0.obs;

  // --- NEW ADVANCED DATA ---
  final totalTaxes = 0.0.obs;
  final totalDiscounts = 0.0.obs;
  final statusBreakdown =
      <String, double>{'Paid': 0.0, 'Pending': 0.0, 'Overdue': 0.0}.obs;
  final topCustomers = <MapEntry<String, double>>[].obs;

  // --- CHART DATA ---
  final salesChartData = <FlSpot>[].obs;
  final purchasesChartData = <FlSpot>[].obs;

  late Box<InvoiceModel> _invoicesBox;

  @override
  void onInit() async {
    super.onInit();
    await _initDatabase();
  }

  Future<void> _initDatabase() async {
    _invoicesBox = await Hive.openBox<InvoiceModel>('invoices_box');
    _invoicesBox.listenable().addListener(() {
      _calculateStatistics();
    });
    _calculateStatistics();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _calculateStatistics();
  }

  Future<void> analyzeBusinessWithAI() async {
    if (isAiAnalyzing.value) return;

    try {
      final apiKey = await _resolveApiKey();
      if (apiKey == null || apiKey.trim().isEmpty) {
        Get.snackbar(
          'مفتاح الذكاء الاصطناعي'.tr,
          'يرجى إدخال مفتاح Groq في الكود'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      isAiAnalyzing.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final statsPayload = _buildAiPayload();
      final prompt = _buildBusinessPrompt(statsPayload);

      final response = await http
          .post(
            Uri.parse(_groqApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _groqModel,
              'response_format': {'type': 'json_object'}, // ضمان استرجاع JSON صحيح
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'أنت مستشار أعمال ومالية محترف. قدم إجابة عربية واضحة، عملية، ومباشرة. يجب أن تكون الاستجابة بصيغة JSON فقط.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                },
              ],
              'temperature': 0.35,
              'max_tokens': 1200,
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode != 200) {
        Get.snackbar(
          'خطأ',
          'فشل إنشاء التحليل: ${response.statusCode}\n${response.body}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      // ======= التعديل هنا لفك تشفير الحروف العربية =======
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      // ====================================================

      final content = _extractAssistantContent(decoded);
      final analysis = _parseAnalysisResponse(content, statsPayload);

      Get.to(() => BusinessAiAnalysisView(analysis: analysis));
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'خطأ'.tr,
        'تعذر تحليل البيانات بالذكاء الاصطناعي'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('AI ANALYSIS ERROR: $e');
    } finally {
      isAiAnalyzing.value = false;
    }
  }

  void _calculateStatistics() {
    isLoading.value = true;
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedFilter.value) {
      case 'يوم':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'أسبوع':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'سنة':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'شهر':
      default:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    final filteredInvoices = _invoicesBox.values
        .where((inv) =>
            inv.date.isAfter(startDate) || inv.date.isAtSameMomentAs(startDate))
        .toList();

    double tempSales = 0;
    double tempPending = 0;
    double tempTax = 0;
    double tempDiscount = 0;
    int paidCount = 0;

    Map<double, double> salesByTime = {};
    Map<String, double> customerSales = {};
    Map<String, double> tempStatus = {
      'Paid': 0.0,
      'Pending': 0.0,
      'Overdue': 0.0
    };

    for (var inv in filteredInvoices) {
      tempSales += inv.total;
      tempTax += inv.taxAmount;
      tempDiscount += inv.discount;

      // Status breakdown by Money
      tempStatus[inv.status] = (tempStatus[inv.status] ?? 0) + inv.total;

      // Top Customers breakdown
      customerSales[inv.customerName] =
          (customerSales[inv.customerName] ?? 0) + inv.total;

      if (inv.status == 'Paid') {
        paidCount++;
      } else {
        tempPending += inv.total;
      }

      double timeKey;
      if (selectedFilter.value == 'سنة') {
        timeKey = inv.date.month.toDouble();
      } else if (selectedFilter.value == 'أسبوع') {
        timeKey = inv.date.weekday.toDouble();
      } else {
        timeKey = inv.date.day.toDouble();
      }

      salesByTime[timeKey] = (salesByTime[timeKey] ?? 0) + inv.total;
    }

    // Assign advanced data
    totalInvoices.value = filteredInvoices.length;
    paidInvoices.value = paidCount;
    totalSales.value = tempSales;
    pendingDebt.value = tempPending;
    totalTaxes.value = tempTax;
    totalDiscounts.value = tempDiscount;
    statusBreakdown.value = tempStatus;
    averageInvoiceValue.value =
        filteredInvoices.isNotEmpty ? tempSales / filteredInvoices.length : 0;

    // Sort top customers
    var sortedCustomers = customerSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topCustomers
        .assignAll(sortedCustomers.take(4).toList()); // Keep top 4 for UI

    if (filteredInvoices.isNotEmpty) {
      successRate.value = ((paidCount / filteredInvoices.length) * 100).round();
    } else {
      successRate.value = 0;
    }

    final spots =
        salesByTime.entries.map((e) => FlSpot(e.key, e.value)).toList();
    spots.sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) {
      salesChartData.assignAll([const FlSpot(0, 0), const FlSpot(1, 0)]);
    } else if (spots.length == 1) {
      salesChartData.assignAll([
        FlSpot(spots.first.x - 1, 0),
        spots.first,
        FlSpot(spots.first.x + 1, 0)
      ]);
    } else {
      salesChartData.assignAll(spots);
    }

    isLoading.value = false;
  }

  Future<String?> _resolveApiKey() async {
    if (_groqApiKey.isEmpty) {
      return null;
    }
    return _groqApiKey;
  }

  Map<String, dynamic> _buildAiPayload() {
    return {
      'currency': 'DA (الدينار الجزائري)',
      'period': selectedFilter.value,
      'invoiceCount': totalInvoices.value,
      'paidInvoices': paidInvoices.value,
      'successRate': '${successRate.value}%',
      'totalSales': totalSales.value,
      'pendingDebt': pendingDebt.value,
      'totalTaxes': totalTaxes.value,
      'totalDiscounts': totalDiscounts.value,
      'averageInvoiceValue': averageInvoiceValue.value,
      'statusBreakdown': statusBreakdown
          .map((key, value) => MapEntry(key, value.toStringAsFixed(2))),
      'topCustomers': topCustomers
          .map((entry) => {
                'name': entry.key,
                'value': entry.value,
              })
          .toList(),
    };
  }

  String _buildBusinessPrompt(Map<String, dynamic> stats) {
    return '''
أنت مستشار مالي واستراتيجي نخبوي متخصص في تطوير الشركات الصغيرة والمستقلين (Freelancers) في السوق الجزائري.

مهمتك:
تحليل هذه البيانات المالية للفترة المحددة ("${stats['period']}") وتقديم استشارة أعمال دقيقة وعملية جداً لصاحب المشروع المسمى "واثق". لا تعطِ نصائح عامة، بل خطوات قابلة للتنفيذ فوراً بناءً على الأرقام.

البيانات المالية:
${jsonEncode(stats)}

قواعد التحليل:
1. تقييم الديون (Pending Debt): إذا كانت الديون عالية مقارنة بالإيرادات، اقترح طرقاً ذكية لتحصيلها بلطف واحترافية.
2. العملاء المميزون (Top Customers): اقترح كيفية الحفاظ على هؤلاء العملاء (مثلاً: برامج ولاء، خصومات خاصة).
3. متوسط الفاتورة (Average Invoice Value): كيف يمكن زيادة هذا الرقم (Upselling/Cross-selling)؟
4. نسبة النجاح (Success Rate): علق على كفاءة التحصيل.

يجب أن يكون الإخراج بصيغة JSON صحيحة فقط، بدون أي نصوص أو مقدمات أو رموز Markdown إضافية، وفق هذا الهيكل تماماً:
{
  "summary": "ملخص تنفيذي احترافي يصف صحة العمل بدقة (3-4 أسطر).",
  "strengths": ["نقطة قوة 1 مبنية على الأرقام", "نقطة قوة 2"],
  "risks": ["خطر 1 (مثل الديون غير المحصلة أو انخفاض المبيعات)", "خطر 2"],
  "recommendations": ["توصية استراتيجية 1", "توصية استراتيجية 2"],
  "quickWins": ["إجراء فوري 1 لزيادة الكاش اليوم", "إجراء فوري 2"],
  "nextSteps": ["خطوة عملية 1 للبدء بها غداً", "خطوة عملية 2"]
}
''';
  }

  String _extractAssistantContent(Map<String, dynamic> responseJson) {
    final choices = responseJson['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = choices.first['message'];
      if (message is Map<String, dynamic>) {
        final content = message['content'];
        if (content is String) {
          return content;
        }
      }
    }
    return responseJson.toString();
  }

  Map<String, dynamic> _parseAnalysisResponse(
      String content, Map<String, dynamic> statsPayload) {
    final cleaned = _stripCodeFences(content);

    try {
      final parsed = jsonDecode(cleaned);
      if (parsed is Map<String, dynamic>) {
        return {
          'summary': parsed['summary'] ?? cleaned,
          'strengths': _toStringList(parsed['strengths']),
          'risks': _toStringList(parsed['risks']),
          'recommendations': _toStringList(parsed['recommendations']),
          'quickWins': _toStringList(parsed['quickWins']),
          'nextSteps': _toStringList(parsed['nextSteps']),
          'raw': cleaned,
          'stats': statsPayload,
        };
      }
    } catch (_) {
      // Fall back to plain text below.
    }

    return {
      'summary': cleaned,
      'strengths': <String>[],
      'risks': <String>[],
      'recommendations': <String>[cleaned],
      'quickWins': <String>[],
      'nextSteps': <String>[],
      'raw': cleaned,
      'stats': statsPayload,
    };
  }

  String _stripCodeFences(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('```')) {
      return trimmed
          .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    return trimmed;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return <String>[];
  }
}