# Turbo Rush — Release Readiness

Honest status after the 1.3.0 studio-upgrade pass. Nothing below is claimed as
verified unless it was actually run.

## Verified in this pass (Godot 4.7.2, headless)

| Check | Result |
|---|---|
| Headless import with script-error gate | PASS (no parse/script errors) |
| `tests/smoke_test.gd` — catalog + 10,000-level determinism | PASS |
| `tests/integration_test.gd` — boot, start race, finish, rewards | PASS |
| Game boots and runs headless | PASS |
| Monetization preflight runs and reports correctly | PASS (reports NOT ready — see below) |

### Critical bugs found and fixed

1. **The game did not compile.** `main.gd` had a parse error (`elif` without a
   matching `if`, caused by a `for` loop inserted between them in `_update_ai`).
   The project's own smoke test still passed because it only exercised the
   autoloads, so the breakage was invisible. Fixed.
2. **Two type-inference parse errors** in the main-menu hero code
   (`var hero_name := screens[...]...`). Fixed with explicit types.
3. **`_show_only("race")` crashed at every race start** because there is no
   `"race"` screen — only the 3D world and the HUD. The exception aborted the
   function before the HUD/camera state was set, so the race HUD and camera
   switch could fail. Fixed by guarding the screen lookup.

## Not verified here (and why)

| Item | Why it is not verified |
|---|---|
| Real Android/iOS device run | No physical device in this environment. |
| Frame rate / thermals / touch latency | Requires a device. |
| Unity Ads shown at runtime | Native bridge + real ad-unit IDs are not present yet. |
| Aptoide purchase / restore | Native bridge + store account are not present yet. |
| Signed store build | Production keystore is not in the repo (by design). |
| 3D art-asset integration | The `Turbo_Rush_All_Assets.zip` asset library was **not** provided, so no GLB/GLTF models were imported. The game still uses its procedural meshes. |
| Native bridge Kotlin compilation | No Android SDK/Gradle/JDK here; the sources in `android/plugins/` are scaffolding. |

## What you must supply to ship

1. **Unity Ads ad-unit IDs** → `autoload/ReleaseConfig.gd`
   (`UNITY_ANDROID_BANNER_AD_UNIT_ID`, `..._REWARDED_...`, `..._INTERSTITIAL_...`).
2. **Aptoide product registration** for the 10 IDs in `ReleaseConfig.gd`.
3. **Build the native bridges** in `android/plugins/` and add the AARs to the Android export.
4. **Production keystore** stored as CI secrets (never committed).
5. **Real-device QA** on the target Android/iOS matrix.

Until 1–3 are done, `tools/monetization_preflight.gd` exits non-zero and the
release workflow will not produce a store artifact. This is intentional.

## Known limitations

- `main.gd` is still large (~2,000 lines). One cohesive subsystem
  (`VehicleFactory`) was extracted; further splitting (track builder, UI builder,
  race manager) is recommended and safe to do incrementally.
- Audio and haptics are stubs (`AudioSystem`, `HapticsSystem` hold state only).
- No iOS export preset ships yet (Android presets only).
