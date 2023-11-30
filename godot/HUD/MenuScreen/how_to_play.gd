extends Control

func _on_button_2_pressed():
    queue_free()


func _on_button_pressed():
    var fight_screen = preload("res://HUD/MenuScreen/fights.tscn").instantiate()
    add_child(fight_screen)
