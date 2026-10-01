extends SceneTree
## Turbo Rush monetization preflight (CI gate).
## Run with:
##   godot --headless --path <project> --script res://tools/monetization_preflight.gd
## Exits 0 when all required release identifiers are configured, 1 otherwise.
##
## A release build must NOT be shipped while this fails.

func _initialize() -> void:
    var release: Node = get_root().get_node_or_null("ReleaseConfig")
    if release == null:
        print("PREFLIGHT FAILED: ReleaseConfig autoload missing")
        quit(1)
        return

    var missing: Array = release.missing_release_fields()
    print("Turbo Rush monetization preflight")
    print("  Unity Android game id : %s" % release.UNITY_ANDROID_GAME_ID)
    print("  Aptoide product count  : %d" % release.APTOIDE_PRODUCT_IDS.size())

    if missing.is_empty():
        print("  RESULT: release-ready (all identifiers configured)")
        quit(0)
        return

    print("  RESULT: NOT release-ready. Missing fields:")
    for field in missing:
        print("    - %s" % field)
    quit(1)
