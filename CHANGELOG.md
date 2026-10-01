# Changelog

## 1.3.0 — studio upgrade pass

### Fixed
- **Game-breaking parse error in `main.gd`** (`_update_ai`): a `for` loop had been
  inserted between an `if` and its `elif`, so the script failed to load. The game
  never actually ran before this fix.
- Two type-inference parse errors in the main-menu hero-car code.
- `_show_only("race")` crashed on every race start (missing `"race"` screen key),
  aborting HUD/camera setup. Now guarded.
- Version numbers were inconsistent across `project.godot` (1.2.0),
  `manifest.json` (1.0.0) and the export presets. All now 1.3.0 (version code 7).

### Changed / added
- Extracted `VehicleFactory.gd` (procedural vehicle + wheel animation) out of
  `main.gd`, which dropped from ~2,260 to ~2,000 lines.
- `ReleaseConfig.gd` restructured: iOS ad-unit constants added, release-field
  validation (`missing_release_fields()`, `is_release_ready()`).
- New `ConsentManager.gd` autoload — GDPR/ATT-style consent gating for ads.
- New `MonetizationPreflight.gd` autoload + `tools/monetization_preflight.gd`
  release gate.
- `AdsManager.gd`: consent gating, interstitial support with rate limiting
  (results→menu only, once per 5 min, disabled for the first 10 min).
- `IAPManager.gd`: `_consume_or_ack()` so consumables are consumed and
  non-consumables acknowledged only after validation.
- New `tests/integration_test.gd` — boots the game and drives a full race.
- New `android/plugins/` native bridge scaffolding (Unity Ads + Aptoide billing)
  and an integration guide.
- CI rewritten for the repository-root project layout; adds the script-error
  gate, both test suites and the monetization preflight.

### Notes
- The native bridge sources are **not compiled** here (no Android SDK available).
- No 3D art assets were imported — the asset ZIP was not provided.
