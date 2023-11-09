extends StaticBody3D

var cliquable = false

func _input(event):
   # Mouse in viewport coordinates.
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and cliquable :
            print("Coffre ouvert!")

func _on_area_3d_mouse_entered():
    cliquable = true

func _on_area_3d_mouse_exited():
    cliquable = false
