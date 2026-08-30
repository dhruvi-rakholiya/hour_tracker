import 'dart:developer';

import 'package:flutter/foundation.dart';

showLog(String msg) {
  if (kDebugMode) {
    log("LOG >> $msg");
  }
}

//TO DO: add the Apple API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const appleApiKey = 'appl_uvLFxdhFsRFDYStldCxjuEefSoJ';

//TO DO: add the Google API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const googleApiKey = 'goog_HPKOPYmcSujDUgKtzFpydbwzqDF';

//TO DO: add the Amazon API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const amazonApiKey = '';

const entitlementKey = "testforallapplication";
