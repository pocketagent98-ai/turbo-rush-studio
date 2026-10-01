# Turbo Rush

A mobile 3D arcade racing game built with **Godot 4.7.2** for **Android + iOS**.
Finite, level-based races (not an endless runner): 1 player against 5 AI on
deterministic procedural tracks, with coins, diamonds, boosters, damage/revive,
car and wheel collection, upgrades and an offline-first save.

- **Project ID:** GME-2026-0003
- **Version:** 1.3.0
- **Engine:** Godot 4.7.2 (mobile renderer, landscape)
- **Package:** `com.vermajeeverma.turborush`

## Run it

1. Install **Godot 4.7.2** (stable).
2. Open this folder in Godot (`project.godot` is at the repository root) and press **F5**.

## Project layout

```
project.godot            Godot project + autoload registration
main.gd                  main scene script (menus, race loop, HUD orchestration)
main.tscn                main scene
VehicleFactory.gd        procedural vehicle builder (extracted from main.gd)
autoload/                global services (see below)
tests/                   smoke_test.gd + integration_test.gd (headless)
tools/                   monetization_preflight.gd (release gate)
android/plugins/         native Unity Ads + Aptoide billing bridge sources
docs/                    design, monetization and release documentation
assets/                  logo / icons
export_presets.cfg       Android export presets (debug + release APK/AAB)
```

### Autoload services

`GameConfig`, `ContentCatalog`, `EventBus`, `SaveSystem`, `EconomyService`,
`ProgressionService`, `RewardService`, `DifficultyService`, `LevelGenerator`,
`RaceSession`, `AdsManager`, `IAPManager`, `ReleaseConfig`, `ConsentManager`,
`MonetizationPreflight`, `AudioSystem`, `HapticsSystem`, `ObjectPoolManager`.

## Tests (headless)

```bash
GODOT=godot   # path to the Godot 4.7.2 binary

# catalog + 10,000-level determinism
$GODOT --headless --path . --script res://tests/smoke_test.gd

# boot the game, start a race, drive it to the finish
$GODOT --headless --path . --script res://tests/integration_test.gd

# release gate: fails while ad/product identifiers are unconfigured
$GODOT --headless --path . --script res://tools/monetization_preflight.gd
```

## Build

GitHub Actions workflows live in `.github/workflows/`:

- `turbo-rush-ci.yml` — headless import (script-error gate), smoke + integration tests.
- `turbo-rush-android.yml` — JDK 17 + Android SDK, release APK/AAB export, signing, validation.

The Android workflow runs the monetization preflight as a **hard gate**: a release
build will not be produced until the ad-unit and store identifiers are filled in.

## Monetization setup (required before release)

1. Put the real Unity Ads ad-unit IDs in `autoload/ReleaseConfig.gd`.
2. Build the native bridges in `android/plugins/` and add the AARs in the Android export settings.
3. Register the 10 product IDs in Aptoide Connect.
4. Re-run the preflight until it exits 0.

See `docs/` and `RELEASE_READINESS.md` for details.

## Licence / third-party

See `THIRD_PARTY_NOTICES.md`.
