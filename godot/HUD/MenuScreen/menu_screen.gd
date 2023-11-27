extends Control


func _on_button_play_pressed():
    get_tree().change_scene_to_packed(preload("res://scenes/main.tscn"))
