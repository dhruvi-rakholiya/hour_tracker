import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/firebase_options.dart';
import 'package:hour_tracker/for_ads/ads/ads_splash_utils.dart';
import 'package:hour_tracker/for_ads/utils/firstTime.dart';
import 'package:hour_tracker/for_ads/utils/store_config.dart';
import 'package:hour_tracker/screens/splash_screen.dart';
import 'package:hour_tracker/services/notification_service.dart';
import 'package:hour_tracker/services/shared_preference_service.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefService.init();
  await NotificationService.instance.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  premiumInit();
  await configureSDK();
  runApp(const MyApp());
}

Future<void> configureSDK() async {
  try {
    await Purchases.setLogLevel(LogLevel.debug);
    Check.init();

    PurchasesConfiguration configuration;
    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(StoreConfig.instance.apiKey);
    } else {
      configuration = PurchasesConfiguration(StoreConfig.instance.apiKey);
    }

    configuration.entitlementVerificationMode =
        EntitlementVerificationMode.informational;
    await Purchases.configure(configuration);
    await Purchases.enableAdServicesAttributionTokenCollection();

    final offerings = await Purchases.getOfferings();
    if (offerings.current != null) {
      print('✅ Offering found: ${offerings.current!.identifier}');
      for (final pkg in offerings.current!.availablePackages) {
        print('👉 Package: ${pkg.identifier}');
        print('👉 Product: ${pkg.storeProduct.identifier}');
      }
    } else {
      print('⚠️ No current offering found');
    }
  } catch (e, st) {
    print('❌ Error configuring SDK or fetching offerings: $e');
    print(st);
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: appBgColor,
          primaryColor: primaryColor,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

