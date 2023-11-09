extends Node3D

signal add_tile

@onready var sfo:StandardMaterial3D
var COLOR_BASE = Color("0062c0")
var COLOR_BLUR = Color(COLOR_BASE, 0)
var COLOR_FOCUS = Color(COLOR_BASE, 0.3)

# Called when the node enters the scene tree for the first time.
func _ready():
    sfo = StandardMaterial3D.new()
    sfo.albedo_color = COLOR_BLUR
    sfo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $Mesh.set_surface_override_material(0,sfo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_area_3d_mouse_entered():
    print("mouse_entered")
    var tween: Tween = create_tween()
    tween.tween_property(sfo, "albedo_color", COLOR_FOCUS, 0.1).set_ease(Tween.EASE_OUT)


func _on_area_3d_mouse_exited():
    print("mouse_exited")
    var tween: Tween = create_tween()
    tween.tween_property(sfo, "albedo_color", COLOR_BLUR, 0.1).set_ease(Tween.EASE_OUT)


func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
            if GlobalVars.selected_tile != null:
                add_tile.emit(self)

