extends Item

var cliquable = false

func _input(event):
   # Mouse in viewport coordinates.
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and cliquable :
            $MeshInstance3D.mesh.material.albedo_color = Color.GREEN
            print("Monstre tué!")

func _on_area_3d_mouse_entered():
    print("Mouse in")
    cliquable = true

func _on_area_3d_mouse_exited():
    print("Mouse out")
    cliquable = false

func activate():
    $Area3D.input_ray_pickable = true
    print("ipnut_ray_pickable activé! : " + str($Area3D.input_ray_pickable))
