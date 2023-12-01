extends Control


func _on_button_play_pressed():
    get_tree().change_scene_to_packed(preload("res://scenes/main.tscn"))


func _on_button_infos_pressed():
    var htp_screen = preload("res://HUD/MenuScreen/how_to_play.tscn").instantiate()
    add_child(htp_screen)
