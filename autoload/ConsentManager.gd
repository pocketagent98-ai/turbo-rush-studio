extends Node
## Turbo Rush consent manager (GDPR / ATT style gating).
## Ads and analytics must not start until a consent decision is known and positive.
## Offline-first: a missing decision simply means "no ads", never a blocked game.

signal consent_changed(status: String)

const STATUS_UNKNOWN := "unknown"
const STATUS_GRANTED := "granted"
const STATUS_DENIED := "denied"

func _privacy() -> Dictionary:
    return SaveSystem.data["privacy"]

func status() -> String:
    return str(_privacy().get("consent_status", STATUS_UNKNOWN))

func is_personalized_allowed() -> bool:
    return bool(_privacy().get("personalized_ads", false))

func analytics_allowed() -> bool:
    return bool(_privacy().get("analytics_allowed", false))

## A positive, personalised-ads-allowed decision is required before any ad loads.
func ads_allowed() -> bool:
    return status() == STATUS_GRANTED

func set_consent(granted: bool, personalized: bool, analytics: bool) -> void:
    var p := _privacy()
    p["consent_status"] = STATUS_GRANTED if granted else STATUS_DENIED
    p["personalized_ads"] = granted and personalized
    p["analytics_allowed"] = granted and analytics
    p["consent_version"] = int(p.get("consent_version", 1))
    p["consent_timestamp_unix"] = Time.get_unix_time_from_system()
    SaveSystem.save_now()
    consent_changed.emit(status())

## Called on a region that legally requires a prompt (EU/UK, or iOS ATT).
func requires_prompt(region: String, is_ios: bool) -> bool:
    var r := region.to_upper()
    if status() != STATUS_UNKNOWN:
        return false
    if r.begins_with("EU") or r in ["DE", "FR", "IT", "ES", "NL", "IE", "SE", "PL", "UK", "GB"]:
        return true
    if is_ios and str(_privacy().get("att_status", "not_required")) == "required":
        return true
    return false
