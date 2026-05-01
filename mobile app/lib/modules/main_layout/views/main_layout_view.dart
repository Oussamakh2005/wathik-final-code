import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart'; // REQUIRED for listenable()
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:wathiq/modules/history/views/history_view.dart';

import '../controllers/layout_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../statistics/views/statistics_view.dart';
import '../../invoices/views/invoices_view.dart';
import '../../customers/views/customers_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../drawer_pages/views/help_view.dart';
import '../../drawer_pages/views/about_us_view.dart';
import '../../drawer_pages/views/rate_us_view.dart';

class MainLayoutView extends GetView<LayoutController> {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.put(SettingsController());

    return Obx(() {
      bool isArabic = settingsCtrl.currentLanguage.value == 'ar';

      return Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: ZoomDrawer(
          controller: controller.drawerController,
          menuScreen: _buildDrawer(),
          mainScreen: _buildMainScreen(context), 
          borderRadius: 30.0,
          showShadow: true,
          angle: 0.0,
          drawerShadowsBackgroundColor: Colors.white.withOpacity(0.5),
          slideWidth: MediaQuery.of(context).size.width * 0.65,
          isRtl: isArabic,
        ),
      );
    });
  }

  Widget _buildMainScreen(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: controller.toggleDrawer,
        ),
        title: Obx(() => Text(_getTitle(controller.currentIndex.value))),
      ),
      
      // Page index is constantly standard: 0 = Invoices, 1 = Customers, 2 = Stats, 3 = History
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          InvoicesView(),
          CustomersView(),
          StatisticsView(),
          HistoryView(),
        ],
      ),
      extendBody: true, 
      
      bottomNavigationBar: Obx(() {
        final currentLang = Get.find<SettingsController>().currentLanguage.value;
        bool isArabic = currentLang == 'ar';

        // Keep the notch on the correct visual item when language flips
        int expectedVisualIndex = isArabic ? 3 - controller.currentIndex.value : controller.currentIndex.value;
        if (controller.notchController.index != expectedVisualIndex) {
          controller.notchController.jumpTo(expectedVisualIndex);
        }

        // FIXED 1: Removed `Directionality` wrapper!
        // The package's shape breaks under RTL mode. We let it render normally
        // and manually reverse the items in the array below to achieve the Arabic layout.
        return AnimatedNotchBottomBar(
          notchBottomBarController: controller.notchController,
          color: AppColors.primary, 
          notchColor: AppColors.primary, 
          itemLabelStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          showLabel: true,
          shadowElevation: 10,
          kBottomRadius: 28.0,
          removeMargins: false,
          bottomBarWidth: MediaQuery.of(context).size.width, 
          durationInMilliSeconds: 300,
          
          bottomBarItems: isArabic 
            ? [
                // ARABIC ORDER (Visual Left-To-Right puts Invoices on the Far Right!)
                BottomBarItem(inActiveItem: const Icon(Icons.history_outlined, color: Colors.white70), activeItem: const Icon(Icons.history, color: Colors.white), itemLabel: 'history'.tr),
                BottomBarItem(inActiveItem: const Icon(Icons.dashboard_outlined, color: Colors.white70), activeItem: const Icon(Icons.dashboard, color: Colors.white), itemLabel: 'statistics'.tr),
                BottomBarItem(inActiveItem: const Icon(Icons.people_outline, color: Colors.white70), activeItem: const Icon(Icons.people, color: Colors.white), itemLabel: 'customers'.tr),
                BottomBarItem(inActiveItem: const Icon(Icons.receipt_outlined, color: Colors.white70), activeItem: const Icon(Icons.receipt, color: Colors.white), itemLabel: 'invoices'.tr),
              ]
            : [
                // ENGLISH/FRENCH ORDER (Visual Left-To-Right puts Invoices on the Far Left)
                BottomBarItem(inActiveItem: const Icon(Icons.receipt_outlined, color: Colors.white70), activeItem: const Icon(Icons.receipt, color: Colors.white), itemLabel: 'invoices'.tr),
                BottomBarItem(inActiveItem: const Icon(Icons.people_outline, color: Colors.white70), activeItem: const Icon(Icons.people, color: Colors.white), itemLabel: 'customers'.tr),
                BottomBarItem(inActiveItem: const Icon(Icons.dashboard_outlined, color: Colors.white70), activeItem: const Icon(Icons.dashboard, color: Colors.white), itemLabel: 'statistics'.tr),
                BottomBarItem(inActiveItem: const Icon(Icons.history_outlined, color: Colors.white70), activeItem: const Icon(Icons.history, color: Colors.white), itemLabel: 'history'.tr),
              ],
          onTap: (visualIndex) {
            // Reverse the tap logic for Arabic so it opens the correct page
            int actualPage = isArabic ? 3 - visualIndex : visualIndex;
            controller.pageController.jumpToPage(actualPage);
            controller.currentIndex.value = actualPage; 
          },
          kIconSize: 22, 
        );
      }),
    );
  }

  String _getTitle(int index) {
    final titles = ['invoices'.tr, 'customers'.tr, 'statistics'.tr, 'history'.tr];
    return titles[index];
  }

  // ==========================================
  // RTL-ALIGNED PREMIUM DRAWER WITH DYNAMIC USER
  // ==========================================
  Widget _buildDrawer() {
    return Container(
      color: AppColors.primaryDark,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // FIXED 2: ValueListenableBuilder instantly updates UI and checks ALL possible Hive keys!
          ValueListenableBuilder(
            valueListenable: Hive.box('session').listenable(),
            builder: (context, Box sessionBox, _) {
              // Check all historically possible keys from your AuthController
              String userName = sessionBox.get('userName') ?? sessionBox.get('user_name') ?? sessionBox.get('name') ?? 'admin'.tr;
              String userEmail = sessionBox.get('userEmail') ?? sessionBox.get('user_email') ?? sessionBox.get('email') ?? 'admin@startup.dz';

              // Fallback check if the whole user object was saved
              final userObj = sessionBox.get('user');
              if (userObj != null) {
                try { userName = userObj.fullName ?? userObj.name ?? userName; } catch(_) {}
                try { userEmail = userObj.email ?? userEmail; } catch(_) {}
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(userEmail, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),

          _buildDrawerItem(Icons.language, 'change_language'.tr, onTap: () => _showLanguageBottomSheet()),

          Obx(() {
            final settingsCtrl = Get.find<SettingsController>();
            return _buildDrawerItem(
              settingsCtrl.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              settingsCtrl.isDarkMode.value ? 'light_mode'.tr : 'dark_mode'.tr,
              onTap: () => settingsCtrl.toggleTheme(),
            );
          }),

          _buildDrawerItem(Icons.help_outline, 'help'.tr, onTap: () => Get.to(() => const HelpView(), transition: Transition.rightToLeft)),
          _buildDrawerItem(Icons.info_outline, 'about_us'.tr, onTap: () => Get.to(() => const AboutUsView(), transition: Transition.rightToLeft)),
          _buildDrawerItem(Icons.star_border, 'rate_us'.tr, onTap: () => Get.to(() => const RateUsView(), transition: Transition.rightToLeft)),

          const Spacer(),

          OutlinedButton(
            onPressed: () {
              Get.find<AuthController>().logout();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('logout'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isSelected = false, required VoidCallback onTap}) {
    return Material(
      color: isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 15),
              // Included the Expanded widget fix from earlier so your text doesn't overflow
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet() {
    final settingsCtrl = Get.find<SettingsController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Get.theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('choose_language'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _langTile('ar', 'العربية', settingsCtrl),
            _langTile('fr', 'Français', settingsCtrl),
            _langTile('en', 'English', settingsCtrl),
          ],
        ),
      ),
    );
  }

  Widget _langTile(String code, String name, SettingsController ctrl) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Obx(() => ctrl.currentLanguage.value == code ? const Icon(Icons.check_circle, color: AppColors.primary) : const SizedBox.shrink()),
      onTap: () {
        ctrl.changeLanguage(code);
        Get.back();
      },
    );
  }
}