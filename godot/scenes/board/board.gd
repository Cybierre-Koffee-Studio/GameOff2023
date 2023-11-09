extends Node3D

signal tile_placed

var tileSlotScene = load("res://scenes/board/tile_slot.tscn")
var GRID_SIZE = 12
var currentTileRotation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in GRID_SIZE*GRID_SIZE:
        var tileSlot: Node3D = tileSlotScene.instantiate()
        tileSlot.position.x = i/GRID_SIZE - 5.5
        tileSlot.position.z = i%GRID_SIZE - 5.5
        tileSlot.position.y = 0.5
        tileSlot.connect("add_tile", on_add_tile)
        add_child(tileSlot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("rotate_tile"):
        currentTileRotation -= deg_to_rad(90.0)
        var tween = create_tween()
        tween.tween_property(GlobalVars.selected_tile_copy, "rotation:y", currentTileRotation, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func on_add_tile(src):
    var tuile = GlobalVars.selected_tile_copy
    remove_child(GlobalVars.selected_tile_copy)
    GlobalVars.selected_tile_copy = null
    emit_signal("tile_placed", tuile)
    tuile.position = src.position
    tuile.position.y = 50
    add_child(tuile)
    var tween = create_tween()
    tween.tween_property(tuile, "position:y", 0.5, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.tween_callback(src.queue_free)
    tip((tuile.position.x+0.5)*0.8)

func tip(angle):
    var tween = create_tween()
    tween.tween_property(self, "rotation_degrees:z", rotation_degrees.z - angle, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.6)
    
func on_tile_selected(tile):
    currentTileRotation = 0
    GlobalVars.selected_tile_copy = tile.duplicate()
    GlobalVars.selected_tile_copy.scale = Vector3(1,1,1)
    add_child(GlobalVars.selected_tile_copy)
