extends Control

signal replay(game_over_screen)

func _on_button_replay_pressed():
    emit_signal("replay", self)
