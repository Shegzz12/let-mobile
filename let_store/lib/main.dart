// import 'package:let_store/screens/add_product.dart';
// import 'package:let_store/screens/sign_up_screen.dart';

import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import 'controllers/navigation_controller.dart';
// import 'screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// import 'screens/sign_up_screen.dart';
// import 'screens/onboarding_screen.dart';
import 'screens/signin_screen.dart';
import 'utils/app_themes.dart';

void main() async {
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LET INNOVATIONS',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ), //AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,

      defaultTransition: Transition.fade,
      // home: OnboardingScreen(),
      home: SigninScreen(),
    );
  }
}
