extends Node
class_name Tile

signal select_tile

@onready var sfo:StandardMaterial3D
var COLOR_BASE = Color("0062c0")
var COLOR_BLUR = Color(COLOR_BASE, 0)
var COLOR_FOCUS = Color(COLOR_BASE, 0.3)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_area_3d_mouse_entered():
    pass

func _on_area_3d_mouse_exited():
    pass

func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
            select_tile.emit(self)
