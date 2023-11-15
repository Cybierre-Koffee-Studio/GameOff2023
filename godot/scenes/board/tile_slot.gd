extends Node3D

signal add_tile

@onready var material:StandardMaterial3D
var COLOR_BLUR = Color("8a8983", 0.2)
var COLOR_FOCUS = Color("8a8983", 1)

var available = true
var board : Board

# Called when the node enters the scene tree for the first time.
func _ready():
    material = StandardMaterial3D.new()
    material.albedo_color = COLOR_BLUR
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $Mesh.set_surface_override_material(0,material)

func set_available():
    available = true

func set_unavailable():
    available = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if available:
        material.albedo_color = COLOR_FOCUS
    else:
        material.albedo_color = COLOR_BLUR

func _on_area_3d_mouse_entered():
    if board != null && board.selected_tile_copy != null:
        if available:
            material.albedo_color = COLOR_BLUR
            board.selected_tile_copy.visible = true
            board.selected_tile_copy.position = self.position
        else:
            board.selected_tile_copy.visible = false
        
func emit_add_tile(tile):
    add_tile.emit(self)
    set_available()

func _on_area_3d_mouse_exited():
    if board != null && board.selected_tile_copy != null:
        board.selected_tile_copy.visible = false
        if available:
            material.albedo_color = COLOR_FOCUS
