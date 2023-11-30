extends ClickableItem

var opened = false
                    
func execute_action():
    if !opened:
        opened = true
        $AnimationPlayer.play("open2")
        $MeshInstance3D/Area3D.input_ray_pickable = false
        var rand_int = randi_range(1, 2)
        match rand_int :
            1 :
                GlobalVars.power_up(1)
                $AnimationPlayer2.play("power")
            2 :
                GlobalVars.potion_up(1)
                $AnimationPlayer2.play("potion")

func activate():
    $MeshInstance3D/Area3D.input_ray_pickable = true

func look_at_player(posi):
    var target_pos = Vector3(posi.x, global_transform.origin.y , posi.z)
    $MeshInstance3D.look_at(target_pos, Vector3.UP, true)
