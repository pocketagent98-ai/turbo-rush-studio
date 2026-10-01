# Turbo Rush — Native Android plugins

This folder holds the **native Android bridge sources** that connect the Godot
client to the Unity Ads SDK and the Aptoide Connect billing SDK.

> STATUS: **scaffolding — not compiled or verified in this environment.**
> There is no Android SDK / Gradle / JDK in the environment where this upgrade
> was prepared, so these sources have NOT been built. They are a starting point
> that must be compiled against your Godot 4.7.2 Android build template and the
> real SDK versions, then tested on a device.
>
> The GDScript client is written so that the game runs fine **without** these
> plugins: every call is guarded by `Engine.has_singleton(...)`, so a missing
> plugin degrades to "no ads / purchases unavailable" instead of crashing.

## What the GDScript client expects

`autoload/AdsManager.gd` looks for a singleton named `UnityAdsBridge`:

| Method | Signature | Purpose |
|---|---|---|
| `initialize` | `(gameId: String, testMode: bool)` | init the Unity Ads SDK |
| `show_loading_banners` | `(topAdUnitId: String, bottomAdUnitId: String)` | two banner views during startup/loading only |
| `hide_loading_banners` | `()` | remove both banners before the lobby |
| `show_rewarded` | `(adUnitId: String, callback: Callable)` | rewarded video, callback `(ok: bool)` |
| `show_interstitial` | `(adUnitId: String, callback: Callable)` | interstitial, callback `(ok: bool)` |

`autoload/IAPManager.gd` looks for a singleton named `AptoideBillingBridge`:

| Method | Signature | Purpose |
|---|---|---|
| `purchase` | `(productId: String)` | start a purchase |
| `restore_purchases` | `()` | restore non-consumables |
| `consume_purchase` | `(productId: String)` | consume a consumable after validation |
| `acknowledge_purchase` | `(productId: String)` | acknowledge a non-consumable |

## How to build and add a plugin (Godot 4.x)

1. Install JDK 17 and the Android SDK (platform 34/36, build-tools 34.0.0/36.1.0).
2. Create a Gradle Android library module for each bridge and add the SDK
   dependency (see each `build.gradle`).
3. Implement the methods above in a class extending
   `org.godotengine.godot.plugin.GodotPlugin`, and expose them with the
   `@UsedByGodot` annotation.
4. `getPluginName()` must return `UnityAdsBridge` / `AptoideBillingBridge` — that
   name is exactly what `Engine.get_singleton(...)` resolves in GDScript.
5. Build the AAR, then in the Godot editor open
   **Project → Export → Android → Plugins** and add the AAR.
6. Fill the real IDs in `autoload/ReleaseConfig.gd` and run the preflight:
   `godot --headless --path <project> --script res://tools/monetization_preflight.gd`
   It must exit 0 before a release build is allowed.

## Signing / secrets

- The Aptoide **public** key is safe to ship (already in `ReleaseConfig.gd`).
- Never commit a private key, service account JSON, keystore, or keystore
  password. The release keystore must live in the CI secret store, not the repo.
