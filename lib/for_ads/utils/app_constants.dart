import 'dart:developer';

import 'package:flutter/foundation.dart';

void showLog(dynamic msg) {
  if (kDebugMode) {
    log("LOG >> $msg");
  }
}

//TO DO: add the Apple API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const appleApiKey = 'appl_uvLFxdhFsRFDYStldCxjuEefSoJ';

//TO DO: add the Google API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const googleApiKey = 'goog_dqIYQAYkdIufDmNvBQQJxaMmFpg';

//TO DO: add the Amazon API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const amazonApiKey = '';

const entitlementKey = "hour_metric_pro";

const weeklyPlanIdentifierAndroid = "hourmetric_premium:weekly";
const yearlyPlanIdentifierAndroid = "hourmetric_premium:yearly";
const weeklyPlanIdentifierIos = "";
const yearlyPlanIdentifierIos = "";
