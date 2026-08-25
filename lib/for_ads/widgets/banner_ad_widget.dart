import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/for_ads/utils/shimmer.dart';

class TabBannerAdWidget extends StatelessWidget {
  final int currentIndex;

  const TabBannerAdWidget({
    super.key,
    required this.currentIndex,
  });

  String? _getAdUnitIdForIndex(int index) {
    switch (index) {
      case 0:
        return AdsVariable.bannerHomeIOS;
      case 2:
        return AdsVariable.bannerLogsIOS;
      case 3:
        return AdsVariable.bannerReportsIOS;
      case 4:
        return AdsVariable.bannerProjectsIOS;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exclude Timer tab (index 1) and purchased state
    if (AdsVariable.isPurchase || currentIndex == 1) {
      return const SizedBox.shrink();
    }

    final adUnitId = _getAdUnitIdForIndex(currentIndex);
    if (adUnitId == null || adUnitId == "11" || adUnitId.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleTabBannerAdWidget(
      key: ValueKey('tab_banner_${currentIndex}_$adUnitId'),
      tabIndex: currentIndex,
      adUnitId: adUnitId,
    );
  }
}

class SingleTabBannerAdWidget extends StatefulWidget {
  final int tabIndex;
  final String adUnitId;

  const SingleTabBannerAdWidget({
    super.key,
    required this.tabIndex,
    required this.adUnitId,
  });

  @override
  State<SingleTabBannerAdWidget> createState() => _SingleTabBannerAdWidgetState();
}

class _SingleTabBannerAdWidgetState extends State<SingleTabBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (AdsVariable.isPurchase || widget.adUnitId == "11" || widget.adUnitId.isEmpty) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('BannerAd loaded successfully for tab ${widget.tabIndex} (${widget.adUnitId})');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          log('BannerAd failed to load for tab ${widget.tabIndex} (${widget.adUnitId}): $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
              _isAdFailed = true;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdsVariable.isPurchase || _isAdFailed) {
      return const SizedBox.shrink();
    }

    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: EdgeInsets.only(bottom: 6.h),
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(
          key: ValueKey('ad_widget_${widget.tabIndex}_${_bannerAd.hashCode}'),
          ad: _bannerAd!,
        ),
      );
    }

    // Display Shimmer placeholder while loading
    return const ShimmerBannerAd();
  }
}
