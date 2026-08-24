package com.example.hour_tracker

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.widget.LinearLayout
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast
import com.facebook.FacebookSdk
import com.facebook.LoggingBehavior
import com.facebook.appevents.AppEventsLogger
import android.os.Bundle
import android.view.WindowManager

fun parseSafeHexColor(colorString: String?, defaultColorHex: String = "#FFFFFF"): Int {
    if (colorString.isNullOrBlank()) {
        return try { Color.parseColor(defaultColorHex) } catch (e: Exception) { Color.BLACK }
    }
    val trimmed = colorString.trim()
    val formatted = if (trimmed.startsWith("#")) trimmed else "#$trimmed"
    return try {
        Color.parseColor(formatted)
    } catch (e: Exception) {
        try {
            Color.parseColor(defaultColorHex)
        } catch (ex: Exception) {
            Color.BLACK
        }
    }
}

class MainActivity: FlutterActivity(){
    private fun setText(myText: String) {
        Toast.makeText(this, myText, Toast.LENGTH_SHORT).show()
    }

    private val CHANNEL = "nativeChannel"

    private var startColor: String = "#0091FF"
    private var endColor: String = "#0091FF"
    private var backgroundColor: String = "#A7DAFB"
    private var headLineTextColor: String = "#000000"
    private var bodyTextColor: String = "#000000"
    private var buttonTextColor: String = "#FFFFFF"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        // 🚫 Disable screenshots and screen recording
//        window.setFlags(
//            WindowManager.LayoutParams.FLAG_SECURE,
//            WindowManager.LayoutParams.FLAG_SECURE
//        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result ->
                Log.i("xyz", "configureFlutterEngine: ")
                when (call.method) {
                    "setToast" -> {

                        try {
                            Log.i("xyz", "configureFlutterEngine: 1111")
                            val fb_appid = call.argument<String>("fb_appid") ?: ""
                            val fb_token = call.argument<String>("fb_token") ?: ""
                            startColor = call.argument<String>("btnBgColorG1") ?: "#0091FF"
                            Log.i("xyz", "configureFlutterEngine: 1111")
                            endColor = call.argument<String>("btnBgColorG2") ?: "#0091FF"
                            backgroundColor = call.argument<String>("nativeBGColor") ?: "#A7DAFB"
                            headLineTextColor = call.argument<String>("headerTextColor") ?: "#000000"
                            bodyTextColor = call.argument<String>("bodyTextColor") ?: "#000000"
                            buttonTextColor = call.argument<String>("btnTextColor") ?: "#FFFFFF"
                            Log.i("xyz", "configureFlutterEngine: 2")

                            if (fb_appid.isNotEmpty() && fb_token.isNotEmpty()) {
                                try {
                                    FacebookSdk.setApplicationId(fb_appid)
                                    FacebookSdk.setClientToken(fb_token)
                                    FacebookSdk.sdkInitialize(this@MainActivity)
                                    FacebookSdk.setAutoInitEnabled(true)
                                    FacebookSdk.fullyInitialize()
                                    FacebookSdk.setAutoLogAppEventsEnabled(true)
                                    FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)
                                    AppEventsLogger.newLogger(this@MainActivity).applicationId
                                } catch (fbEx: Exception) {
                                    fbEx.printStackTrace()
                                }
                            }

                            // Register ad factories here, after initializing properties
                            GoogleMobileAdsPlugin.registerNativeAdFactory(
                                flutterEngine,
                                "smallNativeAds",
                                NativeAdFactorySmall(layoutInflater, startColor, endColor, backgroundColor, headLineTextColor, bodyTextColor, buttonTextColor)
                            )
                            GoogleMobileAdsPlugin.registerNativeAdFactory(
                                flutterEngine,
                                "bigNativeAds",
                                NativeAdFactoryBig(layoutInflater, startColor, endColor, backgroundColor, headLineTextColor, bodyTextColor, buttonTextColor)
                            )
                            GoogleMobileAdsPlugin.registerNativeAdFactory(
                                flutterEngine,
                                "fullNativeAds",
                                NativeAdFactoryFull(layoutInflater, startColor, endColor, backgroundColor, headLineTextColor, bodyTextColor, buttonTextColor)
                            )
                            Log.i("xyz", "configureFlutterEngine: 3")

                        } catch (e: Exception) {
                            e.printStackTrace()
                            result.success(false)
                        }

                    }
                }
            }

        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        super.configureFlutterEngine(flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        Log.i("xyz", "configureFlutterEngine:4 ")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallNativeAds")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "bigNativeAds")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "fullNativeAds")
        Log.i("xyz", "configureFlutterEngine: 5")
    }

}

class NativeAdFactoryBig : GoogleMobileAdsPlugin.NativeAdFactory {
    private var layoutInflater: LayoutInflater
    private var startColor: String
    private var endColor: String
    private var backgroundColor: String
    private var headLineTextColor: String
    private var bodyTextColor: String
    private var buttonTextColor: String

    constructor(layoutInflater: LayoutInflater, startColor : String, endColor : String, backgroundColor: String, headLineTextColor: String, bodyTextColor: String, buttonTextColor: String) {
        this.layoutInflater = layoutInflater
        this.startColor = startColor
        this.endColor = endColor
        this.backgroundColor = backgroundColor
        this.headLineTextColor = headLineTextColor
        this.bodyTextColor = bodyTextColor
        this.buttonTextColor = buttonTextColor
    }

    override fun createNativeAd(
        nativeAd: NativeAd?,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.big_template, null) as NativeAdView
        // Background color
        val circularLayoutBackground: LinearLayout = adView.findViewById(R.id.circular_layout_background)
        val cornerRadius = 20f * adView.context.resources.displayMetrics.density
        val backgroundGradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(parseSafeHexColor(backgroundColor, "#A7DAFB"))
            this.cornerRadius = cornerRadius
        }
        circularLayoutBackground.background = backgroundGradientDrawable

        // Set the media view.
        adView.mediaView = adView.findViewById(R.id.native_ad_media)

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.setTextColor(parseSafeHexColor(headLineTextColor, "#000000"))

        adView.bodyView = adView.findViewById(R.id.ad_body)
        (adView.bodyView as? TextView)?.setTextColor(parseSafeHexColor(bodyTextColor, "#000000"))

        // Button Background
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        val buttonGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TR_BL, // 135 degrees
            intArrayOf(parseSafeHexColor(startColor, "#0091FF"), parseSafeHexColor(endColor, "#0091FF"))
        )
        buttonGradientDrawable.cornerRadius = 14f * adView.context.resources.displayMetrics.density
        adView.callToActionView?.background = buttonGradientDrawable
        //Text Color
        (adView.callToActionView as? Button)?.setTextColor(parseSafeHexColor(buttonTextColor, "#FFFFFF"))

        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // "Ad" Text background
        adView.priceView = adView.findViewById(R.id.native_ad_attribution_small)
        val priceGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TR_BL, // 135 degrees
            intArrayOf(parseSafeHexColor(startColor, "#0091FF"), parseSafeHexColor(endColor, "#0091FF"))
        ).apply {
            cornerRadii = floatArrayOf(
                10f * adView.context.resources.displayMetrics.density, 10f *  adView.context.resources.displayMetrics.density, // top-left radius
                0f, 0f, // top-right radius
                0f, 0f, // bottom-right radius
                5f *  adView.context.resources.displayMetrics.density, 5f *  adView.context.resources.displayMetrics.density  // bottom-left radius
            )
        }
        adView.priceView?.background = priceGradientDrawable
        (adView.priceView as? TextView)?.setTextColor(parseSafeHexColor(buttonTextColor, "#FFFFFF"))

        // Star Color
        adView.starRatingView = adView.findViewById(R.id.ad_stars)

        // Populate ad view
        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}

class NativeAdFactoryFull : GoogleMobileAdsPlugin.NativeAdFactory {
    private var layoutInflater: LayoutInflater
    private var startColor: String
    private var endColor: String
    private var backgroundColor: String
    private var headLineTextColor: String
    private var bodyTextColor: String
    private var buttonTextColor: String

    constructor(layoutInflater: LayoutInflater, startColor : String, endColor : String, backgroundColor: String, headLineTextColor: String, bodyTextColor: String, buttonTextColor: String) {
        this.layoutInflater = layoutInflater
        this.startColor = startColor
        this.endColor = endColor
        this.backgroundColor = backgroundColor
        this.headLineTextColor = headLineTextColor
        this.bodyTextColor = bodyTextColor
        this.buttonTextColor = buttonTextColor
    }

    override fun createNativeAd(
        nativeAd: NativeAd?,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.full_template, null) as NativeAdView

        // Background color
        val circularLayoutBackground: LinearLayout = adView.findViewById(R.id.circular_layout_background)
        val cornerRadius = 20f * adView.context.resources.displayMetrics.density
        val backgroundGradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(parseSafeHexColor(backgroundColor, "#A7DAFB"))
            this.cornerRadius = cornerRadius
        }
        circularLayoutBackground.background = backgroundGradientDrawable

        // Set the media view.
        adView.mediaView = adView.findViewById(R.id.native_ad_media)

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.setTextColor(parseSafeHexColor(headLineTextColor, "#000000"))

        adView.bodyView = adView.findViewById(R.id.ad_body)
        (adView.bodyView as? TextView)?.setTextColor(parseSafeHexColor(bodyTextColor, "#000000"))

        // Button Background
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        val buttonGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TR_BL, // 135 degrees
            intArrayOf(parseSafeHexColor(startColor, "#0091FF"), parseSafeHexColor(endColor, "#0091FF"))
        )
        buttonGradientDrawable.cornerRadius = 14f * adView.context.resources.displayMetrics.density
        adView.callToActionView?.background = buttonGradientDrawable
        //Text Color
        (adView.callToActionView as? Button)?.setTextColor(parseSafeHexColor(buttonTextColor, "#FFFFFF"))

        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // "Ad" Text background
        adView.priceView = adView.findViewById(R.id.native_ad_attribution_small)
        val priceGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TR_BL, // 135 degrees
            intArrayOf(parseSafeHexColor(startColor, "#0091FF"), parseSafeHexColor(endColor, "#0091FF"))
        ).apply {
            cornerRadii = floatArrayOf(
                10f * adView.context.resources.displayMetrics.density, 10f *  adView.context.resources.displayMetrics.density, // top-left radius
                0f, 0f, // top-right radius
                0f, 0f, // bottom-right radius
                5f *  adView.context.resources.displayMetrics.density, 5f *  adView.context.resources.displayMetrics.density  // bottom-left radius
            )
        }
        adView.priceView?.background = priceGradientDrawable
        (adView.priceView as? TextView)?.setTextColor(parseSafeHexColor(buttonTextColor, "#FFFFFF"))

        // Star Color
        adView.starRatingView = adView.findViewById(R.id.ad_stars)

        // Populate ad view
        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}

class NativeAdFactorySmall : NativeAdFactory {
    private var layoutInflater: LayoutInflater
    private var startColor: String
    private var endColor: String
    private var backgroundColor: String
    private var headLineTextColor: String
    private var bodyTextColor: String
    private var buttonTextColor: String

    constructor(layoutInflater: LayoutInflater, startColor : String, endColor : String, backgroundColor: String, headLineTextColor: String, bodyTextColor: String, buttonTextColor: String) {
        this.layoutInflater = layoutInflater
        this.startColor = startColor
        this.endColor = endColor
        this.backgroundColor = backgroundColor
        this.headLineTextColor = headLineTextColor
        this.bodyTextColor = bodyTextColor
        this.buttonTextColor = buttonTextColor
    }

    override fun createNativeAd(
        nativeAd: NativeAd?,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.small_template, null) as NativeAdView
        Log.d("Colors", "Start Color: $startColor, End Color: $endColor, Background Color: $backgroundColor")
        // Background color
        val circularLayoutBackground: LinearLayout = adView.findViewById(R.id.circular_layout_background)
        val cornerRadius = 20f * adView.context.resources.displayMetrics.density
        val backgroundGradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(parseSafeHexColor(backgroundColor, "#A7DAFB"))
            this.cornerRadius = cornerRadius
        }
        circularLayoutBackground.background = backgroundGradientDrawable
        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.setTextColor(parseSafeHexColor(headLineTextColor, "#000000"))

        adView.bodyView = adView.findViewById(R.id.ad_body)
        (adView.bodyView as? TextView)?.setTextColor(parseSafeHexColor(bodyTextColor, "#000000"))

        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        val buttonGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TR_BL, // 135 degrees
            intArrayOf(parseSafeHexColor(startColor, "#0091FF"), parseSafeHexColor(endColor, "#0091FF"))
        )
        buttonGradientDrawable.cornerRadius = 14f * adView.context.resources.displayMetrics.density
        adView.callToActionView?.background = buttonGradientDrawable
        //Text Color
        (adView.callToActionView as? Button)?.setTextColor(parseSafeHexColor(buttonTextColor, "#FFFFFF"))

        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // "Ad" Text background
        adView.priceView = adView.findViewById(R.id.native_ad_attribution_small)
        val priceGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TR_BL, // 135 degrees
            intArrayOf(parseSafeHexColor(startColor, "#0091FF"), parseSafeHexColor(endColor, "#0091FF"))
        ).apply {
            cornerRadii = floatArrayOf(
                10f * adView.context.resources.displayMetrics.density, 10f *  adView.context.resources.displayMetrics.density, // top-left radius
                0f, 0f, // top-right radius
                0f, 0f, // bottom-right radius
                5f *  adView.context.resources.displayMetrics.density, 5f *  adView.context.resources.displayMetrics.density  // bottom-left radius
            )
        }
        adView.priceView?.background = priceGradientDrawable
        (adView.priceView as? TextView)?.setTextColor(parseSafeHexColor(buttonTextColor, "#FFFFFF"))

        adView.starRatingView = adView.findViewById(R.id.ad_stars)

        // The headline and mediaContent are guaranteed to be in every NativeAd.
        (adView.headlineView as TextView).text = nativeAd?.headline

        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }
        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }
        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}

