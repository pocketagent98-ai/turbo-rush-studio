package com.vermajeeverma.turborush.aptoide

import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

/**
 * Turbo Rush Aptoide Connect billing bridge (SCAFFOLDING — not built or device-tested).
 *
 * Exposed to GDScript as the singleton "AptoideBillingBridge" via getPluginName().
 * The GDScript side (autoload/IAPManager.gd) calls these exact snake_case names
 * and only applies an entitlement AFTER the native layer confirms validation.
 *
 * TODO(integration): wire these calls to the actual Aptoide Connect / Billing SDK
 * you registered your products in. The method bodies below are placeholders that
 * document the required behaviour; they do NOT talk to a real store yet.
 */
class AptoideBillingBridge(godot: Godot) : GodotPlugin(godot) {

    override fun getPluginName(): String = "AptoideBillingBridge"

    @UsedByGodot
    fun purchase(productId: String) {
        // TODO: start the Aptoide purchase flow for productId.
        // On success, validate the receipt (server-side preferred), then call
        // Godot's IAPManager.apply_verified_entitlement(productId, transactionId).
    }

    @UsedByGodot
    fun restore_purchases() {
        // TODO: query owned non-consumables and re-deliver entitlements.
    }

    @UsedByGodot
    fun consume_purchase(productId: String) {
        // TODO: consume a consumable after its entitlement has been delivered.
    }

    @UsedByGodot
    fun acknowledge_purchase(productId: String) {
        // TODO: acknowledge a non-consumable (e.g. remove_ads) after validation.
    }
}
