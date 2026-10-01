extends SceneTree
## Turbo Rush integration / boot test.
## Instantiates the real main scene, starts a race, drives it to the finish and
## checks the state machine and reward flow. Run with:
##   godot --headless --path <project> --script res://tests/integration_test.gd

var game: Node = null
var frame: int = 0
var started: bool = false
var failures: Array[String] = []
var finished_seen: bool = false


func _initialize() -> void:
	var packed: PackedScene = load("res://main.tscn")
	if packed == null:
		print("Turbo Rush integration test FAILED: main.tscn did not load")
		quit(1)
		return
	game = packed.instantiate()
	root.add_child(game)


func _process(_delta: float) -> bool:
	frame += 1

	if frame == 40 and not started:
		started = true
		if game.has_method("_start_race"):
			game.call("_start_race", 1)
			if str(game.get("state")) != "COUNTDOWN":
				failures.append("race did not enter COUNTDOWN")
		else:
			failures.append("_start_race missing")

	# Skip the 3s countdown and enter RACING.
	if frame == 70:
		game.set("state", "RACING")

	# Let the race loop, AI, traffic, pickups and collisions run.
	if frame == 120:
		var def: Dictionary = game.get("level_def")
		if float(def.get("track_length_m", 0.0)) <= 0.0:
			failures.append("level_def missing track length")
		var ai: Array = game.get("ai_racers")
		if ai.size() != 5:
			failures.append("expected 5 AI racers, got %d" % ai.size())

	# Push the player past the finish line to exercise the results/reward flow.
	if frame > 130 and not finished_seen:
		var def2: Dictionary = game.get("level_def")
		game.set("player_progress", float(def2.get("track_length_m", 100.0)))
		finished_seen = true

	if frame > 190:
		var state := str(game.get("state"))
		if state != "RESULTS":
			failures.append("expected RESULTS after finish, got %s" % state)
		var rewards: Dictionary = game.get("last_rewards")
		if rewards.is_empty():
			failures.append("no rewards resolved")
		if failures.is_empty():
			print("Turbo Rush integration test passed (frames=%d, state=%s)" % [frame, state])
			quit(0)
		else:
			print("Turbo Rush integration test FAILED: ", failures)
			quit(1)
		return true

	return false
