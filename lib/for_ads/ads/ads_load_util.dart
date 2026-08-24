import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hour_tracker/firebase_analysis.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/for_ads/ads/app_open_ad.dart';
import 'package:hour_tracker/for_ads/ads/life_cycle.dart';
import 'package:hour_tracker/for_ads/utils/app_constants.dart';
import 'package:hour_tracker/for_ads/utils/shimmer.dart';
import 'package:hour_tracker/for_ads/widgets/loading_screen.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsLoadUtil extends GetxController {
  late SharedPreferences prefs;
  late AppLifecycleReactor appLifecycleReactor;

  /// --------- load open ads -----------------------------------------------------
  loadAppOpenSplash(Function() navigateScreen) async {
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd(AdsVariable.appOpenAdsIOS);
    appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    AppLifecycleReactor(appOpenAdManager: appOpenAdManager).listenToAppStateChanges();
  }

  loadAppOpen() async {
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd(AdsVariable.appOpenAdsIOS);
    appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    AppLifecycleReactor(appOpenAdManager: appOpenAdManager).listenToAppStateChanges();
  }

  ///---------- load and show open ad in splash
  void loadAndShowOpenAd(Function onDismissed, String adId) {
    AppOpenAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) async {
          FirebaseAnalyticsService.logEvent(eventName: 'LOAD_OPEN_AD');
          // await loadPreLoadAds();
          log("Ad Loaded:=====================================================================");
          ad.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              log('Ad showed full screen content');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('$ad onAdFailedToShowFullScreenContent=======:- $error');

              Future.delayed(const Duration(seconds: 5), () {
                //Navigator.of(context).pop();
                onDismissed();
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              Future.delayed(const Duration(seconds: 3), () {
                onDismissed();
              });
              AppOpenAdManager adManager = AppOpenAdManager();
              AppLifecycleReactor life = AppLifecycleReactor(appOpenAdManager: adManager);
              life.listenToAppStateChanges(shouldShow: true);

              ///CHANGES TO LOAD PRE LOAD AFTER SPLASH DISMISSED
              AdsLoadUtil.loadPreInterstitialAd(adId: AdsVariable.interPreLoadIOS);
              log('$ad onAdDismissedFullScreenContent========:-');
            },
          );
        },
        onAdFailedToLoad: (error) {
          Future.delayed(const Duration(seconds: 5), () {
            onDismissed();
          });
          log("Ad Not Loaded:=====================================================================");
          log(error.toString());
        },
      ),
    );
  }

  /// ------ Splash screen inter load & show --------------------------------------------
  InterstitialAd? splashInterAd;

  /// -------------------- Splash inter loading ------------------------
  loadInterSplash(Function() navigateScreen, String adUnitId) async {
    prefs = await SharedPreferences.getInstance();
    showLog('>> SHOW INTER CALL <<');
    showLog('AdsVariable.interSplashIOS >>${AdsVariable.interSplashIOS}');

    if (!AdsVariable.isPurchase) {
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) async {
            ///CHANGES IT FROM onAdShowedFullScreenContent To onAdLoaded
            FirebaseAnalyticsService.logEvent(eventName: 'LOAD_SPLASH_INERTIAL_AD');
            // await loadPreLoadAds();

            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) async {
                showLog("onAdShowedFullScreenContent loadInterSplash");
              },
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) async {
                showLog("onAdImpression loadInterSplash");
                Future.delayed(const Duration(milliseconds: 500)).then((value) {
                  navigateScreen();
                });
              },

              // Called when the ad failed to show full screen content.
              //
              onAdFailedToShowFullScreenContent: (ad, err) async {
                // Dispose the ad here to free resources.
                ad.dispose();
                // await loadPreLoadAds();
                showLog("onAdFailedToShowFullScreenContent loadInterSplash");
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) async {
                AppOpenAdManager adManager = AppOpenAdManager();
                AppLifecycleReactor life = AppLifecycleReactor(appOpenAdManager: adManager);
                life.listenToAppStateChanges(shouldShow: true);
                // Dispose the ad here to free resources.

                ///CHANGES TO LOAD PRE LOAD AFTER SPLASH DISMISSED
                //AdsLoadUtil.loadPreInterstitialAd(adId: AdsVariable.interPreLoadIOS);
                ad.dispose();
                showLog("onAdDismissedFullScreenContent loadInterSplash");
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {
                showLog("onAdClicked loadInterSplash");
              },
            );

            showLog('$ad loaded.loadInterSplash ');
            // Keep a reference to the ad so you can show it later.

            splashInterAd = ad;
            splashInterAd!.show();
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) async {
            showLog('InterstitialAd failed to load loadInterSplash: $error');
            // await loadPreLoadAds();
            navigateScreen();
          },
        ),
      );
    }
  }

  ///---------------------- If Preload is not loaded then instantly load ad and show
  static InterstitialAd? _interstitialAd;
  static String interstitialId = "";
  static bool isAdLoaded = false;

  static loadPreInterstitialAd({required String adId}) {
    interstitialId = adId;
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          FirebaseAnalyticsService.logEvent(eventName: 'SHOW_PRE_INTERSTITIAL');
          _interstitialAd = ad;
          isAdLoaded = true;
          showLog("Pre Inter Loaded");
        },
        onAdFailedToLoad: (error) {
          isAdLoaded = false;
          showLog("Pre Inter Failed $error");
        },
      ),
    );
  }

  static void showInterstitial({required Function onDismissed, bool isShowLoading = true}) {
    print('isShowLoading-->$isShowLoading');

    if (AdsVariable.isPurchase || AdsVariable.interPreLoadIOS.startsWith('v', 0)) {
      onDismissed();
      return;
    }
    if (isAdLoaded && _interstitialAd != null) {
      showLog("IT IS PRE LOADED");
      if (isShowLoading) loadingScreen.show();
      // Delay showing the ad for 1500 milliseconds
      if (isShowLoading) {
        Future.delayed(const Duration(milliseconds: 500), () {
          loadingScreen.hide();
          // Close the loading dialog

          // Show the ad
          _interstitialAd!.show();
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdImpression: (ad) {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.black));
              FirebaseAnalyticsService.logEvent(eventName: 'SHOW_INITIAL_AD');
              showLog("onAdImpression---> true");
              Future.delayed(const Duration(milliseconds: 500)).then((val) {
                onDismissed();
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
              showLog("onAdDismissedFullScreenContent---> true");
              ad.dispose();
              _interstitialAd!.dispose().then((value) => loadPreInterstitialAd(adId: interstitialId));
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              showLog("onAdFailedToShowFullScreenContent---> Error $error");
              ad.dispose();
              _interstitialAd!.dispose().then((value) => loadPreInterstitialAd(adId: interstitialId));
              onDismissed();
            },
          );
        });
      } else {
        // Show the ad
        _interstitialAd!.show();
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdImpression: (ad) {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.black));
            FirebaseAnalyticsService.logEvent(eventName: 'SHOW_INITIAL_AD');
            showLog("onAdImpression---> true");
            Future.delayed(const Duration(milliseconds: 500)).then((val) {
              onDismissed();
            });
          },
          onAdDismissedFullScreenContent: (ad) {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
            showLog("onAdDismissedFullScreenContent---> true");
            ad.dispose();
            _interstitialAd!.dispose().then((value) => loadPreInterstitialAd(adId: interstitialId));
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            showLog("onAdFailedToShowFullScreenContent---> Error $error");
            ad.dispose();
            _interstitialAd!.dispose().then((value) => loadPreInterstitialAd(adId: interstitialId));
            onDismissed();
          },
        );
      }
    } else {
      print('get here in else');
      loadAndShow(adId: AdsVariable.interPreLoadIOS, onDismissed: onDismissed);
    }
  }

  static void loadAndShow({required String adId, required Function onDismissed}) {
    showLog("IT IS LOAD AND SHOW");
    log("ads id $adId");
    isAdLoaded = false;
    loadingScreen.show();

    if (_interstitialAd != null) {
      showLog("onDismissed");
      showInterstitial(onDismissed: onDismissed);
    } else {
      interstitialId = adId;
      showLog("dispose");
      if (_interstitialAd != null) {
        _interstitialAd!.dispose();
      }
      InterstitialAd.load(
        adUnitId: adId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            FirebaseAnalyticsService.logEvent(eventName: 'LOADED_INITIAL_AD');
            _interstitialAd = ad;
            showLog(ad.toString());
            showLog(adId);

            loadingScreen.hide();
            _interstitialAd!.show();
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdImpression: (ad) {
                showLog("onAdImpression");
                Future.delayed(const Duration(seconds: 1), () {
                  onDismissed();
                });
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                log("Ad Reloaded");
                loadPreInterstitialAd(adId: AdsVariable.interPreLoadIOS);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                log("Ad Reloaded");
                loadPreInterstitialAd(adId: AdsVariable.interPreLoadIOS);
                onDismissed();
              },
            );
          },
          onAdFailedToLoad: (error) {
            showLog(error.toString());
            loadingScreen.hide();
            onDismissed();
          },
        ),
      );
    }
  }

  /// --------------------- Native ads load ------------------------------

  /// FOR OTHER ADS TAKE STATIC VARIABLES AS MUCH AS YOU WANT TO SHOW ADS
  /// EXAMPLE:
  /// static NativeAd? homeNativeAd (Declare it in AdsVariable File (Recommended))
  /// now wherever I want to preload this homeNativeAd
  /// I will pass
  /// AdsVariable.homeNativeAd = await AdsLoadUtil().loadNative(AdsVariable.dtmd_home_nativeAd, false);

  static NativeAd? nativeBigAdSurvey1;
  static NativeAd? nativeBigAdSurvey2;
  static NativeAd? fullNativeAdIntro;
  static NativeAd? smallThirdNativeAdIntro;

  static RxBool isNativeAdFailedToLoadBigSurvey1 = false.obs;
  static RxBool isNativeAdFailedToLoadBigSurvey2 = false.obs;
  static RxBool isFullNativeAdFailedToLoadIntro = false.obs;
  static RxBool isSmallThirdNativeAdFailedToLoadIntro = false.obs;

  static RxBool isBigNativeSurveyAdLoaded1 = false.obs;
  static RxBool isBigNativeSurveyAdLoaded2 = false.obs;
  static RxBool isFullNativeIntroAdLoaded = false.obs;
  static RxBool isSmallThirdNativeIntroAdLoaded = false.obs;

  Future<NativeAd> loadSurveyBigNative1(String adUnitId, bool isBigNative) async {
    showLog("isBigNative---===>$isBigNative");
    showLog("loadSurveyBigNative1 counter---------------------------------------");
    nativeBigAdSurvey1 = NativeAd(
      adUnitId: adUnitId.toString(),
      factoryId: isBigNative ? 'bigNativeAds' : 'fullNativeAds',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          FirebaseAnalyticsService.logEvent(eventName: 'LOAD LANGUAGE BIG NATIVE 1');
          nativeBigAdSurvey1 = ad as NativeAd?;
          isBigNativeSurveyAdLoaded1.value = true;
          showLog('isLoaded loadIntro1Native');
        },
        onAdFailedToLoad: (ad, error) {
          showLog('onAdFailedToLoad loadSurveyBigNative1 Native $error');
          nativeBigAdSurvey1!.dispose();
          isBigNativeSurveyAdLoaded1.value = false;
          isNativeAdFailedToLoadBigSurvey1.value = true;
        },
      ),
      request: const AdRequest(),
    );
    await nativeBigAdSurvey1!.load();
    return nativeBigAdSurvey1!;
  }

  Future<NativeAd> loadSurveyBigNative2(String adUnitId, bool isBigNative) async {
    showLog("isBigNative---===>$isBigNative");
    showLog("loadSurveyBigNative2 counter---------------------------------------");
    nativeBigAdSurvey2 = NativeAd(
      adUnitId: adUnitId.toString(),
      factoryId: isBigNative ? 'bigNativeAds' : 'fullNativeAds',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          FirebaseAnalyticsService.logEvent(eventName: 'LOAD LANGUAGE BIG NATIVE 2');

          nativeBigAdSurvey2 = ad as NativeAd?;
          isBigNativeSurveyAdLoaded2.value = true;
          showLog('isLoaded loadIntro1Native');
        },
        onAdFailedToLoad: (ad, error) {
          showLog('onAdFailedToLoad Language Native');
          nativeBigAdSurvey2!.dispose();
          isBigNativeSurveyAdLoaded2.value = false;
          isNativeAdFailedToLoadBigSurvey2.value = true;
        },
      ),
      request: const AdRequest(),
    );
    await nativeBigAdSurvey2!.load();
    return nativeBigAdSurvey2!;
  }

  Future<NativeAd> loadIntroFullNative(String adUnitId, bool isSmallNative) async {
    showLog("isSmallNative---===>$isSmallNative");
    showLog("loadIntroFullNative counter---------------------------------------");
    fullNativeAdIntro = NativeAd(
      adUnitId: adUnitId.toString(),
      factoryId: isSmallNative ? 'bigNativeAds' : 'fullNativeAds',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          FirebaseAnalyticsService.logEvent(eventName: 'FULL_NATIVE_AD_LOAD');
          fullNativeAdIntro = ad as NativeAd?;
          isFullNativeIntroAdLoaded.value = true;
          showLog('isLoaded loadFullNative');
        },
        onAdFailedToLoad: (ad, error) {
          showLog('onAdFailedToLoad loadFullNative');
          fullNativeAdIntro!.dispose();
          isFullNativeIntroAdLoaded.value = false;
          isFullNativeAdFailedToLoadIntro.value = true;
        },
      ),
      request: const AdRequest(),
    );
    await fullNativeAdIntro!.load();
    return fullNativeAdIntro!;
  }

  Future<NativeAd> loadSmallThirdIntroNative(String adUnitId, bool isSmallNative) async {
    showLog("isSmallNative---===>$isSmallNative");
    showLog("loadIntroFullNative counter---------------------------------------");
    smallThirdNativeAdIntro = NativeAd(
      adUnitId: adUnitId.toString(),
      factoryId: isSmallNative ? 'bigNativeAds' : 'fullNativeAds',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          FirebaseAnalyticsService.logEvent(eventName: 'FULL_NATIVE_AD_LOAD');
          smallThirdNativeAdIntro = ad as NativeAd?;
          isSmallThirdNativeIntroAdLoaded.value = true;
          showLog('isLoaded loadFullNative');
        },
        onAdFailedToLoad: (ad, error) {
          showLog('onAdFailedToLoad loadFullNative');
          smallThirdNativeAdIntro!.dispose();
          isSmallThirdNativeIntroAdLoaded.value = false;
          isSmallThirdNativeAdFailedToLoadIntro.value = true;
        },
      ),
      request: const AdRequest(),
    );
    await smallThirdNativeAdIntro!.load();
    return smallThirdNativeAdIntro!;
  }
}

/// Big Native Survey1
class SurveyBigNativeAds1 extends StatefulWidget {
  final bool isBigNative;
  final NativeAd? showNativeAd;
  final RxBool isNativeAdLoaded;
  final RxBool isNativeAdFailedToLoad;

  const SurveyBigNativeAds1({
    super.key,
    required this.isBigNative,
    required this.showNativeAd,
    required this.isNativeAdLoaded,
    required this.isNativeAdFailedToLoad,
  });

  @override
  State<SurveyBigNativeAds1> createState() => _SurveyBigNativeAds1State();
}

class _SurveyBigNativeAds1State extends State<SurveyBigNativeAds1> {
  @override
  Widget build(BuildContext context) {
    showLog("CHECK NULL SurveyBigNativeAds1>> ${widget.isNativeAdLoaded.value}");
    showLog("SurveyBigNativeAds1--->> ${widget.isNativeAdFailedToLoad.value}");
    return Obx(
      () => widget.isNativeAdLoaded.value && widget.showNativeAd != null
          ? StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.w), color: HexColor(AdsVariable.nativeBGColor)),
                  padding: EdgeInsets.only(bottom: 10.w, top: 15.w, right: 10.w, left: 10.w),
                  width: Get.width,
                  height: widget.isBigNative ? Get.height / 2.7 : Get.height / 1.04,
                  child: AdWidget(ad: widget.showNativeAd!),
                );
              },
            )
          : getShimmerWidget(),
    );
  }

  Widget getShimmerWidget() {
    if (widget.isNativeAdFailedToLoad.value) {
      return const SizedBox();
    } else {
      return widget.isBigNative ? const ShimmerBigNative() : const ShimmerSmallNative();
    }
  }
}

/// Big Native Survey2
class SurveyBigNativeAds2 extends StatefulWidget {
  final bool isBigNative;
  final NativeAd? showNativeAd;
  final RxBool isNativeAdLoaded;
  final RxBool isNativeAdFailedToLoad;

  const SurveyBigNativeAds2({
    super.key,
    required this.isBigNative,
    required this.showNativeAd,
    required this.isNativeAdLoaded,
    required this.isNativeAdFailedToLoad,
  });

  @override
  State<SurveyBigNativeAds2> createState() => _SurveyBigNativeAds2State();
}

class _SurveyBigNativeAds2State extends State<SurveyBigNativeAds2> {
  @override
  Widget build(BuildContext context) {
    showLog("CHECK NULL SurveyBigNativeAds2>> ${widget.isNativeAdLoaded.value}");
    showLog("SurveyBigNativeAds2--->> ${widget.isNativeAdFailedToLoad.value}");
    return Obx(
      () => widget.isNativeAdLoaded.value && widget.showNativeAd != null
          ? StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.w), color: HexColor(AdsVariable.nativeBGColor)),
                  padding: EdgeInsets.only(bottom: 10.w, top: 15.w, right: 10.w, left: 10.w),
                  width: Get.width,
                  height: widget.isBigNative ? Get.height / 2.7 : Get.height / 1.04,
                  child: AdWidget(ad: widget.showNativeAd!),
                );
              },
            )
          : getShimmerWidget(),
    );
  }

  Widget getShimmerWidget() {
    if (widget.isNativeAdFailedToLoad.value) {
      return const SizedBox();
    } else {
      return widget.isBigNative ? const ShimmerBigNative() : const ShimmerSmallNative();
    }
  }
}

/// Small Native Third Intro
class SmallThirdIntroNativeWidget extends StatefulWidget {
  final bool isBigNative;
  final NativeAd? showNativeAd;
  final RxBool isNativeAdLoaded;
  final RxBool isNativeAdFailedToLoad;

  const SmallThirdIntroNativeWidget({
    super.key,
    required this.isBigNative,
    required this.showNativeAd,
    required this.isNativeAdLoaded,
    required this.isNativeAdFailedToLoad,
  });

  @override
  State<SmallThirdIntroNativeWidget> createState() => _SmallThirdIntroNativeWidgetState();
}

class _SmallThirdIntroNativeWidgetState extends State<SmallThirdIntroNativeWidget> {
  @override
  Widget build(BuildContext context) {
    showLog("CHECK NULL SmallThirdIntroNative>> ${widget.isNativeAdLoaded.value}");
    showLog("SmallThirdIntroNative--->> ${widget.isNativeAdFailedToLoad.value}");
    return Obx(
      () => widget.isNativeAdLoaded.value && widget.showNativeAd != null
          ? StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.w), color: HexColor(AdsVariable.nativeBGColor)),
                  padding: EdgeInsets.only(bottom: 10.w, top: 0.w),
                  width: Get.width,
                  height: widget.isBigNative ? Get.height / 2.7 : Get.height / 4.2,
                  child: AdWidget(ad: widget.showNativeAd!),
                );
              },
            )
          : getShimmerWidget(),
    );
  }

  Widget getShimmerWidget() {
    if (widget.isNativeAdFailedToLoad.value) {
      return SizedBox(height: 50.h);
    } else {
      return widget.isBigNative ? const ShimmerBigNative() : const ShimmerSmallNative();
    }
  }
}

/// Full Native ads
class FullNativeAdScreen extends StatefulWidget {
  const FullNativeAdScreen({super.key});

  @override
  State<FullNativeAdScreen> createState() => _FullNativeAdScreenState();
}

class _FullNativeAdScreenState extends State<FullNativeAdScreen> {
  @override
  Widget build(BuildContext context) {
    log("intro full Ad is ${AdsVariable.fullNativeIntroAdIOS}");
    return Scaffold(backgroundColor: Colors.transparent, body: getFinalNativeAd());
  }

  Widget getFinalNativeAd() {
    if (AdsLoadUtil.isFullNativeAdFailedToLoadIntro.value) {
      return const SizedBox(height: 0);
    } else {
      return (AdsVariable.isPurchase == false && AdsVariable.fullNativeIntroAdIOS != "11")
          ? AdsLoadUtil.fullNativeAdIntro != null
                ? SizedBox(
                    height: Get.height,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
                      child: AdWidget(ad: AdsLoadUtil.fullNativeAdIntro!),
                    ),
                  )
                : const SizedBox(height: 0)
          : const SizedBox(height: 0);
    }
  }
}
