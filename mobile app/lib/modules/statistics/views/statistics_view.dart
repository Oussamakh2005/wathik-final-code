import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/statistics_controller.dart';
import '../../../core/theme/app_colors.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(StatisticsController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              Obx(
                () => IconButton(
                  onPressed: controller.isAiAnalyzing.value || controller.isLoading.value
                      ? null
                      : controller.analyzeBusinessWithAI,
                  icon: controller.isAiAnalyzing.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology_alt_rounded),
                  tooltip: 'تحليل ذكي',
                  color: AppColors.primary,
                ),
              ),
            ],
            bottom: TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: 'sales'.tr),
                Tab(text: 'purchases'.tr),
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildSalesDashboard(context),
            _buildPurchasesDashboard(context), 
          ],
        ),
      ),
    );
  }

  Widget _buildSalesDashboard(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartHeader(),
                  const SizedBox(height: 20),
                  
                  // 1. Interactive & Premium Total Balance Card
                  _buildTotalBalanceCard().animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutBack),
                  const SizedBox(height: 25),
                  
                  // 2. Revenue Chart
                  _buildRevenueChart(isSales: true).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 25),
                  
                  // 3. Status Breakdown (Pie Chart)
                  Text('payment_status'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 15),
                  _buildPieChartSection().animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 25),

                  // 4. Financial Details Grid
                  Text('financial_details'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 15),
                  _buildFinancialDetailsGrid().animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 25),

                  // 5. Top Customers List
                  Text('top_customers_revenue'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 15),
                  _buildTopCustomersList().animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 120), // Space for bottom nav
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasesDashboard(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text('no_purchases_data'.tr, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text('overview'.tr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => TextButton.icon(
                onPressed: controller.isAiAnalyzing.value || controller.isLoading.value
                    ? null
                    : controller.analyzeBusinessWithAI,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: controller.isAiAnalyzing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology_alt_rounded, size: 18),
                label: const Text(
                  'AI تحليل',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      items: controller.filters.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark)))).toList(),
                      onChanged: (val) { if (val != null) controller.changeFilter(val); },
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  // --- FANTASTIC INTERACTIVE PREMIUM CARD ---
  Widget _buildTotalBalanceCard() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isTapped = false;
        
        return GestureDetector(
          onTapDown: (_) => setState(() => isTapped = true),
          onTapUp: (_) => setState(() => isTapped = false),
          onTapCancel: () => setState(() => isTapped = false),
          onTap: () {
            // Interactive Action
            Get.snackbar(
              'total_revenue'.tr, 
              'tap_for_details_msg'.tr, // e.g., "This represents all your generated income"
              backgroundColor: const Color(0xFFD4AF37), // Premium Gold
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(15),
              borderRadius: 15,
              icon: const Icon(Icons.insights, color: Colors.white),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..scale(isTapped ? 0.96 : 1.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft, 
                  end: Alignment.bottomRight
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(isTapped ? 0.2 : 0.5), 
                    blurRadius: isTapped ? 10 : 25, 
                    offset: Offset(0, isTapped ? 5 : 12)
                  )
                ],
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5), // Glassmorphism edge
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // --- Decorative Background Elements ---
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD4AF37).withOpacity(0.15)),
                    ),
                  ),
                  
                  // --- Card Content ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('total_revenue'.tr, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                          const Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 28) // Gold Premium Icon
                              .animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 2000.ms, delay: 1000.ms, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() => Text(
                        controller.currencyFormatter.format(controller.totalSales.value),
                        style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      )),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.trending_up, color: Color(0xFF00E676), size: 16),
                                const SizedBox(width: 6),
                                Text('updated_now'.tr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text('tap_for_details'.tr, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildRevenueChart({required bool isSales}) {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 20, right: 20, left: 10, bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Obx(() {
        final spots = isSales ? controller.salesChartData : controller.purchasesChartData;
        double maxY = 100;
        for (var spot in spots) { if (spot.y > maxY) maxY = spot.y; }

        return LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.2,
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1)),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12))),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: AppColors.primary,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: AppColors.primary)),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPieChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 120,
              child: Obx(() {
                final status = controller.statusBreakdown;
                if (status['Paid'] == 0 && status['Pending'] == 0 && status['Overdue'] == 0) {
                  return Center(child: Text('no_data'.tr));
                }
                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      if ((status['Paid'] ?? 0) > 0) PieChartSectionData(color: const Color(0xFF00C853), value: status['Paid'], title: '', radius: 25),
                      if ((status['Pending'] ?? 0) > 0) PieChartSectionData(color: const Color(0xFFFFC107), value: status['Pending'], title: '', radius: 20),
                      if ((status['Overdue'] ?? 0) > 0) PieChartSectionData(color: const Color(0xFFFF3D00), value: status['Overdue'], title: '', radius: 20),
                    ],
                  ),
                );
              }),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(const Color(0xFF00C853), 'paid'.tr),
              const SizedBox(height: 8),
              _buildLegendItem(const Color(0xFFFFC107), 'pending'.tr),
              const SizedBox(height: 8),
              _buildLegendItem(const Color(0xFFFF3D00), 'overdue'.tr),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFinancialDetailsGrid() {
    return Row(
      children: [
        Expanded(child: Obx(() => _buildStatSquare(Icons.percent, 'total_taxes'.tr, controller.currencyFormatter.format(controller.totalTaxes.value), Colors.purple))),
        const SizedBox(width: 15),
        Expanded(child: Obx(() => _buildStatSquare(Icons.money_off, 'discounts_granted'.tr, controller.currencyFormatter.format(controller.totalDiscounts.value), Colors.pink))),
      ],
    );
  }

  Widget _buildStatSquare(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopCustomersList() {
    return Obx(() {
      if (controller.topCustomers.isEmpty) {
        return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('no_customers_yet'.tr, style: const TextStyle(color: Colors.grey))));
      }

      return Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
        child: Column(
          children: controller.topCustomers.map((customer) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(customer.key.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              title: Text(customer.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                controller.currencyFormatter.format(customer.value),
                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}