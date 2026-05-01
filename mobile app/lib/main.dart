import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wathiq/modules/settings/controllers/settings_controller.dart';
import 'package:wathiq/modules/splash/views/splash_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
// Add this at the top of your main.dart with your other imports
import 'data/models/user_model.dart';
// Theme & Translations
import 'dart:io'; // <-- 1. Add this import at the top
import 'core/theme/app_theme.dart';
import 'translations/app_translations.dart';

// Models (Need to be registered before opening boxes)
import 'data/models/invoice_model.dart';
import 'data/models/customer_model.dart';

// Layout & Auth
import 'modules/main_layout/views/main_layout_view.dart';
import 'modules/main_layout/controllers/layout_controller.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
void main() async {
  // 1. Ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Local Storage (Hive)
  await Hive.initFlutter();
// Register the generated adaptersOpening Java Projects: check details
  Hive.registerAdapter(InvoiceModelAdapter());
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(UserModelAdapter()); // Don't forget the user!

  // 4. Open required Hive Boxes
  await Hive.openBox('session');
  await Hive.openBox('settings');
  await Hive.openBox<InvoiceModel>('invoices_box');
  await Hive.openBox<CustomerModel>('customers_box');
  
  // 5. Global Dependency Injection (Controllers that must live forever)
// 5. Global Dependency Injection (Controllers that must live forever)
  Get.put(AuthController(), permanent: true);
  Get.put(LayoutController(), permanent: true);
  Get.put(SettingsController(), permanent: true); // Add this line!
  // 6. Check Authentication State
  final sessionBox = Hive.box('session');
  final bool isLoggedIn = AuthController.isTokenValid(sessionBox);

  runApp(FintechApp(isLoggedIn: isLoggedIn));
}

class FintechApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const FintechApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read saved settings
    final settingsBox = Hive.box('settings');
    final bool isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);
    final String savedLang = settingsBox.get('language', defaultValue: 'ar');
HttpOverrides.global = MyHttpOverrides(); // <--- ADD THIS LINE HERE
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
    return GetMaterialApp(
      title: 'Invoice & Finance Manager',
      
      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Localization
      translations: AppTranslations(),
      locale: Locale(savedLang, savedLang == 'ar' ? 'DZ' : (savedLang == 'fr' ? 'FR' : 'US')), 
      fallbackLocale: const Locale('en', 'US'),

      // Proper Flutter localization delegates for RTL Arabic support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'DZ'),
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      
      home: SplashView(isLoggedIn: isLoggedIn),
     
      debugShowCheckedModeBanner: false,

    );
  }

  // A quick placeholder for the Login Screen so the app compiles immediately
  Widget _buildMockLoginScreen() {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Mock Login Action
            await Hive.box('session').put('token', 'mock_token_123');
            Get.offAll(() => const MainLayoutView());
          },
          child: const Text("Mock Login (Tap to Enter App)"),
        ),
      ),
    );
  }
}

