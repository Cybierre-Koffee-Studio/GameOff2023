extends Node3D

signal add_tile

@onready var material:StandardMaterial3D
var COLOR_BASE = Color("0062c0")
var COLOR_BLUR = Color(COLOR_BASE, 0)
var COLOR_FOCUS = Color(COLOR_BASE, 0.3)

var available = false
var board : Board

# Called when the node enters the scene tree for the first time.
func _ready():
    material = StandardMaterial3D.new()
    material.albedo_color = COLOR_BLUR
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $Mesh.set_surface_override_material(0,material)

func set_available():
    available = true
    material.albedo_color = COLOR_FOCUS

func set_unavailable():
    available = false
    material.albedo_color = COLOR_BLUR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass

func _on_area_3d_mouse_entered():
    if board != null && board.selected_tile_copy != null && available:
        material.albedo_color = COLOR_BLUR
        board.selected_tile_copy.visible = true
        board.selected_tile_copy.position = self.position

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
            if GlobalVars.selected_tile != null && available:
                add_tile.emit(self)

func _on_area_3d_mouse_exited():
    if board != null && board.selected_tile_copy != null:
        board.selected_tile_copy.visible = false
        if available:
            material.albedo_color = COLOR_FOCUS
