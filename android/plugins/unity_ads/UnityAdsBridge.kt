package com.vermajeeverma.turborush.unityads

import android.app.Activity
import android.view.Gravity
import android.widget.FrameLayout
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot
import com.unity3d.ads.IUnityAdsInitializationListener
import com.unity3d.ads.IUnityAdsLoadListener
import com.unity3d.ads.IUnityAdsShowListener
import com.unity3d.ads.UnityAds
import com.unity3d.ads.UnityAdsShowOptions
import com.unity3d.services.banners.BannerView
import com.unity3d.services.banners.UnityBannerSize

/**
 * Turbo Rush Unity Ads bridge (SCAFFOLDING — not built or device-tested).
 *
 * Exposed to GDScript as the singleton "UnityAdsBridge" via getPluginName().
 * The GDScript side (autoload/AdsManager.gd) calls these exact snake_case names.
 *
 * Callbacks: the current GDScript contract passes a Godot Callable. If your
 * Godot 4.7.2 Android build template does not expose
 * `org.godotengine.godot.variant.Callable`, switch these methods to emit
 * plugin signals instead (override getPluginSignals()) and connect from GDScript.
 */
class UnityAdsBridge(godot: Godot) : GodotPlugin(godot) {

    private val activity: Activity? = godot.activity
    private var topBanner: BannerView? = null
    private var bottomBanner: BannerView? = null

    override fun getPluginName(): String = "UnityAdsBridge"

    private fun root(): FrameLayout? =
        activity?.findViewById(android.R.id.content) as? FrameLayout

    @UsedByGodot
    fun initialize(gameId: String, testMode: Boolean) {
        if (UnityAds.isInitialized) return
        UnityAds.initialize(
            activity?.applicationContext,
            gameId,
            testMode,
            object : IUnityAdsInitializationListener {
                override fun onInitializationComplete() {}
                override fun onInitializationFailed(error: UnityAds.UnityAdsInitializationError, message: String?) {}
            }
        )
    }

    /** Two dedicated banner views (top + bottom) shown only during startup/loading. */
    @UsedByGodot
    fun show_loading_banners(topAdUnitId: String, bottomAdUnitId: String) {
        val root = root() ?: return
        activity?.runOnUiThread {
            topBanner = BannerView(activity, topAdUnitId, UnityBannerSize(320, 50)).apply {
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).also { it.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL }
                load()
            }
            bottomBanner = BannerView(activity, bottomAdUnitId, UnityBannerSize(320, 50)).apply {
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).also { it.gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL }
                load()
            }
            root.addView(topBanner)
            root.addView(bottomBanner)
        }
    }

    @UsedByGodot
    fun hide_loading_banners() {
        val root = root()
        activity?.runOnUiThread {
            topBanner?.let { root?.removeView(it); it.destroy() }
            bottomBanner?.let { root?.removeView(it); it.destroy() }
            topBanner = null
            bottomBanner = null
        }
    }

    @UsedByGodot
    fun show_rewarded(adUnitId: String, callback: org.godotengine.godot.variant.Callable) {
        UnityAds.load(adUnitId, object : IUnityAdsLoadListener {
            override fun onUnityAdsAdLoaded(placementId: String) {
                UnityAds.show(activity, placementId, UnityAdsShowOptions(), object : IUnityAdsShowListener {
                    override fun onUnityAdsShowComplete(p: String, state: UnityAds.UnityAdsShowCompletionState) {
                        callback.call(state == UnityAds.UnityAdsShowCompletionState.COMPLETED)
                    }
                    override fun onUnityAdsShowFailure(p: String, e: UnityAds.UnityAdsShowError, m: String?) { callback.call(false) }
                    override fun onUnityAdsShowStart(p: String) {}
                    override fun onUnityAdsShowClick(p: String) {}
                })
            }
            override fun onUnityAdsFailedToLoad(placementId: String, error: UnityAds.UnityAdsLoadError, message: String?) {
                callback.call(false)
            }
        })
    }

    @UsedByGodot
    fun show_interstitial(adUnitId: String, callback: org.godotengine.godot.variant.Callable) {
        UnityAds.load(adUnitId, object : IUnityAdsLoadListener {
            override fun onUnityAdsAdLoaded(placementId: String) {
                UnityAds.show(activity, placementId, UnityAdsShowOptions(), object : IUnityAdsShowListener {
                    override fun onUnityAdsShowComplete(p: String, state: UnityAds.UnityAdsShowCompletionState) { callback.call(true) }
                    override fun onUnityAdsShowFailure(p: String, e: UnityAds.UnityAdsShowError, m: String?) { callback.call(false) }
                    override fun onUnityAdsShowStart(p: String) {}
                    override fun onUnityAdsShowClick(p: String) {}
                })
            }
            override fun onUnityAdsFailedToLoad(placementId: String, error: UnityAds.UnityAdsLoadError, message: String?) { callback.call(false) }
        })
    }
}
