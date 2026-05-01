import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import '../../../core/theme/app_colors.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HistoryController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('activity_log'.tr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), 
                  const SizedBox(height: 8),
                  Text('activity_log_desc'.tr, style: TextStyle(fontSize: 14, color: Colors.grey[600])), 
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }

            if (controller.historyLog.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text('no_activities'.tr, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 100), 
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.historyLog[index];
                    return _buildTimelineItem(item, index)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                  childCount: controller.historyLog.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(invoice, int index) {
    bool isLast = index == controller.historyLog.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60, 
                  color: AppColors.primary.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('new_invoice_created'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(controller.getTimeAgo(invoice.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 'customer' is already in your translation file!
                  Text("${'customers'.tr}: ${invoice.customerName}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${'invoice_num'.tr}: ${invoice.id}", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      Text(
                        "${invoice.total.toStringAsFixed(2)} DA", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}