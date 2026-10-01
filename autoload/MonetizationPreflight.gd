extends Node
## Turbo Rush monetization preflight.
## At runtime it warns (developer builds only) when release identifiers are
## missing. The authoritative gate is tools/monetization_preflight.gd, which the
## release workflow runs before exporting and which exits non-zero on failure.

func _ready() -> void:
    if OS.has_feature("editor") or OS.is_debug_build():
        var missing := ReleaseConfig.missing_release_fields()
        if not missing.is_empty():
            push_warning("[Turbo Rush] Monetization not configured. Missing: %s" % ", ".join(missing))

func report() -> Dictionary:
    var missing := ReleaseConfig.missing_release_fields()
    return {
        "release_ready": missing.is_empty(),
        "missing_fields": missing,
        "unity_android_game_id": ReleaseConfig.UNITY_ANDROID_GAME_ID,
        "aptoide_products": ReleaseConfig.APTOIDE_PRODUCT_IDS.size()
    }
