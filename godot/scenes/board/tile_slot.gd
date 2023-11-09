extends Node3D

signal add_tile

@onready var material:StandardMaterial3D
var COLOR_BASE = Color("0062c0")
var COLOR_BLUR = Color(COLOR_BASE, 0)
var COLOR_FOCUS = Color(COLOR_BASE, 0.3)

# Called when the node enters the scene tree for the first time.
func _ready():
    material = StandardMaterial3D.new()
    material.albedo_color = COLOR_BLUR
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $Mesh.set_surface_override_material(0,material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_area_3d_mouse_entered():
    print("mouse_entered", GlobalVars.selected_tile_copy)
    if GlobalVars.selected_tile_copy != null:
        GlobalVars.selected_tile_copy.position = self.position

func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
            if GlobalVars.selected_tile != null:
                add_tile.emit(self)

