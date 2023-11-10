extends Node
class_name Tile

signal select_tile
signal rotate_tile

@export var can_rotate : bool = true
@export var can_move : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass

func _on_area_3d_mouse_entered():
    pass

func _on_area_3d_mouse_exited():
    pass

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
            select_tile.emit(self)

