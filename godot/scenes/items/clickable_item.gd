extends Item
class_name ClickableItem

@onready var player = get_tree().root.get_node("/root/Main/joueur")
var cliquable = false

func _input(event):
     if event is InputEventMouseButton:
        var distance_to_player = snapped(global_position.distance_to(player.global_position), 0.1)
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and cliquable && distance_to_player <= 1 :
            execute_action()

func execute_action():
    pass
    
func activate():
    pass

func _on_area_3d_mouse_entered():
    cliquable = true

func _on_area_3d_mouse_exited():
    cliquable = false


