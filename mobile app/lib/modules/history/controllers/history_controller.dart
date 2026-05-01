import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/invoice_model.dart';

class HistoryController extends GetxController {
  final historyLog = <InvoiceModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() async {
    isLoading.value = true;
    
    // Open the local database on the phone
    final box = await Hive.openBox<InvoiceModel>('invoices_box');
    
    // Get all saved invoices
    final items = box.values.toList();
    
    // Sort them from newest to oldest
    items.sort((a, b) => b.date.compareTo(a.date));
    
    historyLog.assignAll(items);
    isLoading.value = false;
  }

  // A helper function to format the time easily
// A helper function to format the time and translate it
  String getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) return 'days_ago'.trParams({'days': difference.inDays.toString()});
    if (difference.inHours > 0) return 'hours_ago'.trParams({'hours': difference.inHours.toString()});
    if (difference.inMinutes > 0) return 'minutes_ago'.trParams({'minutes': difference.inMinutes.toString()});
    return 'just_now'.tr;
  }
}