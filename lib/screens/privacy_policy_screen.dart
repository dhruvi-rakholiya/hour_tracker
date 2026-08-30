import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController controller;
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    try {
      if (Platform.isAndroid) {
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..enableZoom(true)
          ..loadRequest(
            Uri.parse(
              'https://nidhirola.blogspot.com/2025/01/privacy-policy.html',
            ),
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() {
                  isLoading.value = true;
                });
              },
              onPageFinished: (url) {
                setState(() {
                  isLoading.value = false;
                });
              },
            ),
          );
      } else {
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                isLoading.value = true;
              },
              onPageFinished: (url) {
                isLoading.value = false;
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              'https://nidhirola.blogspot.com/2025/01/privacy-policy.html',
            ),
          );
      }
    } catch (e) {
      log("Webview Error :- $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: CustomAppText(
          text: "Privacy Policy",
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      body: Obx(
        () => isLoading.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              )
            : WebViewWidget(controller: controller),
      ),
    );
  }
}
