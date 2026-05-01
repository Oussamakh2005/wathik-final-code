import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class LayoutController extends GetxController {
  final drawerController = ZoomDrawerController();
  final pageController = PageController(initialPage: 0);
  final notchController = NotchBottomBarController(index: 0);
  
  // RESTORED: This keeps track of the title for the AppBar
  final currentIndex = 0.obs; 

  void toggleDrawer() {
    drawerController.toggle?.call();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    pageController.dispose();
    notchController.dispose();
    super.dispose();
  }
}