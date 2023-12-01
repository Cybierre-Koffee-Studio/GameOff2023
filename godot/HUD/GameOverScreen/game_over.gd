extends Control

signal replay(game_over_screen)

func _ready():
    if GlobalVars.at_exit:
        $CanvasLayer/LabelGameOver.text = "You win !"

func _on_button_replay_pressed():
    emit_signal("replay", self)
