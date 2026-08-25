import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:hour_tracker/for_ads/ads/ads_load_util.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/for_ads/ads/app_open_ad.dart';
import 'package:hour_tracker/for_ads/ads/life_cycle.dart';
import 'package:hour_tracker/for_ads/utils/app_constants.dart';
import 'package:hour_tracker/for_ads/utils/firstTime.dart';
import 'package:hour_tracker/for_ads/utils/store_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsSplashUtils {
  late SharedPreferences prefs;

  Future<void> getOnlineIds({required Function() navigateScreen}) async {
    print("In Get Ads");
    prefs = await SharedPreferences.getInstance();

    /// IOS
    AdsVariable.appOpenAdsIOS = prefs.getString("appOpenAd") ?? "11";
    AdsVariable.interSplashIOS = prefs.getString("splashInterstitialAd") ?? "11";
    // AdsVariable.bigNativeSurveyAdIOS1 = prefs.getString("surveyBigNative1") ?? "11";
    // AdsVariable.bigNativeSurveyAdIOS2 = prefs.getString("surveyBigNative2") ?? "11";
    // AdsVariable.fullNativeIntroAdIOS = prefs.getString("introFullNative") ?? "11";
    // // AdsVariable.smallThirdIntroNativeIntroAdIOS =
    // //     prefs.getString("smallThirdIntroNative") ?? "11";
    AdsVariable.interPreLoadIOS = prefs.getString("preInterstitialAd") ?? "11";
    AdsVariable.bannerHomeIOS = prefs.getString("bannerHome") ?? "11";
    AdsVariable.bannerLogsIOS = prefs.getString("bannerLogs") ?? "11";
    AdsVariable.bannerReportsIOS = prefs.getString("bannerReports") ?? "11";
    AdsVariable.bannerProjectsIOS = prefs.getString("bannerProjects") ?? "11";

    // AdsVariable.nativeBGColor = prefs.getString("nativeBGColor") ?? "#A7DAFB";
    // AdsVariable.headerTextColor = prefs.getString("headlineTxtColor") ?? "#000000";
    // AdsVariable.bodyTextColor = prefs.getString("bodyTxtColor") ?? "#000000";
    // AdsVariable.btnTextColor = prefs.getString("buttonTxtColor") ?? "#FFFFFF";
    // AdsVariable.btnBgColorG1 = prefs.getString("buttonBgColorG1") ?? "#0091FF";
    // AdsVariable.btnBgColorG2 = prefs.getString("buttonBgColorG2") ?? "#0091FF";

    AdsVariable.openAdInSplash = prefs.getBool("showOpenAdInSplash") ?? false;
    AdsVariable.click = prefs.getString("click") ?? "2";

    log("await AdsVariable.isInternetConnected() :- ${await AdsVariable.isInternetConnected()}");

    if (await AdsVariable.isInternetConnected()) {
      try {
        final remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.setConfigSettings(
          RemoteConfigSettings(fetchTimeout: const Duration(minutes: 1), minimumFetchInterval: const Duration(minutes: 5)),
        );

        await remoteConfig.fetchAndActivate();

        Map<String, dynamic> mapValues1 = {};

        if (Platform.isAndroid) {
          log("Map is ${remoteConfig.getValue("hour_tracker").asString()}");
          mapValues1 = jsonDecode(remoteConfig.getValue("hour_tracker").asString());
          print(mapValues1);
        } else {
          log("Map is ${remoteConfig.getValue("hour_tracker").asString()}");
          mapValues1 = jsonDecode(remoteConfig.getValue("hour_tracker").asString());
          print(mapValues1);
        }

        /// IOS Id setup from Firebase Remote Config
        /// Facebook id setup

        AdsVariable.facebookId = mapValues1["fb_appid"].toString();
        AdsVariable.facebookToken = mapValues1["fb_token"].toString();
        AdsVariable.appOpenAdsIOS = mapValues1["appOpenAd"].toString();
        AdsVariable.interSplashIOS = mapValues1["splashInterstitialAd"].toString();

        // AdsVariable.bigNativeSurveyAdIOS1 = mapValues1["surveyBigNative1"].toString();
        // AdsVariable.bigNativeSurveyAdIOS2 = mapValues1["surveyBigNative2"].toString();
        // AdsVariable.fullNativeIntroAdIOS = mapValues1["introFullNative"].toString();
        AdsVariable.interPreLoadIOS = mapValues1["preInterstitialAd"].toString();

        AdsVariable.bannerHomeIOS = mapValues1["bannerHome"]?.toString() ??
            mapValues1["bannerAdHome"]?.toString() ??
            mapValues1["bannerDashboard"]?.toString() ??
            "11";
        AdsVariable.bannerLogsIOS = mapValues1["bannerLogs"]?.toString() ??
            mapValues1["bannerAdLogs"]?.toString() ??
            "11";
        AdsVariable.bannerReportsIOS = mapValues1["bannerReports"]?.toString() ??
            mapValues1["bannerAdReports"]?.toString() ??
            "11";
        AdsVariable.bannerProjectsIOS = mapValues1["bannerProjects"]?.toString() ??
            mapValues1["bannerAdProjects"]?.toString() ??
            "11";

        // AdsVariable.nativeBGColor = mapValues1['nativeBGColor'] ?? 'A7DAFB';
        // AdsVariable.headerTextColor = mapValues1["headlineTxtColor"].toString();
        // AdsVariable.bodyTextColor = mapValues1["bodyTxtColor"].toString();
        // AdsVariable.btnBgColorG1 = mapValues1["buttonBgColorG1"].toString();
        // AdsVariable.btnBgColorG2 = mapValues1["buttonBgColorG2"].toString();
        // AdsVariable.btnTextColor = mapValues1["buttonTxtColor"].toString();
        AdsVariable.click = mapValues1["click"];
        AdsVariable.openAdInSplash = mapValues1["showOpenAdInSplash"];

        /// Store firebase remote config data into shared preferences :

        // prefs.setString("nativeBGColor", mapValues1["nativeBGColor"].toString());
        // prefs.setString("buttonBgColorG1", mapValues1["buttonBgColorG1"].toString());
        // prefs.setString("buttonBgColorG2", mapValues1["buttonBgColorG2"].toString());
        // prefs.setString("buttonTxtColor", mapValues1["buttonTxtColor"].toString());
        // prefs.setString("headlineTxtColor", mapValues1["headlineTxtColor"].toString());
        // prefs.setString("bodyTxtColor", mapValues1["bodyTxtColor"].toString());

        prefs.setString("fb_appid", mapValues1["fb_appid"].toString());
        prefs.setString("fb_token", mapValues1["fb_token"].toString());

        prefs.setString("appOpenAd", mapValues1["appOpenAd"] ?? "11");
        prefs.setString("splashInterstitialAd", mapValues1["splashInterstitialAd"] ?? "11");
        prefs.setString("preInterstitialAd", mapValues1["preInterstitialAd"] ?? "11");
        // prefs.setString("surveyBigNative1", mapValues1["surveyBigNative1"] ?? "11");
        // prefs.setString("surveyBigNative2", mapValues1["surveyBigNative2"] ?? "11");
        // prefs.setString("introFullNative", mapValues1["introFullNative"] ?? "11");
        prefs.setString("bannerHome", AdsVariable.bannerHomeIOS);
        prefs.setString("bannerLogs", AdsVariable.bannerLogsIOS);
        prefs.setString("bannerReports", AdsVariable.bannerReportsIOS);
        prefs.setString("bannerProjects", AdsVariable.bannerProjectsIOS);
        // prefs.setString(
        //   "fs_smallThirdIntroNative",
        //   mapValues1["fs_smallThirdIntroNative"] ?? "11",
        // );
        prefs.setBool("showOpenAdInSplash", mapValues1["showOpenAdInSplash"] ?? false);
        prefs.setString("click", mapValues1["click"] ?? "2");

        /// Check available purchases

        if (Platform.isIOS) {
          await initializeGDPR();
          await fetchPurchase();
        } else {
          await initializeMobileAds();
          await fetchPurchase();
        }

        // AdsLoadUtil.loadPreInterstitialAd(adId: AdsVariable.interPreLoadIOS);

        /// Facebook id setup
        setupFbAdsId();

        if (AdsVariable.isPurchase) {
          Future.delayed(const Duration(seconds: 3), () {
            print('**call navigateScreen***');
            navigateScreen();
          });
        }

        ///LOAD AND SHOW OPEN OR SPLASH AD BASED ON CONDITION

        await Check.init();

        // Native ads preloading disabled as big/full native ads are no longer used in the app
        // loadPreLoadIntroFullNativeAds();
        // loadPreLoadSurveyNativeAds1();
        // loadPreLoadSurveyNativeAds2();

        Future.delayed(const Duration(seconds: 0), () async {
          if (AdsVariable.openAdInSplash!) {
            print('call open ad in splash condition');
            AdsLoadUtil().loadAndShowOpenAd(navigateScreen, AdsVariable.appOpenAdsIOS);
          } else {
            print('----call else part-----');
            AdsLoadUtil().loadInterSplash(navigateScreen, AdsVariable.interSplashIOS);
          }
        });
      } on PlatformException catch (exception) {
        showLog("Exception is $exception");
        navigateScreen();
      } catch (exception) {
        showLog("Exception is $exception");
        navigateScreen();
      }
    } else {
      print("Not Connected");
      navigateScreen();
    }
  }

  late AppLifecycleReactor appLifecycleReactor;

  Future<void> loadAppOpenAd() async {
    showLog("Load from BG...");
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd(AdsVariable.appOpenAdsIOS);
    await appOpenAdManager.loadAd(AdsVariable.appOpenAdsIOS);
    appOpenAdManager.showAdIfAvailable(AdsVariable.appOpenAdsIOS);
    appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    AppLifecycleReactor(appOpenAdManager: appOpenAdManager).listenToAppStateChanges();
  }

  Future<void> fetchPurchase() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementKey] != null &&
          customerInfo.entitlements.all[entitlementKey]!.isActive == true) {
        AdsVariable.isPurchase = true;
        AdsVariable.resetAdIds();
      } else {
        AdsVariable.isPurchase = false;
      }
      if (AdsVariable.isPurchase) {
        showLog("Purchase ----->${AdsVariable.isPurchase}");
        AdsVariable.resetAdIds;
      }
    } catch (e) {
      showLog("PURCHASE_ERROR >> ${e.toString()}");
    }
  }
}

void premiumInit() {
  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(store: Store.appStore, apiKey: appleApiKey);
  } else if (Platform.isAndroid) {
    const useAmazon = bool.fromEnvironment("amazon");
    StoreConfig(store: useAmazon ? Store.amazon : Store.playStore, apiKey: useAmazon ? amazonApiKey : googleApiKey);
  }
}

Future<void> setupFbAdsId() async {
  showLog("Call 1");
  const platformMethodChannel = MethodChannel('nativeChannel');
  showLog("Call 2");
  if (Platform.isIOS) {
    platformMethodChannel.invokeMethod('setToast', {
      'isPurchase': AdsVariable.isPurchase.toString(),
      'fb_appid': AdsVariable.facebookId,
      'fb_token': AdsVariable.facebookToken,
      'nativeBGColor': AdsVariable.nativeBGColor,
      'btnBgColor': AdsVariable.btnBgColorG1,
      'btnTextColor': AdsVariable.btnTextColor,
      'headerTextColor': AdsVariable.headerTextColor,
      'bodyTextColor': AdsVariable.bodyTextColor,
    });
  } else {
    platformMethodChannel.invokeMethod('setToast', {
      'isPurchase': AdsVariable.isPurchase.toString(),
      'fb_appid': AdsVariable.facebookId,
      'fb_token': AdsVariable.facebookToken,
      'nativeBGColor': AdsVariable.nativeBGColor,
      'btnBgColorG1': AdsVariable.btnBgColorG1,
      'btnBgColorG2': AdsVariable.btnBgColorG2,
      'btnTextColor': AdsVariable.btnTextColor,
      'headerTextColor': AdsVariable.headerTextColor,
      'bodyTextColor': AdsVariable.bodyTextColor,
    });
  }

  showLog("Call 3");
}

Future<void> loadPreLoadSurveyNativeAds1() async {
  showLog("Call Method loadPreLoadLanguageNativeAds1");
  AdsVariable.nativeBigAdSurvey1 = await AdsLoadUtil().loadSurveyBigNative1(AdsVariable.bigNativeSurveyAdIOS1, true);
  showLog("AdsVariable.bigNativeSurveyAdIOS1 --->${AdsVariable.bigNativeSurveyAdIOS1}");
  showLog("AdsVariable.nativeBigAdSurvey1 ----===>${AdsVariable.nativeBigAdSurvey1?.adUnitId ?? ''}");
}

Future<void> loadPreLoadSurveyNativeAds2() async {
  showLog("Call Method loadPreLoadLanguageNativeAds2");
  AdsVariable.nativeBigAdSurvey2 = await AdsLoadUtil().loadSurveyBigNative2(AdsVariable.bigNativeSurveyAdIOS2, true);
  showLog("AdsVariable.bigNativeSurveyAdIOS2 --->${AdsVariable.bigNativeSurveyAdIOS2}");
  showLog("AdsVariable.nativeBigAdSurvey2 ----===>${AdsVariable.nativeBigAdSurvey2?.adUnitId ?? ''}");
}

void loadPreLoadIntroFullNativeAds() async {
  showLog("Call Method loadPreLoadIntroFullNativeAds ");
  AdsVariable.fullNativeAdIntro = await AdsLoadUtil().loadIntroFullNative(AdsVariable.fullNativeIntroAdIOS, false);
  showLog("AdsVariable.fullNativeIntroAdIOS --->${AdsVariable.fullNativeIntroAdIOS}");
  showLog("AdsVariable.fullNativeAdIntro ----===>${AdsVariable.fullNativeAdIntro?.adUnitId ?? ''}");
}

// void loadSmallThirdIntroNativeAds() async {
//   showLog("Call Method loadPreLoadIntroFullNativeAds ");
//   AdsVariable.smallThirdNativeAdIntro = await AdsLoadUtil()
//       .loadSmallThirdIntroNative(
//         AdsVariable.smallThirdIntroNativeIntroAdIOS,
//         true,
//       );
//   showLog(
//     "AdsVariable.fullNativeIntroAdIOS --->${AdsVariable.smallThirdIntroNativeIntroAdIOS}",
//   );
//   showLog(
//     "AdsVariable.fullNativeAdIntro ----===>${AdsVariable.smallThirdNativeAdIntro?.adUnitId ?? ''}",
//   );
// }

/// GDPR Implementation methods : initializeGDPR, changePrivacyPreferences, loadConsentForm, initializeMobileAds
Future<FormError?> initializeGDPR() async {
  final completer = Completer<FormError?>();
  final params = ConsentRequestParameters(); //
  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      if (await isPrivacyOptionsStatus()) {
        await loadConsentForm();
      } else {
        await initializeWithOutGDPR();
      }
      completer.complete();
    },
    (error) {
      log("ERROR ==> ${error.message}");
      completer.complete(error);
    },
  );

  return completer.future;
}

Future<TrackingStatus> initializeWithOutGDPR() async {
  final completer = Completer<TrackingStatus>();
  AppTrackingTransparency.requestTrackingAuthorization().then((value) async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.authorized) {
      print("GDPR: TrackingStatus.required");
      await initializeMobileAds();
      completer.complete(TrackingStatus.authorized);
    } else {
      print("GDPR: TrackingStatus Not Required");
      await initializeMobileAds();
      completer.complete(TrackingStatus.denied);
    }
  });
  return completer.future;
}

Future<bool> changePrivacyPreferences() async {
  final completer = Completer<bool>();

  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
    () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        ConsentForm.loadConsentForm(
          (consentForm) {
            consentForm.show((formError) async {
              await initializeMobileAds();
              completer.complete(true);
            });
          },
          (formError) {
            completer.complete(false);
          },
        );
      } else {
        completer.complete(false);
      }
    },
    (error) {
      completer.complete(false);
    },
  );

  return completer.future;
}

void showPrivacyOptionsForm(OnConsentFormDismissedListener onConsentFormDismissedListener) {
  ConsentForm.showPrivacyOptionsForm(onConsentFormDismissedListener);
}

Future<FormError?> loadConsentForm() async {
  final completer = Completer<FormError?>();

  ConsentForm.loadConsentForm(
    (consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((formError) {
          completer.complete(loadConsentForm());
        });
      } else {
        await initializeMobileAds();
        completer.complete();
      }
    },
    (FormError? error) {
      completer.complete(error);
    },
  );

  return completer.future;
}

Future<void> initializeMobileAds() async {
  if (await isPrivacyOptionsStatus()) {
    AdsVariable.isPrivacyOptionsRequired = true;
  } else {
    AdsVariable.isPrivacyOptionsRequired = false;
  }
  await MobileAds.instance.initialize();
}

Future<bool> isPrivacyOptionsStatus() async {
  return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() == PrivacyOptionsRequirementStatus.required;
}

Future<void> checkAndShowInAppReview(String key) async {
  log('enter in app review function');
  final prefs = await SharedPreferences.getInstance();
  final hasShown = prefs.getBool(key) ?? false;
  final inAppReview = InAppReview.instance;
  if (!hasShown && await inAppReview.isAvailable()) {
    await inAppReview.requestReview();
    await prefs.setBool(key, true); // Mark as shown
    log('show review box');
  }
}
