extends Node2D

var is_spectator = false
var player_name = ""


func _process(_delta: float) -> void:
	if is_spectator:
		if has_node("Players/" + str(multiplayer.get_unique_id())):
			remove_player.rpc(multiplayer.get_unique_id())
			is_spectator = false

@rpc("any_peer", "call_remote", "reliable")
func remove_player(id):
	get_node("Players/" + str(id)).queue_free()

func become_host():
	hide_UI()
	MultiplayerManager.become_host()
	$UI/Timer/Timer.start()

func join_as_player():
	hide_UI()
	MultiplayerManager.join_as_player(
		$UI/Menu/Panel/VBoxContainer/LineEdit.text)

func join_as_spectator():
	hide_UI()
	MultiplayerManager.join_as_spectator(
		$UI/Menu/Panel/VBoxContainer/LineEdit.text)
	is_spectator = true

func quit_game():
	get_tree().quit()

func hide_UI():
	$UI/Menu.hide()
	unhide_timer()

func unhide_UI():
	$UI/Menu.visible = true
	$UI/Timer.visible = false
	$UI/Timer.time_left = 0

func unhide_timer():
	$UI/Timer.visible = true

func _on_timer_timeout() -> void:
	game_over.rpc()

@rpc("any_peer", "call_local", "reliable")
func set_who_it_is():
	$Players.get_children()[0].is_it = true

@rpc("any_peer", "call_local", "reliable")
func game_over():
	var current_player = get_tree().get_current_scene().get_node("Players").get_node(str(multiplayer.get_unique_id()))
	if current_player != null:
		if current_player.is_it:
			$UI/Outcome.text = "You Lost!"
			$UI/Outcome/AnimationPlayer.play("Result")
		else:
			$UI/Outcome.text = "You Won!"
			$UI/Outcome/AnimationPlayer.play("Result")
