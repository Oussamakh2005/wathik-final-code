import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class BusinessAiAnalysisView extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const BusinessAiAnalysisView({Key? key, required this.analysis})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = (analysis['stats'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          centerTitle: true,
          // === تم التعديل هنا ليتناسق مع لون الخلفية ===
          backgroundColor: const Color(0xFFF5F7FB),
          foregroundColor: const Color(0xFF0F172A), // لون النص والأيقونات
          elevation: 0,
          title: const Text(
            'تحليل الذكاء الاصطناعي',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F7FB), Color(0xFFEFF4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeroCard(
                summary: analysis['summary']?.toString() ?? '',
                stats: stats,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.12, curve: Curves.easeOutCubic),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'نقاط القوة',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFF0EA5E9),
                items: _asStringList(analysis['strengths']),
              ).animate().fadeIn(delay: 120.ms),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'المخاطر والملاحظات',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFF97316),
                items: _asStringList(analysis['risks']),
              ).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'التوصيات العملية',
                icon: Icons.lightbulb_rounded,
                color: const Color(0xFF22C55E),
                items: _asStringList(analysis['recommendations']),
              ).animate().fadeIn(delay: 240.ms),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'مكاسب سريعة خلال 7 أيام',
                icon: Icons.bolt_rounded,
                color: const Color(0xFF8B5CF6),
                items: _asStringList(analysis['quickWins']),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'الخطوات التالية',
                icon: Icons.route_rounded,
                color: const Color(0xFF14B8A6),
                items: _asStringList(analysis['nextSteps']),
              ).animate().fadeIn(delay: 360.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _asStringList(dynamic value) {
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

class _HeroCard extends StatelessWidget {
  final String summary;
  final Map<String, dynamic> stats;

  const _HeroCard({required this.summary, required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalSales = _formatCurrency(stats['totalSales']);
    final pendingDebt = _formatCurrency(stats['pendingDebt']);
    final successRate = '${stats['successRate'] ?? 0}%';
    final averageValue = _formatCurrency(stats['averageInvoiceValue']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.psychology_alt_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ملخص ذكي لأداء نشاطك',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary.isNotEmpty ? summary : 'لم يتم توفير ملخص من النموذج.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                  label: 'الإيرادات',
                  value: totalSales,
                  icon: Icons.payments_rounded),
              _StatChip(
                  label: 'الديون',
                  value: pendingDebt,
                  icon: Icons.receipt_long_rounded),
              _StatChip(
                  label: 'نسبة السداد',
                  value: successRate,
                  icon: Icons.verified_rounded),
              _StatChip(
                  label: 'متوسط الفاتورة',
                  value: averageValue,
                  icon: Icons.stacked_line_chart_rounded),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    final numericValue = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    return 'DA ${numericValue.toStringAsFixed(2)}';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'لا توجد تفاصيل كافية في هذه الفقرة.',
              style: TextStyle(color: Colors.grey[600], height: 1.6),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BulletItem(text: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A8A),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}