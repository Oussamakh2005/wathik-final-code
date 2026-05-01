import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class RateUsView extends StatefulWidget {
  const RateUsView({Key? key}) : super(key: key);

  @override
  State<RateUsView> createState() => _RateUsViewState();
}

class _RateUsViewState extends State<RateUsView> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('rate_us'.tr),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 100, color: Colors.amber)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms)
                  .shake(hz: 2, curve: Curves.easeInOutCubic),
              
              const SizedBox(height: 32),
              
              Text(
                'rate_us_title'.tr,
                style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 16),
              
              Text(
                'rate_us_subtitle'.tr,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 50,
                      color: index < _rating ? Colors.amber : Colors.grey[400],
                    ).animate(target: index < _rating ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                  );
                }),
              ).animate().slideY(begin: 0.5, delay: 500.ms),
              
              const SizedBox(height: 50),
              
              AnimatedOpacity(
                opacity: _rating > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: _rating > 0 ? () {
                    Get.back();
                    Get.snackbar('thank_you'.tr, 'appreciate_feedback'.tr, 
                      snackPosition: SnackPosition.BOTTOM, 
                      backgroundColor: Colors.green, 
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(20),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('submit_rating'.tr, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
