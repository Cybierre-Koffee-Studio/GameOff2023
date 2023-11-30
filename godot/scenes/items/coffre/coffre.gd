extends Item

var cliquable = false
var opened = false

func _input(event):
   # Mouse in viewport coordinates.
    if event is InputEventMouseButton and GlobalVars.can_player_move:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and cliquable and !opened :
            opened = true
            $AnimationPlayer.play("open2")
            $MeshInstance3D/Area3D.input_ray_pickable = false
            var rand_int = randi_range(1, 2)
            match rand_int :
                1 :
                    print("Puissance obtenue")
                    GlobalVars.power_up(1)
                    $AnimationPlayer2.play("power")
                2 :
                    print("Potion reçue")
                    GlobalVars.potion_up(1)
                    $AnimationPlayer2.play("potion")


func _on_area_3d_mouse_entered():
    cliquable = true

func _on_area_3d_mouse_exited():
    cliquable = false

func activate():
    $MeshInstance3D/Area3D.input_ray_pickable = true
